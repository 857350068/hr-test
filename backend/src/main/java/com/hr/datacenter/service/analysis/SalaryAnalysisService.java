package com.hr.datacenter.service.analysis;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.util.*;

/**
 * 薪酬福利分析服务
 * 提供薪酬结构、竞争力分析、成本优化等分析功能
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class SalaryAnalysisService {

    @Autowired
    @Qualifier("hiveDataSource")
    private DataSource hiveDataSource;

    /**
     * 获取薪酬结构分析
     * @return 薪酬结构分布数据
     */
    public Map<String, Object> getSalaryStructure() {
        log.info("开始分析薪酬结构");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        
        Map<String, Object> result = new HashMap<>();
        
        // 按部门统计薪酬
        String deptSql = "SELECT department, " +
                "COUNT(*) as emp_count, " +
                "AVG(salary) as avg_salary, " +
                "MIN(salary) as min_salary, " +
                "MAX(salary) as max_salary, " +
                "SUM(salary) as total_salary " +
                "FROM dim_employee " +
                "WHERE status = 1 " +
                "GROUP BY department " +
                "ORDER BY total_salary DESC";
        List<Map<String, Object>> deptStats = hiveJdbc.queryForList(deptSql);
        result.put("departmentSalary", deptStats);
        
        // 按岗位统计薪酬
        String posSql = "SELECT position, " +
                "COUNT(*) as emp_count, " +
                "AVG(salary) as avg_salary, " +
                "MIN(salary) as min_salary, " +
                "MAX(salary) as max_salary " +
                "FROM dim_employee " +
                "WHERE status = 1 " +
                "GROUP BY position " +
                "ORDER BY avg_salary DESC " +
                "LIMIT 20";
        List<Map<String, Object>> posStats = hiveJdbc.queryForList(posSql);
        result.put("positionSalary", posStats);
        
        // 薪酬区间分布
        String rangeSql = "SELECT " +
                "CASE " +
                "  WHEN salary < 5000 THEN '0-5K' " +
                "  WHEN salary < 10000 THEN '5K-10K' " +
                "  WHEN salary < 15000 THEN '10K-15K' " +
                "  WHEN salary < 20000 THEN '15K-20K' " +
                "  WHEN salary < 30000 THEN '20K-30K' " +
                "  ELSE '30K+' " +
                "END as salary_range, " +
                "COUNT(*) as count, " +
                "SUM(salary) as total_salary " +
                "FROM dim_employee " +
                "WHERE status = 1 " +
                "GROUP BY " +
                "CASE " +
                "  WHEN salary < 5000 THEN '0-5K' " +
                "  WHEN salary < 10000 THEN '5K-10K' " +
                "  WHEN salary < 15000 THEN '10K-15K' " +
                "  WHEN salary < 20000 THEN '15K-20K' " +
                "  WHEN salary < 30000 THEN '20K-30K' " +
                "  ELSE '30K+' " +
                "END " +
                "ORDER BY salary_range";
        List<Map<String, Object>> rangeStats = hiveJdbc.queryForList(rangeSql);
        result.put("salaryRangeDistribution", rangeStats);
        
        log.info("薪酬结构分析完成");
        return result;
    }

    /**
     * 获取薪酬竞争力分析
     * @return 薪酬竞争力评估
     */
    public Map<String, Object> getSalaryCompetitiveness() {
        log.info("开始分析薪酬竞争力");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        
        Map<String, Object> result = new HashMap<>();
        
        // 整体薪酬水平
        String overallSql = "SELECT " +
                "AVG(salary) as avg_salary, " +
                "PERCENTILE(CAST(salary AS BIGINT), 0.5) as median_salary, " +
                "STDDEV(salary) as salary_stddev " +
                "FROM dim_employee WHERE status = 1";
        Map<String, Object> overallStats = hiveJdbc.queryForMap(overallSql);
        result.put("overallStats", overallStats);
        
        // 部门薪酬竞争力
        String deptCompSql = "SELECT department, " +
                "AVG(salary) as avg_salary, " +
                "AVG(salary) - (SELECT AVG(salary) FROM dim_employee WHERE status = 1) as salary_diff " +
                "FROM dim_employee " +
                "WHERE status = 1 " +
                "GROUP BY department " +
                "ORDER BY avg_salary DESC";
        List<Map<String, Object>> deptComp = hiveJdbc.queryForList(deptCompSql);
        result.put("departmentCompetitiveness", deptComp);
        
        // 高薪人才分布
        String highPaySql = "SELECT department, position, COUNT(*) as high_pay_count " +
                "FROM dim_employee " +
                "WHERE status = 1 AND salary > (SELECT AVG(salary) * 1.5 FROM dim_employee WHERE status = 1) " +
                "GROUP BY department, position " +
                "ORDER BY high_pay_count DESC";
        List<Map<String, Object>> highPayDist = hiveJdbc.queryForList(highPaySql);
        result.put("highPayDistribution", highPayDist);
        
        log.info("薪酬竞争力分析完成");
        return result;
    }

    /**
     * 获取人力成本分析
     * @return 人力成本统计
     */
    public Map<String, Object> getLaborCostAnalysis() {
        log.info("开始分析人力成本");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        
        Map<String, Object> result = new HashMap<>();
        
        // 总人力成本
        String totalSql = "SELECT " +
                "SUM(salary) as total_cost, " +
                "AVG(salary) as avg_cost, " +
                "COUNT(*) as emp_count " +
                "FROM dim_employee WHERE status = 1";
        Map<String, Object> totalCost = hiveJdbc.queryForMap(totalSql);
        result.put("totalCost", totalCost);
        
        // 部门成本占比
        String deptRatioSql = "SELECT department, " +
                "SUM(salary) as dept_cost, " +
                "SUM(salary) * 100.0 / (SELECT SUM(salary) FROM dim_employee WHERE status = 1) as cost_ratio " +
                "FROM dim_employee " +
                "WHERE status = 1 " +
                "GROUP BY department " +
                "ORDER BY dept_cost DESC";
        List<Map<String, Object>> deptRatio = hiveJdbc.queryForList(deptRatioSql);
        result.put("departmentCostRatio", deptRatio);
        
        // 成本趋势（按入职时间）
        String trendSql = "SELECT YEAR(hire_date) as year, " +
                "COUNT(*) as new_hires, " +
                "SUM(salary) as new_cost " +
                "FROM dim_employee " +
                "WHERE status = 1 AND hire_date IS NOT NULL " +
                "GROUP BY YEAR(hire_date) " +
                "ORDER BY year DESC " +
                "LIMIT 5";
        List<Map<String, Object>> trend = hiveJdbc.queryForList(trendSql);
        result.put("costTrend", trend);
        
        log.info("人力成本分析完成");
        return result;
    }

    /**
     * 获取薪酬优化建议
     * @return 薪酬优化建议
     */
    public List<Map<String, Object>> getSalaryOptimization() {
        log.info("开始生成薪酬优化建议");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        
        List<Map<String, Object>> suggestions = new ArrayList<>();
        
        // 识别薪酬异常（过高或过低）
        String anomalySql = "SELECT emp_id, emp_name, department, position, salary, " +
                "salary - (SELECT AVG(salary) FROM dim_employee WHERE status = 1) as salary_diff " +
                "FROM dim_employee " +
                "WHERE status = 1 " +
                "AND (salary > (SELECT AVG(salary) * 1.5 FROM dim_employee WHERE status = 1) " +
                "  OR salary < (SELECT AVG(salary) * 0.5 FROM dim_employee WHERE status = 1)) " +
                "ORDER BY ABS(salary_diff) DESC " +
                "LIMIT 10";
        List<Map<String, Object>> anomalies = hiveJdbc.queryForList(anomalySql);
        
        for (Map<String, Object> anomaly : anomalies) {
            Map<String, Object> suggestion = new HashMap<>();
            suggestion.put("type", "薪酬异常");
            suggestion.put("employee", anomaly.get("emp_name"));
            suggestion.put("department", anomaly.get("department"));
            suggestion.put("currentSalary", anomaly.get("salary"));
            suggestion.put("suggestion", "建议调整薪酬至合理区间");
            suggestions.add(suggestion);
        }
        
        log.info("薪酬优化建议生成完成，共{}条建议", suggestions.size());
        return suggestions;
    }
}
