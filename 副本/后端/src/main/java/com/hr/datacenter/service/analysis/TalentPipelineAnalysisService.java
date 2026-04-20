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
 * 人才梯队分析服务
 * 提供人才储备、继任计划、能力评估等分析功能
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class TalentPipelineAnalysisService {

    @Autowired
    @Qualifier("hiveDataSource")
    private DataSource hiveDataSource;

    /**
     * 获取人才储备分析
     * @param department 部门名称（可选）
     * @return 人才储备数据
     */
    public List<Map<String, Object>> getTalentReserve(String department) {
        log.info("开始分析人才储备，部门：{}", department);
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        String latestDt = getLatestDt(hiveJdbc);

        StringBuilder sql = new StringBuilder("SELECT department, position, " +
                "COUNT(*) as total_count, " +
                "COUNT(CASE WHEN education IN ('本科', '硕士', '博士') THEN 1 END) as high_talent_count, " +
                "COUNT(CASE WHEN current_salary > (SELECT AVG(current_salary) FROM dim_employee WHERE dt = ?) THEN 1 END) as high_salary_count, " +
                "AVG(current_salary) as avg_salary " +
                "FROM dim_employee WHERE ");

        List<Object> params = new ArrayList<>();
        appendLatestDtCondition(sql, params, latestDt);
        sql.append(" AND status = 1 ");
        if (StringUtils.hasText(department)) {
            sql.append(" AND department = ? ");
            params.add(department);
        }
        sql.append(" GROUP BY department, position ORDER BY high_talent_count DESC");

        if (StringUtils.hasText(latestDt)) {
            params.add(0, latestDt);
        } else {
            // 未能取到分区时，子查询改全量
            int idx = sql.indexOf("WHERE dt = ?");
            if (idx >= 0) {
                sql.replace(idx, idx + "WHERE dt = ?".length(), "WHERE 1=1");
            }
        }

        List<Map<String, Object>> result = hiveJdbc.queryForList(sql.toString(), params.toArray());
        log.info("人才储备分析完成，共{}个岗位", result.size());
        
        return result;
    }

    /**
     * 获取继任计划分析
     * @return 关键岗位继任者分析
     */
    public List<Map<String, Object>> getSuccessionPlan() {
        log.info("开始分析继任计划");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        String latestDt = getLatestDt(hiveJdbc);
        
        // 识别关键岗位（管理层、技术骨干）
        String sql = "SELECT department, position, " +
                "COUNT(*) as current_count, " +
                "COUNT(CASE WHEN position LIKE '%经理%' OR position LIKE '%总监%' OR position LIKE '%主管%' THEN 1 END) as manager_count, " +
                "COUNT(CASE WHEN education = '硕士' OR education = '博士' THEN 1 END) as potential_successor " +
                "FROM dim_employee " +
                buildLatestDtWhereClause(latestDt) +
                "AND status = 1 " +
                "GROUP BY department, position " +
                "HAVING manager_count > 0 OR position LIKE '%经理%' OR position LIKE '%总监%' " +
                "ORDER BY manager_count DESC";
        
        List<Map<String, Object>> result = queryForListWithLatestDt(hiveJdbc, sql, latestDt);
        log.info("继任计划分析完成，共{}个关键岗位", result.size());
        
        return result;
    }

    /**
     * 获取能力评估分析
     * @return 员工能力分布
     */
    public Map<String, Object> getCapabilityAssessment() {
        log.info("开始分析能力评估");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        String latestDt = getLatestDt(hiveJdbc);
        
        Map<String, Object> result = new HashMap<>();
        
        // 学历能力分布
        String eduSql = "SELECT education, COUNT(*) as count " +
                "FROM dim_employee " +
                buildLatestDtWhereClause(latestDt) +
                "AND status = 1 " +
                "GROUP BY education " +
                "ORDER BY count DESC";
        List<Map<String, Object>> eduDist = queryForListWithLatestDt(hiveJdbc, eduSql, latestDt);
        result.put("educationDistribution", eduDist);
        
        // 薪资能力分布（按薪资区间）
        String salarySql = "SELECT " +
                "CASE " +
                "  WHEN current_salary < 5000 THEN '0-5K' " +
                "  WHEN current_salary < 10000 THEN '5K-10K' " +
                "  WHEN current_salary < 15000 THEN '10K-15K' " +
                "  WHEN current_salary < 20000 THEN '15K-20K' " +
                "  ELSE '20K+' " +
                "END as salary_range, " +
                "COUNT(*) as count " +
                "FROM dim_employee " +
                buildLatestDtWhereClause(latestDt) +
                "AND status = 1 " +
                "GROUP BY " +
                "CASE " +
                "  WHEN current_salary < 5000 THEN '0-5K' " +
                "  WHEN current_salary < 10000 THEN '5K-10K' " +
                "  WHEN current_salary < 15000 THEN '10K-15K' " +
                "  WHEN current_salary < 20000 THEN '15K-20K' " +
                "  ELSE '20K+' " +
                "END " +
                "ORDER BY salary_range";
        List<Map<String, Object>> salaryDist = queryForListWithLatestDt(hiveJdbc, salarySql, latestDt);
        result.put("salaryDistribution", salaryDist);
        
        // 工龄能力分布
        String tenureSql = "SELECT " +
                "CASE " +
                "  WHEN DATEDIFF(CURRENT_DATE, hire_date) < 365 THEN '0-1年' " +
                "  WHEN DATEDIFF(CURRENT_DATE, hire_date) < 730 THEN '1-2年' " +
                "  WHEN DATEDIFF(CURRENT_DATE, hire_date) < 1095 THEN '2-3年' " +
                "  WHEN DATEDIFF(CURRENT_DATE, hire_date) < 1825 THEN '3-5年' " +
                "  ELSE '5年+' " +
                "END as tenure_range, " +
                "COUNT(*) as count " +
                "FROM dim_employee " +
                buildLatestDtWhereClause(latestDt) +
                "AND status = 1 " +
                "GROUP BY " +
                "CASE " +
                "  WHEN DATEDIFF(CURRENT_DATE, hire_date) < 365 THEN '0-1年' " +
                "  WHEN DATEDIFF(CURRENT_DATE, hire_date) < 730 THEN '1-2年' " +
                "  WHEN DATEDIFF(CURRENT_DATE, hire_date) < 1095 THEN '2-3年' " +
                "  WHEN DATEDIFF(CURRENT_DATE, hire_date) < 1825 THEN '3-5年' " +
                "  ELSE '5年+' " +
                "END";
        List<Map<String, Object>> tenureDist = queryForListWithLatestDt(hiveJdbc, tenureSql, latestDt);
        result.put("tenureDistribution", tenureDist);
        
        log.info("能力评估分析完成");
        return result;
    }

    /**
     * 获取人才梯队健康度
     * @return 人才梯队健康度评分
     */
    public Map<String, Object> getTalentPipelineHealth() {
        log.info("开始计算人才梯队健康度");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        String latestDt = getLatestDt(hiveJdbc);
        
        Map<String, Object> result = new HashMap<>();
        
        // 高学历人才比例
        String highEduSql = "SELECT " +
                "COUNT(CASE WHEN education IN ('本科', '硕士', '博士') THEN 1 END) * 100.0 / COUNT(*) as rate " +
                "FROM dim_employee " + buildLatestDtWhereClause(latestDt) + "AND status = 1";
        Double highEduRate = queryForObjectWithLatestDt(hiveJdbc, highEduSql, latestDt);
        result.put("highEducationRate", highEduRate);
        
        // 核心岗位人才储备
        String coreSql = "SELECT " +
                "COUNT(CASE WHEN position LIKE '%经理%' OR position LIKE '%总监%' OR position LIKE '%工程师%' THEN 1 END) as core_count, " +
                "COUNT(*) as total_count " +
                "FROM dim_employee " + buildLatestDtWhereClause(latestDt) + "AND status = 1";
        Map<String, Object> coreStats = queryForMapWithLatestDt(hiveJdbc, coreSql, latestDt);
        result.put("coreTalentStats", coreStats);
        
        // 继任者准备度
        String successorSql = "SELECT " +
                "COUNT(CASE WHEN education = '硕士' OR education = '博士' THEN 1 END) * 100.0 / COUNT(*) as successor_rate " +
                "FROM dim_employee " +
                buildLatestDtWhereClause(latestDt) +
                "AND status = 1 AND (position LIKE '%工程师%' OR position LIKE '%专员%')";
        Double successorRate = queryForObjectWithLatestDt(hiveJdbc, successorSql, latestDt);
        result.put("successorReadiness", successorRate);
        
        // 计算综合健康度
        double healthScore = calculatePipelineHealthScore(highEduRate, successorRate);
        result.put("healthScore", healthScore);
        
        log.info("人才梯队健康度计算完成，综合评分：{}", healthScore);
        return result;
    }

    /**
     * 计算人才梯队健康度评分
     */
    private double calculatePipelineHealthScore(Double highEduRate, Double successorRate) {
        double score = 0.0;
        
        // 高学历人才比例（权重50%）
        if (highEduRate != null) {
            score += (highEduRate / 100) * 50;
        }
        
        // 继任者准备度（权重50%）
        if (successorRate != null) {
            score += (successorRate / 100) * 50;
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

    private Double queryForObjectWithLatestDt(JdbcTemplate hiveJdbc, String sql, String latestDt) {
        return StringUtils.hasText(latestDt)
                ? hiveJdbc.queryForObject(sql, Double.class, latestDt)
                : hiveJdbc.queryForObject(sql, Double.class);
    }

    private Map<String, Object> queryForMapWithLatestDt(JdbcTemplate hiveJdbc, String sql, String latestDt) {
        return StringUtils.hasText(latestDt) ? hiveJdbc.queryForMap(sql, latestDt) : hiveJdbc.queryForMap(sql);
    }
}
