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
        
        // 查询部门效能对比数据
        List<Map<String, Object>> deptComparison = query(
                "SELECT dept_id AS deptId, dept_name AS deptName, AVG(value) AS avgScore FROM employee_profile WHERE category_id = 1 AND period = ? AND is_deleted = 0 GROUP BY dept_id, dept_name ORDER BY avgScore DESC", p);
        
        // 如果数据库没有数据，使用模拟数据
        if (deptComparison.isEmpty()) {
            deptComparison = new ArrayList<>();
            deptComparison.add(createDeptData("研发部", 92.5));
            deptComparison.add(createDeptData("产品部", 88.3));
            deptComparison.add(createDeptData("运营部", 85.6));
            deptComparison.add(createDeptData("市场部", 82.1));
            deptComparison.add(createDeptData("销售部", 78.9));
            deptComparison.add(createDeptData("人事部", 76.5));
        }
        result.put("departmentComparison", deptComparison);
        
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
    
    private Map<String, Object> createDeptData(String deptName, double avgScore) {
        Map<String, Object> data = new HashMap<>();
        data.put("deptName", deptName);
        data.put("avgScore", avgScore);
        return data;
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
        
        // 查询高潜人才数据
        List<Map<String, Object>> highPotential = query(
                "SELECT employee_no AS employeeNo, name, dept_name AS deptName, job, value FROM employee_profile WHERE category_id = 2 AND period = ? AND is_deleted = 0 AND value >= 85 ORDER BY value DESC", p);
        
        // 如果数据库没有数据，使用模拟数据
        if (highPotential.isEmpty()) {
            highPotential = new ArrayList<>();
            highPotential.add(createHighPotentialData("EMP001", "张三", "研发部", "高级工程师", 95.5));
            highPotential.add(createHighPotentialData("EMP002", "李四", "产品部", "产品经理", 92.3));
            highPotential.add(createHighPotentialData("EMP003", "王五", "运营部", "运营总监", 90.8));
            highPotential.add(createHighPotentialData("EMP004", "赵六", "市场部", "市场经理", 88.6));
            highPotential.add(createHighPotentialData("EMP005", "钱七", "研发部", "技术主管", 87.2));
        }
        result.put("highPotential", highPotential);
        return result;
    }
    
    private Map<String, Object> createHighPotentialData(String employeeNo, String name, String deptName, String job, double value) {
        Map<String, Object> data = new HashMap<>();
        data.put("employeeNo", employeeNo);
        data.put("name", name);
        data.put("deptName", deptName);
        data.put("job", job);
        data.put("value", value);
        return data;
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
        
        // 查询薪酬分布数据
        List<Map<String, Object>> salaryDistribution = query(
                "SELECT dept_name AS deptName, AVG(value) AS avgVal FROM employee_profile WHERE category_id = 3 AND period = ? AND is_deleted = 0 GROUP BY dept_name", p);
        
        // 如果数据库没有数据，使用模拟数据
        if (salaryDistribution.isEmpty()) {
            salaryDistribution = new ArrayList<>();
            salaryDistribution.add(createSalaryData("研发部", 15800));
            salaryDistribution.add(createSalaryData("产品部", 14200));
            salaryDistribution.add(createSalaryData("运营部", 12500));
            salaryDistribution.add(createSalaryData("市场部", 11800));
            salaryDistribution.add(createSalaryData("销售部", 13500));
            salaryDistribution.add(createSalaryData("人事部", 10200));
        }
        result.put("salaryDistribution", salaryDistribution);
        
        result.put("trend", query(
                "SELECT period, AVG(value) AS avgVal FROM employee_profile WHERE category_id = 3 AND is_deleted = 0 GROUP BY period ORDER BY period"));
        return result;
    }
    
    private Map<String, Object> createSalaryData(String deptName, double avgVal) {
        Map<String, Object> data = new HashMap<>();
        data.put("deptName", deptName);
        data.put("avgVal", avgVal);
        return data;
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
        
        // 查询部门绩效对比数据
        List<Map<String, Object>> deptComparison = query(
                "SELECT dept_name AS deptName, AVG(value) AS avgScore FROM employee_profile WHERE category_id = 4 AND period = ? AND is_deleted = 0 GROUP BY dept_name ORDER BY avgScore DESC", p);
        
        // 如果数据库没有数据，使用模拟数据
        if (deptComparison.isEmpty()) {
            deptComparison = new ArrayList<>();
            deptComparison.add(createDeptData("研发部", 91.2));
            deptComparison.add(createDeptData("产品部", 88.5));
            deptComparison.add(createDeptData("运营部", 86.3));
            deptComparison.add(createDeptData("市场部", 84.7));
            deptComparison.add(createDeptData("销售部", 82.9));
            deptComparison.add(createDeptData("人事部", 80.5));
        }
        result.put("departmentComparison", deptComparison);
        
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
        
        // 查询高风险员工数据
        List<Map<String, Object>> highRiskList = query(
                "SELECT employee_no AS employeeNo, name, dept_name AS deptName, job, value AS riskScore FROM employee_profile WHERE category_id = 5 AND period = ? AND is_deleted = 0 AND value >= 7 ORDER BY value DESC LIMIT 20", p);
        
        // 如果数据库没有数据，使用模拟数据
        if (highRiskList.isEmpty()) {
            highRiskList = new ArrayList<>();
            highRiskList.add(createRiskData("EMP101", "刘一", "销售部", "销售代表", 85));
            highRiskList.add(createRiskData("EMP102", "陈二", "市场部", "市场专员", 78));
            highRiskList.add(createRiskData("EMP103", "张三", "运营部", "运营助理", 72));
            highRiskList.add(createRiskData("EMP104", "李四", "研发部", "初级工程师", 68));
            highRiskList.add(createRiskData("EMP105", "王五", "人事部", "人事专员", 65));
        }
        result.put("highRiskList", highRiskList);
        return result;
    }
    
    private Map<String, Object> createRiskData(String employeeNo, String name, String deptName, String job, int riskScore) {
        Map<String, Object> data = new HashMap<>();
        data.put("employeeNo", employeeNo);
        data.put("name", name);
        data.put("deptName", deptName);
        data.put("job", job);
        data.put("riskScore", riskScore);
        return data;
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
        
        // 查询培训课程数据
        List<Map<String, Object>> courseList = query(
                "SELECT dept_name AS deptName, COUNT(*) AS count, AVG(value) AS avgScore FROM employee_profile WHERE category_id = 6 AND period = ? AND is_deleted = 0 GROUP BY dept_name", p);
        
        // 如果数据库没有数据，使用模拟数据
        if (courseList.isEmpty()) {
            courseList = new ArrayList<>();
            courseList.add(createCourseData("研发部", 45, 92.5));
            courseList.add(createCourseData("产品部", 32, 88.3));
            courseList.add(createCourseData("运营部", 28, 85.6));
            courseList.add(createCourseData("市场部", 25, 82.1));
            courseList.add(createCourseData("销售部", 38, 86.8));
            courseList.add(createCourseData("人事部", 15, 90.2));
        }
        result.put("courseList", courseList);
        return result;
    }
    
    private Map<String, Object> createCourseData(String deptName, int count, double avgScore) {
        Map<String, Object> data = new HashMap<>();
        data.put("deptName", deptName);
        data.put("count", count);
        data.put("avgScore", avgScore);
        return data;
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
        
        // 查询部门成本数据
        List<Map<String, Object>> departmentCost = query(
                "SELECT dept_name AS deptName, SUM(value) AS total FROM employee_profile WHERE category_id = 7 AND period = ? AND is_deleted = 0 GROUP BY dept_name", p);
        
        // 如果数据库没有数据，使用模拟数据
        if (departmentCost.isEmpty()) {
            departmentCost = new ArrayList<>();
            departmentCost.add(createCostData("研发部", 3580000));
            departmentCost.add(createCostData("产品部", 2120000));
            departmentCost.add(createCostData("运营部", 1850000));
            departmentCost.add(createCostData("市场部", 1620000));
            departmentCost.add(createCostData("销售部", 2280000));
            departmentCost.add(createCostData("人事部", 1130000));
        }
        result.put("departmentCost", departmentCost);
        return result;
    }
    
    private Map<String, Object> createCostData(String deptName, long total) {
        Map<String, Object> data = new HashMap<>();
        data.put("deptName", deptName);
        data.put("total", total);
        return data;
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
        
        // 查询人才缺口数据
        List<Map<String, Object>> gapList = query(
                "SELECT dept_name AS deptName, job, COUNT(*) AS gap FROM employee_profile WHERE category_id = 8 AND period = ? AND is_deleted = 0 GROUP BY dept_name, job", p);
        
        // 如果数据库没有数据，使用模拟数据
        if (gapList.isEmpty()) {
            gapList = new ArrayList<>();
            gapList.add(createGapData("研发部", "高级工程师", 5));
            gapList.add(createGapData("研发部", "架构师", 2));
            gapList.add(createGapData("产品部", "产品经理", 3));
            gapList.add(createGapData("运营部", "运营总监", 2));
            gapList.add(createGapData("市场部", "市场经理", 4));
            gapList.add(createGapData("销售部", "销售主管", 3));
        }
        result.put("gapList", gapList);
        return result;
    }
    
    private Map<String, Object> createGapData(String deptName, String job, int gap) {
        Map<String, Object> data = new HashMap<>();
        data.put("deptName", deptName);
        data.put("job", job);
        data.put("gap", gap);
        return data;
    }
}
