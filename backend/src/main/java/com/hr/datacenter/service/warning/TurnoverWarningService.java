package com.hr.datacenter.service.warning;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

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

    // 预警阈值配置
    private static final double HIGH_RISK_THRESHOLD = 0.7;  // 高风险阈值
    private static final double MEDIUM_RISK_THRESHOLD = 0.4; // 中风险阈值

    /**
     * 获取员工流失风险分析
     * @return 流失风险员工列表
     */
    public List<Map<String, Object>> getTurnoverRiskAnalysis() {
        log.info("开始分析员工流失风险");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        
        List<Map<String, Object>> result = new ArrayList<>();
        
        // 查询所有在职员工
        String sql = "SELECT emp_id, emp_no, emp_name, department, position, " +
                "salary, hire_date, education, DATEDIFF(CURRENT_DATE, hire_date) as tenure_days " +
                "FROM dim_employee WHERE status = 1";
        List<Map<String, Object>> employees = hiveJdbc.queryForList(sql);
        
        for (Map<String, Object> emp : employees) {
            double riskScore = calculateTurnoverRisk(emp);
            
            if (riskScore >= MEDIUM_RISK_THRESHOLD) {
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
        
        String sql = "SELECT department, " +
                "COUNT(*) as total_count, " +
                "COUNT(CASE WHEN resign_date IS NOT NULL AND resign_date != '' THEN 1 END) as resigned_count, " +
                "COUNT(CASE WHEN resign_date IS NOT NULL AND resign_date != '' THEN 1 END) * 100.0 / COUNT(*) as turnover_rate " +
                "FROM dim_employee " +
                "GROUP BY department " +
                "ORDER BY turnover_rate DESC";
        
        List<Map<String, Object>> result = hiveJdbc.queryForList(sql);
        log.info("部门流失率统计完成，共{}个部门", result.size());
        
        return result;
    }

    /**
     * 获取流失预警概览
     * @return 预警概览数据
     */
    public Map<String, Object> getTurnoverWarningOverview() {
        log.info("开始生成流失预警概览");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        
        Map<String, Object> result = new HashMap<>();
        
        // 整体流失率
        String overallSql = "SELECT " +
                "COUNT(CASE WHEN resign_date IS NOT NULL AND resign_date != '' THEN 1 END) * 100.0 / COUNT(*) as turnover_rate " +
                "FROM dim_employee";
        Double turnoverRate = hiveJdbc.queryForObject(overallSql, Double.class);
        result.put("overallTurnoverRate", turnoverRate);
        
        // 风险员工统计
        List<Map<String, Object>> riskEmployees = getTurnoverRiskAnalysis();
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
                "WHERE resign_date IS NOT NULL AND resign_date != '' " +
                "GROUP BY YEAR(resign_date), MONTH(resign_date) " +
                "ORDER BY year DESC, month DESC " +
                "LIMIT 6";
        List<Map<String, Object>> trend = hiveJdbc.queryForList(trendSql);
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
        Integer tenureDays = (Integer) emp.get("tenure_days");
        if (tenureDays != null) {
            if (tenureDays < 180) { // 入职不到半年
                score += 0.3;
            } else if (tenureDays < 365) { // 入职不到一年
                score += 0.2;
            } else if (tenureDays > 1095 && tenureDays < 1825) { // 3-5年（容易跳槽期）
                score += 0.15;
            }
        }
        
        // 2. 薪资因素（权重25%）
        Double salary = (Double) emp.get("salary");
        if (salary != null) {
            // 假设平均薪资为10000
            if (salary < 8000) { // 薪资偏低
                score += 0.25;
            } else if (salary < 10000) {
                score += 0.15;
            }
        }
        
        // 3. 学历因素（权重20%）
        String education = (String) emp.get("education");
        if ("本科".equals(education) || "硕士".equals(education) || "博士".equals(education)) {
            score += 0.2; // 高学历更容易跳槽
        }
        
        // 4. 岗位因素（权重15%）
        String position = (String) emp.get("position");
        if (position != null && (position.contains("工程师") || position.contains("开发"))) {
            score += 0.15; // 技术岗位流动性较高
        }
        
        // 5. 部门因素（权重10%）
        String department = (String) emp.get("department");
        if (department != null && (department.contains("研发") || department.contains("技术"))) {
            score += 0.1; // 技术部门流动性较高
        }
        
        return score;
    }

    /**
     * 获取风险等级
     */
    private String getRiskLevel(double riskScore) {
        if (riskScore >= HIGH_RISK_THRESHOLD) {
            return "高";
        } else if (riskScore >= MEDIUM_RISK_THRESHOLD) {
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
        
        Integer tenureDays = (Integer) emp.get("tenure_days");
        if (tenureDays != null && tenureDays < 365) {
            factors.add("入职时间较短（<1年）");
        }
        
        Double salary = (Double) emp.get("salary");
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
}
