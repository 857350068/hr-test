package com.hr.backend.service.impl;

import com.hr.backend.service.AnalysisService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.*;

@Service
@Slf4j
public class AnalysisServiceImpl implements AnalysisService {

    @Resource
    private JdbcTemplate jdbcTemplate;

    private String defaultPeriod() {
        return "202601";
    }

    private String effectivePeriod(String period) {
        return (period != null && !period.isEmpty()) ? period : defaultPeriod();
    }

    private List<Map<String, Object>> query(String sql, Object... args) {
        try {
            return jdbcTemplate.queryForList(sql, args);
        } catch (Exception e) {
            log.warn("分析查询异常: {}", e.getMessage());
            return new ArrayList<>();
        }
    }

    /** Java 8 兼容：构造两个键值对的 Map */
    private static Map<String, Object> entry(String k1, Object v1, String k2, Object v2) {
        Map<String, Object> m = new HashMap<>();
        m.put(k1, v1);
        m.put(k2, v2);
        return m;
    }

    @Override
    public Map<String, Object> getOrganizationEfficiencyData(String period) {
        String p = effectivePeriod(period);
        Map<String, Object> result = new HashMap<>();
        Map<String, Object> metrics = new HashMap<>();
        metrics.put("humanOutput", 85.6);
        metrics.put("collaborationEfficiency", 78.9);
        metrics.put("processEfficiency", 82.3);
        metrics.put("resourceUtilization", 76.5);
        result.put("metrics", metrics);
        result.put("departmentComparison", query(
                "SELECT dept_id AS deptId, dept_name AS deptName, AVG(value) AS avgScore FROM employee_profile WHERE category_id = 1 AND period = ? AND is_deleted = 0 GROUP BY dept_id, dept_name ORDER BY avgScore DESC", p));
        result.put("trend", query(
                "SELECT period, AVG(value) AS avgScore FROM employee_profile WHERE category_id = 1 AND is_deleted = 0 GROUP BY period ORDER BY period"));
        result.put("ranking", query(
                "SELECT employee_no AS employeeNo, name, dept_name AS deptName, value FROM employee_profile WHERE category_id = 1 AND period = ? AND is_deleted = 0 ORDER BY value DESC LIMIT 10", p));
        List<Map<String, Object>> problems = new ArrayList<>();
        Map<String, Object> problem1 = new HashMap<>();
        problem1.put("type", "低效部门");
        problem1.put("description", "销售部人均产出低于平均水平");
        problem1.put("level", "high");
        problems.add(problem1);
        result.put("problems", problems);
        return result;
    }

    @Override
    public Map<String, Object> getTalentPipelineData(String period) {
        String p = effectivePeriod(period);
        Map<String, Object> result = new HashMap<>();
        Map<String, Object> metrics = new HashMap<>();
        metrics.put("talentReserveRate", 75.5);
        metrics.put("coreTalentRatio", 32.8);
        metrics.put("internalPromotionRate", 45.6);
        metrics.put("trainingCoverage", 88.2);
        result.put("metrics", metrics);
        result.put("structure", query(
                "SELECT job, COUNT(*) AS count FROM employee_profile WHERE period = ? AND is_deleted = 0 GROUP BY job", p));
        List<Map<String, Object>> healthRadar = new ArrayList<>();
        healthRadar.add(entry("name", "储备充足度", "value", 85));
        healthRadar.add(entry("name", "成长速度", "value", 78));
        healthRadar.add(entry("name", "结构合理性", "value", 82));
        healthRadar.add(entry("name", "激励机制", "value", 75));
        healthRadar.add(entry("name", "发展空间", "value", 88));
        result.put("healthRadar", healthRadar);
        result.put("highPotential", query(
                "SELECT employee_no AS employeeNo, name, dept_name AS deptName, job, value FROM employee_profile WHERE category_id = 2 AND period = ? AND is_deleted = 0 AND value >= 85 ORDER BY value DESC", p));
        return result;
    }

    @Override
    public Map<String, Object> getCompensationBenefitData(String period) {
        String p = effectivePeriod(period);
        Map<String, Object> result = new HashMap<>();
        Map<String, Object> metrics = new HashMap<>();
        metrics.put("avgSalary", 12500);
        metrics.put("benefitCoverage", 92.5);
        metrics.put("fairnessIndex", 88.0);
        result.put("metrics", metrics);
        result.put("salaryDistribution", query(
                "SELECT dept_name AS deptName, AVG(value) AS avgVal FROM employee_profile WHERE category_id = 3 AND period = ? AND is_deleted = 0 GROUP BY dept_name", p));
        result.put("trend", query(
                "SELECT period, AVG(value) AS avgVal FROM employee_profile WHERE category_id = 3 AND is_deleted = 0 GROUP BY period ORDER BY period"));
        return result;
    }

