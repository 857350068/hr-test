package com.hr.datacenter.controller.analysis;

import com.hr.datacenter.common.Result;
import com.hr.datacenter.service.analysis.OrgEfficiencyAnalysisService;
import com.hr.datacenter.service.analysis.SalaryAnalysisService;
import com.hr.datacenter.service.analysis.TalentPipelineAnalysisService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

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
}
