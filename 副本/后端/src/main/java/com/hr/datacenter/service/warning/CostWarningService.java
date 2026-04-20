package com.hr.datacenter.service.warning;

import com.hr.datacenter.service.AnalysisRuleService;
import com.hr.datacenter.service.WarningModelService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CostWarningService {

    @Autowired
    @Qualifier("mysqlDataSource")
    private DataSource mysqlDataSource;
    @Autowired
    private AnalysisRuleService analysisRuleService;
    @Autowired
    private WarningModelService warningModelService;

    public List<Map<String, Object>> getCostOverrunAnalysis() {
        JdbcTemplate jdbcTemplate = new JdbcTemplate(mysqlDataSource);
        double budgetMultiplier = analysisRuleService.getDoubleRule("cost", "cost.budgetMultiplier", 1.10);
        double budgetWeight = warningModelService.getFeatureWeights("cost").getOrDefault("budget", 0.40);
        double adjustedMultiplier = Math.max(1.01, budgetMultiplier + (budgetWeight - 0.40) * 0.25);
        String sql = "SELECT e.department, sp.year, sp.month, " +
                "SUM(sp.total_net_salary) AS total_cost, " +
                "COUNT(DISTINCT sp.emp_id) AS employee_count, " +
                "SUM(sp.total_net_salary) / COUNT(DISTINCT sp.emp_id) AS avg_cost, " +
                "AVG(e.salary) * COUNT(DISTINCT sp.emp_id) * " + adjustedMultiplier + " AS budget_line, " +
                "(SUM(sp.total_net_salary) - AVG(e.salary) * COUNT(DISTINCT sp.emp_id) * " + adjustedMultiplier + ") AS overrun_amount " +
                "FROM salary_payment sp " +
                "JOIN employee e ON sp.emp_id = e.emp_id " +
                "WHERE sp.deleted = 0 AND e.deleted = 0 " +
                "GROUP BY e.department, sp.year, sp.month " +
                "HAVING SUM(sp.total_net_salary) > AVG(e.salary) * COUNT(DISTINCT sp.emp_id) * " + adjustedMultiplier + " " +
                "ORDER BY overrun_amount DESC";
        return jdbcTemplate.queryForList(sql);
    }

    public Map<String, Object> getCostOverrunOverview() {
        List<Map<String, Object>> rows = getCostOverrunAnalysis();
        Map<String, Object> result = new HashMap<>();
        double totalOverrun = rows.stream()
                .mapToDouble(r -> ((Number) r.get("overrun_amount")).doubleValue())
                .sum();
        result.put("overrunCount", rows.size());
        result.put("totalOverrunAmount", Math.round(totalOverrun * 100.0) / 100.0);
        result.put("highRiskDepartments", rows.stream()
                .limit(5)
                .map(r -> r.get("department"))
                .toArray());
        return result;
    }
}