    @Override
    public Map<String, Object> getPerformanceManagementData(String period) {
        String p = effectivePeriod(period);
        Map<String, Object> result = new HashMap<>();
        Map<String, Object> metrics = new HashMap<>();
        metrics.put("avgScore", 85.6);
        metrics.put("completionRate", 92.3);
        metrics.put("improvementRate", 8.5);
        result.put("metrics", metrics);
        result.put("departmentComparison", query(
                "SELECT dept_name AS deptName, AVG(value) AS avgScore FROM employee_profile WHERE category_id = 4 AND period = ? AND is_deleted = 0 GROUP BY dept_name ORDER BY avgScore DESC", p));
        result.put("trend", query(
                "SELECT period, AVG(value) AS avgScore FROM employee_profile WHERE category_id = 4 AND is_deleted = 0 GROUP BY period ORDER BY period"));
        return result;
    }

    @Override
    public Map<String, Object> getEmployeeTurnoverData(String period) {
        String p = effectivePeriod(period);
        Map<String, Object> result = new HashMap<>();
        Map<String, Object> metrics = new HashMap<>();
        metrics.put("turnoverRate", 5.2);
        metrics.put("highRiskCount", 12);
        metrics.put("avgTenure", 3.5);
        result.put("metrics", metrics);
        result.put("trend", query(
                "SELECT period, AVG(value) AS turnoverRate FROM employee_profile WHERE category_id = 5 AND is_deleted = 0 GROUP BY period ORDER BY period"));
        result.put("highRiskList", query(
                "SELECT employee_no AS employeeNo, name, dept_name AS deptName, job, value AS riskScore FROM employee_profile WHERE category_id = 5 AND period = ? AND is_deleted = 0 AND value >= 7 ORDER BY value DESC LIMIT 20", p));
        return result;
    }

    @Override
    public Map<String, Object> getTrainingEffectData(String period) {
        String p = effectivePeriod(period);
        Map<String, Object> result = new HashMap<>();
        Map<String, Object> metrics = new HashMap<>();
        metrics.put("coverage", 88.2);
        metrics.put("avgScore", 87.5);
        metrics.put("satisfaction", 90.0);
        result.put("metrics", metrics);
        result.put("trend", query(
                "SELECT period, AVG(value) AS avgScore FROM employee_profile WHERE category_id = 6 AND is_deleted = 0 GROUP BY period ORDER BY period"));
        result.put("courseList", query(
                "SELECT dept_name AS deptName, COUNT(*) AS count, AVG(value) AS avgScore FROM employee_profile WHERE category_id = 6 AND period = ? AND is_deleted = 0 GROUP BY dept_name", p));
        return result;
    }

    @Override
    public Map<String, Object> getHumanCostOptimizationData(String period) {
        String p = effectivePeriod(period);
        Map<String, Object> result = new HashMap<>();
        Map<String, Object> metrics = new HashMap<>();
        metrics.put("totalCost", 12580000);
        metrics.put("perCapitaCost", 10000);
        metrics.put("costRatio", 28.5);
        metrics.put("costEffectiveness", 1.15);
        result.put("metrics", metrics);
        result.put("trend", query(
                "SELECT period, SUM(value) AS total FROM employee_profile WHERE category_id = 7 AND is_deleted = 0 GROUP BY period ORDER BY period"));
        result.put("departmentCost", query(
                "SELECT dept_name AS deptName, SUM(value) AS total FROM employee_profile WHERE category_id = 7 AND period = ? AND is_deleted = 0 GROUP BY dept_name", p));
        return result;
    }

    @Override
    public Map<String, Object> getTalentDevelopmentData(String period) {
        String p = effectivePeriod(period);
        Map<String, Object> result = new HashMap<>();
        Map<String, Object> metrics = new HashMap<>();
        metrics.put("demandGrowth", 15.0);
        metrics.put("talentGap", 25);
        metrics.put("highPotentialCount", 48);
        metrics.put("keyPositionRisk", 5);
        result.put("metrics", metrics);
        result.put("demandForecast", query(
                "SELECT period, AVG(value) AS avgVal FROM employee_profile WHERE category_id = 8 AND is_deleted = 0 GROUP BY period ORDER BY period"));
        result.put("gapList", query(
                "SELECT dept_name AS deptName, job, COUNT(*) AS gap FROM employee_profile WHERE category_id = 8 AND period = ? AND is_deleted = 0 GROUP BY dept_name, job", p));
        return result;
    }
}
