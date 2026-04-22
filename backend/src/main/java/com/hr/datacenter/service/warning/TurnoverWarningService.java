package com.hr.datacenter.service.warning;

import com.hr.datacenter.service.AnalysisRuleService;
import com.hr.datacenter.service.WarningModelService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import javax.sql.DataSource;
import java.util.*;

/**
 * 员工流失预警服务
 * 提供员工流失风险预测和预警功能
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class TurnoverWarningService {

    @Autowired
    @Qualifier("hiveDataSource")
    private DataSource hiveDataSource;
    @Autowired
    private AnalysisRuleService analysisRuleService;
    @Autowired
    private WarningModelService warningModelService;

    /**
     * 获取员工流失风险分析
     * @return 流失风险员工列表
     */
    public List<Map<String, Object>> getTurnoverRiskAnalysis() {
        return getTurnoverRiskAnalysis(null, null, null);
    }

    public List<Map<String, Object>> getTurnoverRiskAnalysis(String department, String position, String empNo) {
        log.info("开始分析员工流失风险");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        String latestDt = getLatestDt(hiveJdbc);
        
        List<Map<String, Object>> result = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        String filterClause = buildEmployeeFilterClause(latestDt, department, position, empNo, params);
        
        // 查询所有在职员工
        String sql = "SELECT emp_id, emp_no, emp_name, department, position, " +
                "current_salary as salary, hire_date, education, DATEDIFF(CURRENT_DATE, hire_date) as tenure_days " +
                "FROM dim_employee " + filterClause + "AND status = 1";
        List<Map<String, Object>> employees = hiveJdbc.queryForList(sql, params.toArray());
        
        for (Map<String, Object> emp : employees) {
            double riskScore = calculateTurnoverRisk(emp);
            
            if (riskScore >= getMediumRiskThreshold()) {
                Map<String, Object> riskEmp = new HashMap<>(emp);
                riskEmp.put("riskScore", Math.round(riskScore * 100.0) / 100.0);
                riskEmp.put("riskLevel", getRiskLevel(riskScore));
                riskEmp.put("riskFactors", getRiskFactors(emp, riskScore));
                result.add(riskEmp);
            }
        }
        
        // 按风险分数排序
        result.sort((a, b) -> Double.compare((Double) b.get("riskScore"), (Double) a.get("riskScore")));
        
        log.info("员工流失风险分析完成，共识别{}名风险员工", result.size());
        return result;
    }

    /**
     * 获取部门流失率统计
     * @return 部门流失率数据
     */
    public List<Map<String, Object>> getDepartmentTurnoverRate() {
        log.info("开始统计部门流失率");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        String latestDt = getLatestDt(hiveJdbc);
        
        String sql = "SELECT department, " +
                "COUNT(*) as total_count, " +
                "COUNT(CASE WHEN resign_date IS NOT NULL THEN 1 END) as resigned_count, " +
                "COUNT(CASE WHEN resign_date IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) as turnover_rate " +
                "FROM dim_employee " +
                buildLatestDtWhereClause(latestDt) +
                "GROUP BY department " +
                "ORDER BY turnover_rate DESC";
        
        List<Map<String, Object>> result = queryForListWithLatestDt(hiveJdbc, sql, latestDt);
        log.info("部门流失率统计完成，共{}个部门", result.size());
        
        return result;
    }

    /**
     * 获取流失预警概览
     * @return 预警概览数据
     */
    public Map<String, Object> getTurnoverWarningOverview() {
        return getTurnoverWarningOverview(null, null, null, null);
    }

    public Map<String, Object> getTurnoverWarningOverview(String department, String position, String empNo, String period) {
        log.info("开始生成流失预警概览");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        String latestDt = getLatestDt(hiveJdbc);
        
        Map<String, Object> result = new HashMap<>();
        List<Object> baseParams = new ArrayList<>();
        String whereClause = buildEmployeeFilterClause(latestDt, department, position, empNo, baseParams);
        List<Object> turnoverParams = new ArrayList<>(baseParams);
        String periodFilter = appendTurnoverPeriodFilter(turnoverParams, period);
        
        // 整体流失率
        String overallSql = "SELECT " +
                "COUNT(CASE WHEN resign_date IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) as turnover_rate " +
                "FROM dim_employee " + whereClause + periodFilter;
        Double turnoverRate = queryForObjectWithParams(hiveJdbc, overallSql, turnoverParams);
        result.put("overallTurnoverRate", turnoverRate);
        
        // 风险员工统计
        List<Map<String, Object>> riskEmployees = getTurnoverRiskAnalysis(department, position, empNo);
        long highRiskCount = riskEmployees.stream()
                .filter(e -> "高".equals(e.get("riskLevel")))
                .count();
        long mediumRiskCount = riskEmployees.stream()
                .filter(e -> "中".equals(e.get("riskLevel")))
                .count();
        
        result.put("highRiskCount", highRiskCount);
        result.put("mediumRiskCount", mediumRiskCount);
        result.put("totalRiskCount", riskEmployees.size());
        
        // 近期离职趋势
        String trendSql = "SELECT YEAR(resign_date) as year, MONTH(resign_date) as month, " +
                "COUNT(*) as resign_count " +
                "FROM dim_employee " +
                whereClause +
                "AND resign_date IS NOT NULL " +
                "GROUP BY YEAR(resign_date), MONTH(resign_date) " +
                "ORDER BY year DESC, month DESC " +
                "LIMIT 6";
        List<Map<String, Object>> trend = hiveJdbc.queryForList(trendSql, baseParams.toArray());
        result.put("turnoverTrend", trend);
        
        log.info("流失预警概览生成完成");
        return result;
    }

    /**
     * 计算员工流失风险分数
     */
    private double calculateTurnoverRisk(Map<String, Object> emp) {
        double score = 0.0;
        
        // 1. 工龄因素（权重30%）
        Map<String, Double> weights = warningModelService.getFeatureWeights("turnover");
        double tenureWeight = getWeight(weights, "tenure", 0.30);
        double salaryWeight = getWeight(weights, "salary", 0.25);
        double educationWeight = getWeight(weights, "education", 0.20);
        double positionWeight = getWeight(weights, "position", 0.15);
        double departmentWeight = getWeight(weights, "department", 0.10);

        Integer tenureDays = asInt(emp.get("tenure_days"));
        if (tenureDays != null) {
            if (tenureDays < 180) { // 入职不到半年
                score += tenureWeight;
            } else if (tenureDays < 365) { // 入职不到一年
                score += tenureWeight * 0.67;
            } else if (tenureDays > 1095 && tenureDays < 1825) { // 3-5年（容易跳槽期）
                score += tenureWeight * 0.5;
            }
        }
        
        // 2. 薪资因素（权重25%）
        Double salary = asDouble(emp.get("salary"));
        if (salary != null) {
            // 假设平均薪资为10000
            if (salary < 8000) { // 薪资偏低
                score += salaryWeight;
            } else if (salary < 10000) {
                score += salaryWeight * 0.6;
            }
        }
        
        // 3. 学历因素（权重20%）
        String education = (String) emp.get("education");
        if ("本科".equals(education) || "硕士".equals(education) || "博士".equals(education)) {
            score += educationWeight; // 高学历更容易跳槽
        }
        
        // 4. 岗位因素（权重15%）
        String position = (String) emp.get("position");
        if (position != null && (position.contains("工程师") || position.contains("开发"))) {
            score += positionWeight; // 技术岗位流动性较高
        }
        
        // 5. 部门因素（权重10%）
        String department = (String) emp.get("department");
        if (department != null && (department.contains("研发") || department.contains("技术"))) {
            score += departmentWeight; // 技术部门流动性较高
        }
        
        return Math.min(1.0, score);
    }

    /**
     * 获取风险等级
     */
    private String getRiskLevel(double riskScore) {
        if (riskScore >= getHighRiskThreshold()) {
            return "高";
        } else if (riskScore >= getMediumRiskThreshold()) {
            return "中";
        } else {
            return "低";
        }
    }

    /**
     * 获取风险因素说明
     */
    private List<String> getRiskFactors(Map<String, Object> emp, double riskScore) {
        List<String> factors = new ArrayList<>();
        
        Integer tenureDays = asInt(emp.get("tenure_days"));
        if (tenureDays != null && tenureDays < 365) {
            factors.add("入职时间较短（<1年）");
        }
        
        Double salary = asDouble(emp.get("salary"));
        if (salary != null && salary < 10000) {
            factors.add("薪资水平偏低");
        }
        
        String education = (String) emp.get("education");
        if ("本科".equals(education) || "硕士".equals(education) || "博士".equals(education)) {
            factors.add("高学历人才（跳槽倾向高）");
        }
        
        String position = (String) emp.get("position");
        if (position != null && position.contains("工程师")) {
            factors.add("技术岗位（流动性高）");
        }
        
        return factors;
    }

    private double getHighRiskThreshold() {
        return analysisRuleService.getDoubleRule("turnover", "turnover.highRiskThreshold", 0.70);
    }

    private double getMediumRiskThreshold() {
        return analysisRuleService.getDoubleRule("turnover", "turnover.mediumRiskThreshold", 0.40);
    }

    private double getWeight(Map<String, Double> weights, String key, double defaultValue) {
        return weights.getOrDefault(key, defaultValue);
    }

    private Integer asInt(Object value) {
        return value instanceof Number ? ((Number) value).intValue() : null;
    }

    private Double asDouble(Object value) {
        return value instanceof Number ? ((Number) value).doubleValue() : null;
    }

    private String getLatestDt(JdbcTemplate hiveJdbc) {
        try {
            return hiveJdbc.queryForObject("SELECT MAX(dt) FROM dim_employee", String.class);
        } catch (Exception ex) {
            log.warn("获取dim_employee最新分区失败，改为全表查询", ex);
            return null;
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
