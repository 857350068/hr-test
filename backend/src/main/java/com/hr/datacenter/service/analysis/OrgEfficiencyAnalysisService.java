package com.hr.datacenter.service.analysis;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

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
        
        String sql = "SELECT department, " +
                "COUNT(DISTINCT emp_id) as emp_count, " +
                "AVG(salary) as avg_salary, " +
                "SUM(salary) as total_salary, " +
                "COUNT(CASE WHEN status = 1 THEN 1 END) as active_count, " +
                "COUNT(CASE WHEN status = 0 THEN 1 END) as inactive_count " +
                "FROM dim_employee " +
                "WHERE 1=1 " +
                (department != null && !department.isEmpty() ? "AND department = '" + department + "' " : "") +
                "GROUP BY department " +
                "ORDER BY emp_count DESC";
        
        List<Map<String, Object>> result = hiveJdbc.queryForList(sql);
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
        
        Map<String, Object> result = new HashMap<>();
        
        // 按部门统计人数
        String deptSql = "SELECT department, COUNT(*) as count " +
                "FROM dim_employee " +
                "GROUP BY department " +
                "ORDER BY count DESC";
        List<Map<String, Object>> deptStats = hiveJdbc.queryForList(deptSql);
        result.put("departmentStats", deptStats);
        
        // 按岗位统计人数
        String posSql = "SELECT position, COUNT(*) as count " +
                "FROM dim_employee " +
                "GROUP BY position " +
                "ORDER BY count DESC " +
                "LIMIT 10";
        List<Map<String, Object>> posStats = hiveJdbc.queryForList(posSql);
        result.put("positionStats", posStats);
        
        // 按学历统计人数
        String eduSql = "SELECT education, COUNT(*) as count " +
                "FROM dim_employee " +
                "GROUP BY education " +
                "ORDER BY count DESC";
        List<Map<String, Object>> eduStats = hiveJdbc.queryForList(eduSql);
        result.put("educationStats", eduStats);
        
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
        
        String sql = "SELECT department, position, " +
                "COUNT(*) as current_count, " +
                "AVG(salary) as avg_salary, " +
                "SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) as active_ratio " +
                "FROM dim_employee " +
                "GROUP BY department, position " +
                "HAVING current_count > 0 " +
                "ORDER BY department, current_count DESC";
        
        List<Map<String, Object>> result = hiveJdbc.queryForList(sql);
        log.info("人员配置分析完成，共{}个配置项", result.size());
        
        return result;
    }

    /**
     * 获取组织健康度评分
     * @return 组织健康度各项指标
     */
    public Map<String, Object> getOrganizationHealth() {
        log.info("开始计算组织健康度");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        
        Map<String, Object> result = new HashMap<>();
        
        // 员工稳定性（在职率）
        String stabilitySql = "SELECT " +
                "COUNT(CASE WHEN status = 1 THEN 1 END) * 100.0 / COUNT(*) as stability_rate " +
                "FROM dim_employee";
        Double stabilityRate = hiveJdbc.queryForObject(stabilitySql, Double.class);
        result.put("stabilityRate", stabilityRate);
        
        // 人员流动性（离职率）
        String turnoverSql = "SELECT " +
                "COUNT(CASE WHEN resign_date IS NOT NULL AND resign_date != '' THEN 1 END) * 100.0 / COUNT(*) as turnover_rate " +
                "FROM dim_employee";
        Double turnoverRate = hiveJdbc.queryForObject(turnoverSql, Double.class);
        result.put("turnoverRate", turnoverRate);
        
        // 薪酬竞争力（平均薪资）
        String salarySql = "SELECT AVG(salary) as avg_salary FROM dim_employee";
        Double avgSalary = hiveJdbc.queryForObject(salarySql, Double.class);
        result.put("avgSalary", avgSalary);
        
        // 学历结构
        String eduSql = "SELECT " +
                "COUNT(CASE WHEN education IN ('本科', '硕士', '博士') THEN 1 END) * 100.0 / COUNT(*) as high_edu_rate " +
                "FROM dim_employee";
        Double highEduRate = hiveJdbc.queryForObject(eduSql, Double.class);
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
}
