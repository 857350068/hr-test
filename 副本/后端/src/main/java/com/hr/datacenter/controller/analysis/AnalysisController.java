package com.hr.datacenter.controller.analysis;

import com.hr.datacenter.common.Result;
import com.hr.datacenter.service.analysis.OrgEfficiencyAnalysisService;
import com.hr.datacenter.service.analysis.SalaryAnalysisService;
import com.hr.datacenter.service.analysis.TalentPipelineAnalysisService;
import com.hr.datacenter.service.warning.TalentGapWarningService;
import com.hr.datacenter.service.warning.TurnoverWarningService;
import com.hr.datacenter.util.CsvExportUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 数据分析控制器
 * 提供各类数据分析接口
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@RestController
@RequestMapping("/analysis")
@CrossOrigin(origins = "*")
public class AnalysisController {

    @Autowired
    private OrgEfficiencyAnalysisService orgEfficiencyService;

    @Autowired
    private TalentPipelineAnalysisService talentPipelineService;

    @Autowired
    private SalaryAnalysisService salaryService;

    @Autowired
    private TurnoverWarningService turnoverWarningService;

    @Autowired
    private TalentGapWarningService talentGapWarningService;

    // ==================== 组织效能分析 ====================

    /**
     * 获取部门效能分析
     */
    @GetMapping("/org-efficiency/department")
    public Result<List<Map<String, Object>>> getDepartmentEfficiency(
            @RequestParam(required = false) String department) {
        log.info("获取部门效能分析，部门：{}", department);
        List<Map<String, Object>> data = orgEfficiencyService.getDepartmentEfficiency(department);
        return Result.success(data);
    }

    /**
     * 获取组织架构分析
     */
    @GetMapping("/org-efficiency/structure")
    public Result<Map<String, Object>> getOrganizationStructure() {
        log.info("获取组织架构分析");
        Map<String, Object> data = orgEfficiencyService.getOrganizationStructure();
        return Result.success(data);
    }

    /**
     * 获取人员配置分析
     */
    @GetMapping("/org-efficiency/staffing")
    public Result<List<Map<String, Object>>> getStaffingAnalysis() {
        log.info("获取人员配置分析");
        List<Map<String, Object>> data = orgEfficiencyService.getStaffingAnalysis();
        return Result.success(data);
    }

    /**
     * 获取组织健康度
     */
    @GetMapping("/org-efficiency/health")
    public Result<Map<String, Object>> getOrganizationHealth() {
        log.info("获取组织健康度");
        Map<String, Object> data = orgEfficiencyService.getOrganizationHealth();
        return Result.success(data);
    }

    // ==================== 人才梯队分析 ====================

    /**
     * 获取人才储备分析
     */
    @GetMapping("/talent-pipeline/reserve")
    public Result<List<Map<String, Object>>> getTalentReserve(
            @RequestParam(required = false) String department) {
        log.info("获取人才储备分析，部门：{}", department);
        List<Map<String, Object>> data = talentPipelineService.getTalentReserve(department);
        return Result.success(data);
    }

    /**
     * 获取继任计划分析
     */
    @GetMapping("/talent-pipeline/succession")
    public Result<List<Map<String, Object>>> getSuccessionPlan() {
        log.info("获取继任计划分析");
        List<Map<String, Object>> data = talentPipelineService.getSuccessionPlan();
        return Result.success(data);
    }

    /**
     * 获取能力评估分析
     */
    @GetMapping("/talent-pipeline/capability")
    public Result<Map<String, Object>> getCapabilityAssessment() {
        log.info("获取能力评估分析");
        Map<String, Object> data = talentPipelineService.getCapabilityAssessment();
        return Result.success(data);
    }

    /**
     * 获取人才梯队健康度
     */
    @GetMapping("/talent-pipeline/health")
    public Result<Map<String, Object>> getTalentPipelineHealth() {
        log.info("获取人才梯队健康度");
        Map<String, Object> data = talentPipelineService.getTalentPipelineHealth();
        return Result.success(data);
    }

    // ==================== 薪酬福利分析 ====================

    /**
     * 获取薪酬结构分析
     */
    @GetMapping("/salary/structure")
    public Result<Map<String, Object>> getSalaryStructure() {
        log.info("获取薪酬结构分析");
        Map<String, Object> data = salaryService.getSalaryStructure();
        return Result.success(data);
    }

