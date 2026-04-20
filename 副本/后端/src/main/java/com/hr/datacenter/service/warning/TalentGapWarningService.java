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
 * 人才缺口预警服务
 * 提供人才缺口识别和预警功能
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class TalentGapWarningService {

    @Autowired
    @Qualifier("hiveDataSource")
    private DataSource hiveDataSource;
    @Autowired
    private AnalysisRuleService analysisRuleService;
    @Autowired
    private WarningModelService warningModelService;

    /**
     * 获取人才缺口分析
     * @return 人才缺口数据
     */
    public List<Map<String, Object>> getTalentGapAnalysis() {
        log.info("开始分析人才缺口");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        String latestDt = getLatestDt(hiveJdbc);
        
        List<Map<String, Object>> result = new ArrayList<>();
        
        // 按部门和岗位统计人数
        String sql = "SELECT department, position, COUNT(*) as current_count " +
                "FROM dim_employee " + buildLatestDtWhereClause(latestDt) + "AND status = 1 " +
                "GROUP BY department, position";
        List<Map<String, Object>> positionStats = queryForListWithLatestDt(hiveJdbc, sql, latestDt);
        
        for (Map<String, Object> stat : positionStats) {
            String department = (String) stat.get("department");
            String position = (String) stat.get("position");
            long currentCount = asLong(stat.get("current_count"));
            
            // 计算期望人数（基于业务规则）
            int expectedCount = calculateExpectedCount(department, position);
            
            if (currentCount < expectedCount) {
                Map<String, Object> gap = new HashMap<>();
                gap.put("department", department);
                gap.put("position", position);
                gap.put("currentCount", currentCount);
                gap.put("expectedCount", expectedCount);
                gap.put("gapCount", expectedCount - currentCount);
                gap.put("gapRate", (expectedCount - currentCount) * 100.0 / expectedCount);
                gap.put("urgency", getUrgencyLevel(expectedCount - currentCount, expectedCount));
                gap.put("suggestion", getRecruitmentSuggestion(position, expectedCount - currentCount));
                result.add(gap);
            }
        }
        
        // 按缺口数量排序
        result.sort((a, b) -> Long.compare(asLong(b.get("gapCount")), asLong(a.get("gapCount"))));
        
        log.info("人才缺口分析完成，共识别{}个缺口岗位", result.size());
        return result;
    }

    /**
     * 获取部门人才结构分析
     * @return 部门人才结构数据
     */
    public List<Map<String, Object>> getDepartmentStructureAnalysis() {
        log.info("开始分析部门人才结构");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        String latestDt = getLatestDt(hiveJdbc);
        
        String sql = "SELECT department, " +
                "COUNT(*) as total_count, " +
                "COUNT(CASE WHEN position LIKE '%经理%' OR position LIKE '%总监%' THEN 1 END) as manager_count, " +
                "COUNT(CASE WHEN position LIKE '%工程师%' OR position LIKE '%开发%' THEN 1 END) as tech_count, " +
                "COUNT(CASE WHEN education IN ('本科', '硕士', '博士') THEN 1 END) as high_edu_count " +
                "FROM dim_employee " + buildLatestDtWhereClause(latestDt) + "AND status = 1 " +
                "GROUP BY department " +
                "ORDER BY total_count DESC";
        
        List<Map<String, Object>> result = queryForListWithLatestDt(hiveJdbc, sql, latestDt);
        
        // 计算结构健康度
        for (Map<String, Object> dept : result) {
            long totalCount = asLong(dept.get("total_count"));
            long managerCount = asLong(dept.get("manager_count"));
            
            // 管理幅度（每个管理者管理的员工数）
            double managementSpan = managerCount > 0 ? (totalCount - managerCount) * 1.0 / managerCount : 0;
            dept.put("managementSpan", Math.round(managementSpan * 100.0) / 100.0);
            
            // 结构健康度评估
            String healthStatus = evaluateStructureHealth(managementSpan, totalCount);
            dept.put("healthStatus", healthStatus);
        }
        
        log.info("部门人才结构分析完成");
        return result;
    }

    /**
     * 获取人才缺口预警概览
     * @return 预警概览数据
     */
    public Map<String, Object> getTalentGapWarningOverview() {
        log.info("开始生成人才缺口预警概览");
        
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        String latestDt = getLatestDt(hiveJdbc);
        
        Map<String, Object> result = new HashMap<>();
        
        // 整体人才缺口统计
        List<Map<String, Object>> gaps = getTalentGapAnalysis();
        long totalGapCount = gaps.stream()
                .mapToLong(g -> asLong(g.get("gapCount")))
                .sum();
        
        result.put("totalGapPositions", gaps.size());
        result.put("totalGapCount", totalGapCount);
        
        // 紧急缺口统计
        long urgentCount = gaps.stream()
                .filter(g -> "紧急".equals(g.get("urgency")))
                .count();
        result.put("urgentGapCount", urgentCount);
        
        // 部门缺口分布
        Map<String, Long> deptGapDist = new HashMap<>();
        for (Map<String, Object> gap : gaps) {
            String dept = (String) gap.get("department");
            long gapCount = asLong(gap.get("gapCount"));
            deptGapDist.merge(dept, gapCount, Long::sum);
        }
        result.put("departmentGapDistribution", deptGapDist);
        
        // 人才储备率
        String reserveSql = "SELECT " +
                "COUNT(CASE WHEN education IN ('本科', '硕士', '博士') THEN 1 END) * 100.0 / COUNT(*) as reserve_rate " +
                "FROM dim_employee " + buildLatestDtWhereClause(latestDt) + "AND status = 1";
        Double reserveRate = queryForObjectWithLatestDt(hiveJdbc, reserveSql, latestDt);
        result.put("talentReserveRate", reserveRate);
        
        log.info("人才缺口预警概览生成完成");
        return result;
    }

    /**
     * 计算期望人数（基于业务规则）
     */
    private int calculateExpectedCount(String department, String position) {
        // 基硎期望人数
        int baseCount = analysisRuleService.getIntRule("talentGap", "talentGap.minTeamSize", 3);
        int techTeamSize = analysisRuleService.getIntRule("talentGap", "talentGap.techTeamSize", 8);
        Map<String, Double> weights = warningModelService.getFeatureWeights("talentGap");
        double deptWeight = weights.getOrDefault("department", 0.35);
        double positionWeight = weights.getOrDefault("position", 0.35);
        double structureWeight = weights.getOrDefault("structure", 0.30);
        
        // 根据部门调整
        if (department != null) {
            if (department.contains("研发") || department.contains("技术")) {
                baseCount = techTeamSize; // 技术部门需要更多人员
            } else if (department.contains("销售")) {
                baseCount = Math.max(baseCount, Math.max(4, (int) Math.round(10 * deptWeight / 0.35))); // 销售部门需要更多人员
            } else if (department.contains("人事") || department.contains("行政")) {
                baseCount = Math.max(baseCount, Math.max(3, (int) Math.round(5 * deptWeight / 0.35))); // 职能部门人员较少
            }
        }
        
        // 根据岗位调整
        if (position != null) {
            if (position.contains("经理") || position.contains("总监")) {
                baseCount = 1; // 管理岗位通常只需要1人
            } else if (position.contains("工程师") || position.contains("开发")) {
                baseCount = Math.max(baseCount, Math.max(3, (int) Math.round(5 * positionWeight / 0.35))); // 技术岗位至少5人
            }
        }

        return Math.max(1, (int) Math.round(baseCount * (1 + structureWeight * 0.1)));
    }

    /**
     * 获取紧急程度
     */
    private String getUrgencyLevel(long gapCount, int expectedCount) {
        double gapRate = gapCount * 1.0 / expectedCount;
        
        if (gapRate >= 0.5) {
            return "紧急";
        } else if (gapRate >= 0.3) {
            return "重要";
        } else {
            return "一般";
        }
    }

    /**
     * 获取招聘建议
     */
    private String getRecruitmentSuggestion(String position, long gapCount) {
        return String.format("建议招聘%d名%s", gapCount, position != null ? position : "员工");
    }

    /**
     * 评估结构健康度
     */
    private String evaluateStructureHealth(double managementSpan, long totalCount) {
        // 管理幅度理想范围：5-15人
        if (managementSpan >= 5 && managementSpan <= 15) {
            return "健康";
        } else if (managementSpan < 5) {
            return "管理层过多";
        } else {
            return "管理层不足";
        }
    }

    private long asLong(Object value) {
        return value instanceof Number ? ((Number) value).longValue() : 0L;
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

    private Double queryForObjectWithLatestDt(JdbcTemplate hiveJdbc, String sql, String latestDt) {
        return StringUtils.hasText(latestDt)
                ? hiveJdbc.queryForObject(sql, Double.class, latestDt)
                : hiveJdbc.queryForObject(sql, Double.class);
    }
}
