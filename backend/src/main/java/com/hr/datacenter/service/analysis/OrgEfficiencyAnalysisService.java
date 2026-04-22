package com.hr.datacenter.service.analysis;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import javax.sql.DataSource;
import java.util.*;

/**
 * 组织效能分析服务
 * 提供组织效能相关的数据分析功能
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class OrgEfficiencyAnalysisService {

    @Autowired
    @Qualifier("hiveDataSource")
    private DataSource hiveDataSource;

    /**
     * 获取部门效能分析数据
     * @param department 部门名称（可选）
     * @return 部门效能分析结果
     */
    public List<Map<String, Object>> getDepartmentEfficiency(String department) {
        log.info("开始分析部门效能，部门：{}", department);
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        String latestDt = getLatestDt(hiveJdbc);

        StringBuilder sql = new StringBuilder("SELECT department, " +
                "COUNT(DISTINCT emp_id) as emp_count, " +
                "AVG(current_salary) as avg_salary, " +
                "SUM(current_salary) as total_salary, " +
                "COUNT(CASE WHEN status = 1 THEN 1 END) as active_count, " +
                "COUNT(CASE WHEN status = 0 THEN 1 END) as inactive_count " +
                "FROM dim_employee WHERE ");
        List<Object> params = new ArrayList<>();
        appendLatestDtCondition(sql, params, latestDt);
        if (StringUtils.hasText(department)) {
            sql.append(" AND department = ? ");
            params.add(department);
        }
        sql.append(" GROUP BY department ORDER BY emp_count DESC");

        List<Map<String, Object>> result = hiveJdbc.queryForList(sql.toString(), params.toArray());
        log.info("部门效能分析完成，共{}个部门", result.size());
        
        return result;
    }

    /**
     * 获取组织架构分析数据
     * @return 组织架构层级数据
     */
    public Map<String, Object> getOrganizationStructure() {
        log.info("开始分析组织架构");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        String latestDt = getLatestDt(hiveJdbc);
        
        Map<String, Object> result = new HashMap<>();
        
        // 按部门统计人数
        String deptSql = "SELECT department, COUNT(*) as count " +
                "FROM dim_employee " +
                buildLatestDtWhereClause(latestDt) +
                "GROUP BY department " +
                "ORDER BY count DESC";
        List<Map<String, Object>> deptStats = queryForListWithLatestDt(hiveJdbc, deptSql, latestDt);
        result.put("departmentStats", deptStats);
        
        // 按岗位统计人数
        String posSql = "SELECT position, COUNT(*) as count " +
                "FROM dim_employee " +
                buildLatestDtWhereClause(latestDt) +
                "GROUP BY position " +
                "ORDER BY count DESC " +
                "LIMIT 10";
        List<Map<String, Object>> posStats = queryForListWithLatestDt(hiveJdbc, posSql, latestDt);
        result.put("positionStats", posStats);
        
        // 按学历统计人数
        String eduSql = "SELECT education, COUNT(*) as count " +
                "FROM dim_employee " +
                buildLatestDtWhereClause(latestDt) +
                "GROUP BY education " +
                "ORDER BY count DESC";
        List<Map<String, Object>> eduStats = queryForListWithLatestDt(hiveJdbc, eduSql, latestDt);
        result.put("educationStats", eduStats);

        // 原组织效能页面使用明细员工数据构建多个图表，这里补齐该结构字段
        String allEmpSql = "SELECT emp_id, emp_no, emp_name, department, position, education, " +
                "current_salary AS salary, status, hire_date, resign_date " +
                "FROM dim_employee " +
                buildLatestDtWhereClause(latestDt);
        List<Map<String, Object>> allEmployees = queryForListWithLatestDt(hiveJdbc, allEmpSql, latestDt);
        result.put("allEmployees", allEmployees);
        
        log.info("组织架构分析完成");
        return result;
    }

    /**
     * 获取人员配置分析
     * @return 人员配置优化建议
     */
    public List<Map<String, Object>> getStaffingAnalysis() {
        log.info("开始分析人员配置");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        String latestDt = getLatestDt(hiveJdbc);
        
        String sql = "SELECT department, position, " +
                "COUNT(*) as current_count, " +
                "AVG(current_salary) as avg_salary, " +
                "SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) as active_ratio " +
                "FROM dim_employee " +
                buildLatestDtWhereClause(latestDt) +
                "GROUP BY department, position " +
                "HAVING current_count > 0 " +
                "ORDER BY department, current_count DESC";
        
        List<Map<String, Object>> result = queryForListWithLatestDt(hiveJdbc, sql, latestDt);
        log.info("人员配置分析完成，共{}个配置项", result.size());
        
        return result;
    }

    /**
     * 获取组织健康度评分
     * @return 组织健康度各项指标
     */
    public Map<String, Object> getOrganizationHealth() {
        return getOrganizationHealth(null, null, null, null);
    }

    /**
     * 获取组织健康度评分（支持筛选）
     */
    public Map<String, Object> getOrganizationHealth(String department, String position, String empNo, String period) {
        log.info("开始计算组织健康度");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        String latestDt = getLatestDt(hiveJdbc);
        
        Map<String, Object> result = new HashMap<>();
        List<Object> baseParams = new ArrayList<>();
        String whereClause = buildEmployeeFilterClause(latestDt, department, position, empNo, baseParams);
        
        // 员工稳定性（在职率）
        String stabilitySql = "SELECT " +
                "COUNT(CASE WHEN status = 1 THEN 1 END) * 100.0 / COUNT(*) as stability_rate " +
                "FROM dim_employee " + whereClause;
        Double stabilityRate = queryForObjectWithParams(hiveJdbc, stabilitySql, baseParams);
        result.put("stabilityRate", stabilityRate);
        
        // 人员流动性（离职率，可按统计周期约束离职时间）
        List<Object> turnoverParams = new ArrayList<>(baseParams);
        String turnoverTimeFilter = appendTurnoverPeriodFilter(turnoverParams, period);
        String turnoverSql = "SELECT " +
                "COUNT(CASE WHEN resign_date IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) as turnover_rate " +
                "FROM dim_employee " + whereClause + turnoverTimeFilter;
        Double turnoverRate = queryForObjectWithParams(hiveJdbc, turnoverSql, turnoverParams);
        result.put("turnoverRate", turnoverRate);
        
        // 薪酬竞争力（平均薪资）
        String salarySql = "SELECT AVG(current_salary) as avg_salary FROM dim_employee " + whereClause;
        Double avgSalary = queryForObjectWithParams(hiveJdbc, salarySql, baseParams);
        result.put("avgSalary", avgSalary);
        
        // 学历结构
        String eduSql = "SELECT " +
                "COUNT(CASE WHEN education IN ('本科', '硕士', '博士') THEN 1 END) * 100.0 / COUNT(*) as high_edu_rate " +
                "FROM dim_employee " + whereClause;
        Double highEduRate = queryForObjectWithParams(hiveJdbc, eduSql, baseParams);
        result.put("highEducationRate", highEduRate);
        
        // 计算综合健康度评分
        double healthScore = calculateHealthScore(stabilityRate, turnoverRate, highEduRate);
        result.put("healthScore", healthScore);
        
        log.info("组织健康度计算完成，综合评分：{}", healthScore);
        return result;
    }

    /**
     * 计算组织健康度评分
     */
    private double calculateHealthScore(Double stabilityRate, Double turnoverRate, Double highEduRate) {
        double score = 0.0;
        
        // 稳定性评分（权重40%）
        if (stabilityRate != null) {
            score += (stabilityRate / 100) * 40;
        }
        
        // 流失率评分（权重30%，流失率越低分数越高）
        if (turnoverRate != null) {
            score += (1 - turnoverRate / 100) * 30;
        }
        
        // 学历结构评分（权重30%）
        if (highEduRate != null) {
            score += (highEduRate / 100) * 30;
        }
        
        return Math.round(score * 100.0) / 100.0;
    }

    private String getLatestDt(JdbcTemplate hiveJdbc) {
        try {
            return hiveJdbc.queryForObject("SELECT MAX(dt) FROM dim_employee", String.class);
        } catch (Exception ex) {
            log.warn("获取dim_employee最新分区失败，改为全表查询", ex);
            return null;
        }
    }

    private void appendLatestDtCondition(StringBuilder sql, List<Object> params, String latestDt) {
        if (StringUtils.hasText(latestDt)) {
            sql.append(" dt = ? ");
            params.add(latestDt);
        } else {
            sql.append(" 1=1 ");
        }
    }

    private String buildLatestDtWhereClause(String latestDt) {
        return StringUtils.hasText(latestDt) ? "WHERE dt = ? " : "WHERE 1=1 ";
    }

    private List<Map<String, Object>> queryForListWithLatestDt(JdbcTemplate hiveJdbc, String sql, String latestDt) {
        return StringUtils.hasText(latestDt) ? hiveJdbc.queryForList(sql, latestDt) : hiveJdbc.queryForList(sql);
    }

    private String buildEmployeeFilterClause(String latestDt,
                                             String department,
                                             String position,
                                             String empNo,
                                             List<Object> params) {
        StringBuilder whereClause = new StringBuilder("WHERE 1=1 ");
        if (StringUtils.hasText(latestDt)) {
            whereClause.append("AND dt = ? ");
            params.add(latestDt);
        }
        if (StringUtils.hasText(department)) {
            whereClause.append("AND department = ? ");
            params.add(department);
        }
        if (StringUtils.hasText(position)) {
            whereClause.append("AND position = ? ");
            params.add(position);
        }
        if (StringUtils.hasText(empNo)) {
            whereClause.append("AND emp_no LIKE ? ");
            params.add("%" + empNo + "%");
        }
        return whereClause.toString();
    }

    private String appendTurnoverPeriodFilter(List<Object> params, String period) {
        if (!StringUtils.hasText(period)) {
            return "";
        }
        String normalized = period.trim().toLowerCase();
        if ("year".equals(normalized)) {
            params.add(java.sql.Date.valueOf(java.time.LocalDate.now().minusYears(1)));
            return " AND (resign_date IS NULL OR resign_date >= ?) ";
        }
        if ("quarter".equals(normalized)) {
            params.add(java.sql.Date.valueOf(java.time.LocalDate.now().minusMonths(3)));
            return " AND (resign_date IS NULL OR resign_date >= ?) ";
        }
        if ("month".equals(normalized)) {
            params.add(java.sql.Date.valueOf(java.time.LocalDate.now().minusMonths(1)));
            return " AND (resign_date IS NULL OR resign_date >= ?) ";
        }
        return "";
    }

    private Double queryForObjectWithParams(JdbcTemplate hiveJdbc, String sql, List<Object> params) {
        return hiveJdbc.queryForObject(sql, Double.class, params.toArray());
    }
}