    /**
     * 获取薪酬竞争力分析
     */
    @GetMapping("/salary/competitiveness")
    public Result<Map<String, Object>> getSalaryCompetitiveness() {
        log.info("获取薪酬竞争力分析");
        Map<String, Object> data = salaryService.getSalaryCompetitiveness();
        return Result.success(data);
    }

    /**
     * 获取人力成本分析
     */
    @GetMapping("/salary/cost")
    public Result<Map<String, Object>> getLaborCostAnalysis() {
        log.info("获取人力成本分析");
        Map<String, Object> data = salaryService.getLaborCostAnalysis();
        return Result.success(data);
    }

    /**
     * 获取薪酬优化建议
     */
    @GetMapping("/salary/optimization")
    public Result<List<Map<String, Object>>> getSalaryOptimization() {
        log.info("获取薪酬优化建议");
        List<Map<String, Object>> data = salaryService.getSalaryOptimization();
        return Result.success(data);
    }

    /**
     * 分析模块筛选导出（统一导出入口）
     */
    @GetMapping("/export")
    public ResponseEntity<byte[]> exportAnalysis(
            @RequestParam String module,
            @RequestParam(required = false) String department,
            @RequestParam(required = false) String position,
            @RequestParam(required = false) String period,
            @RequestParam(required = false) String empNo) {
        String normalizedModule = StringUtils.hasText(module) ? module.trim() : "dashboard";
        List<Map<String, Object>> rows;
        switch (normalizedModule) {
            case "dashboard":
                rows = buildDashboardRows(department, position, period, empNo);
                break;
            case "warning":
                rows = buildWarningRows(department, position, empNo);
                break;
            case "org-efficiency":
                rows = orgEfficiencyService.getDepartmentEfficiency(department);
                break;
            case "talent-pipeline":
                rows = talentPipelineService.getTalentReserve(department);
                break;
            case "salary":
                rows = toRows(salaryService.getSalaryStructure().get("departmentSalary"));
                break;
            default:
                rows = new ArrayList<>();
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("message", "不支持的导出模块: " + normalizedModule);
                rows.add(row);
                break;
        }
        String csv = CsvExportUtil.toCsv(rows);
        String filename = CsvExportUtil.buildFileName("analysis_" + normalizedModule);
        return CsvExportUtil.buildCsvResponse(filename, csv);
    }

    private List<Map<String, Object>> buildDashboardRows(String department, String position, String period, String empNo) {
        Map<String, Object> orgHealth = orgEfficiencyService.getOrganizationHealth();
        Map<String, Object> turnover = turnoverWarningService.getTurnoverWarningOverview();
        Map<String, Object> gap = talentGapWarningService.getTalentGapWarningOverview();
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("筛选_部门", defaultText(department));
        row.put("筛选_岗位", defaultText(position));
        row.put("筛选_周期", defaultText(period));
        row.put("筛选_员工编号", defaultText(empNo));
        row.put("组织健康度", orgHealth.get("healthScore"));
        row.put("员工稳定性", orgHealth.get("stabilityRate"));
        row.put("流失率", orgHealth.get("turnoverRate"));
        row.put("高学历比例", orgHealth.get("highEducationRate"));
        row.put("流失高风险人数", turnover.get("highRiskCount"));
        row.put("流失中风险人数", turnover.get("mediumRiskCount"));
        row.put("人才缺口岗位数", gap.get("totalGapPositions"));
        row.put("人才总缺口人数", gap.get("totalGapCount"));
        row.put("紧急缺口数", gap.get("urgentGapCount"));
        return CsvExportUtil.singleRow(row);
    }

    private List<Map<String, Object>> buildWarningRows(String department, String position, String empNo) {
        List<Map<String, Object>> source = turnoverWarningService.getTurnoverRiskAnalysis();
        List<Map<String, Object>> filtered = new ArrayList<>();
        for (Map<String, Object> row : source) {
            String dep = val(row, "department");
            String pos = val(row, "position");
            String no = val(row, "emp_no");
            if (match(dep, department) && match(pos, position) && match(no, empNo)) {
                filtered.add(row);
            }
        }
        return filtered;
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> toRows(Object data) {
        if (data instanceof List) {
            return (List<Map<String, Object>>) data;
        }
        return new ArrayList<>();
    }

    private boolean match(String value, String keyword) {
        if (!StringUtils.hasText(keyword)) {
            return true;
        }
        return value != null && value.contains(keyword);
    }

    private String val(Map<String, Object> row, String key) {
        Object value = row.get(key);
        return value == null ? "" : String.valueOf(value);
    }

    private String defaultText(String text) {
        return StringUtils.hasText(text) ? text : "全部";
    }
}
