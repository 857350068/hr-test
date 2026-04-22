package com.hr.datacenter.controller.warning;

import com.hr.datacenter.common.Result;
import com.hr.datacenter.service.warning.CostWarningService;
import com.hr.datacenter.service.warning.TalentGapWarningService;
import com.hr.datacenter.service.warning.TurnoverWarningService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 预警管理控制器
 * 提供各类预警信息接口
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@RestController
@RequestMapping("/warning")
@CrossOrigin(origins = "*")
public class WarningController {

    @Autowired
    private TurnoverWarningService turnoverWarningService;

    @Autowired
    private TalentGapWarningService talentGapWarningService;

    @Autowired
    private CostWarningService costWarningService;

    // ==================== 员工流失预警 ====================

    /**
     * 获取员工流失风险分析
     */
    @GetMapping("/turnover/risk-analysis")
    public Result<List<Map<String, Object>>> getTurnoverRiskAnalysis() {
        log.info("获取员工流失风险分析");
        List<Map<String, Object>> data = turnoverWarningService.getTurnoverRiskAnalysis();
        return Result.success(data);
    }

    /**
     * 获取部门流失率统计
     */
    @GetMapping("/turnover/department-rate")
    public Result<List<Map<String, Object>>> getDepartmentTurnoverRate() {
        log.info("获取部门流失率统计");
        List<Map<String, Object>> data = turnoverWarningService.getDepartmentTurnoverRate();
        return Result.success(data);
    }

    /**
     * 获取流失预警概览
     */
    @GetMapping("/turnover/overview")
    public Result<Map<String, Object>> getTurnoverWarningOverview(
            @RequestParam(required = false) String department,
            @RequestParam(required = false) String position,
            @RequestParam(required = false) String period,
            @RequestParam(required = false) String empNo) {
        log.info("获取流失预警概览");
        Map<String, Object> data = turnoverWarningService.getTurnoverWarningOverview(department, position, empNo, period);
        return Result.success(data);
    }

    // ==================== 人才缺口预警 ====================

    /**
     * 获取人才缺口分析
     */
    @GetMapping("/talent-gap/analysis")
    public Result<List<Map<String, Object>>> getTalentGapAnalysis() {
        log.info("获取人才缺口分析");
        List<Map<String, Object>> data = talentGapWarningService.getTalentGapAnalysis();
        return Result.success(data);
    }

    /**
     * 获取部门人才结构分析
     */
    @GetMapping("/talent-gap/structure")
    public Result<List<Map<String, Object>>> getDepartmentStructureAnalysis() {
        log.info("获取部门人才结构分析");
        List<Map<String, Object>> data = talentGapWarningService.getDepartmentStructureAnalysis();
        return Result.success(data);
    }

    /**
     * 获取人才缺口预警概览
     */
    @GetMapping("/talent-gap/overview")
    public Result<Map<String, Object>> getTalentGapWarningOverview(
            @RequestParam(required = false) String department,
            @RequestParam(required = false) String position,
            @RequestParam(required = false) String period,
            @RequestParam(required = false) String empNo) {
        log.info("获取人才缺口预警概览");
        Map<String, Object> data = talentGapWarningService.getTalentGapWarningOverview(department, position, empNo, period);
        return Result.success(data);
    }

    @GetMapping("/cost/overrun-analysis")
    public Result<List<Map<String, Object>>> getCostOverrunAnalysis() {
        log.info("获取人力成本超支分析");
        return Result.success(costWarningService.getCostOverrunAnalysis());
    }

    @GetMapping("/cost/overview")
    public Result<Map<String, Object>> getCostOverview() {
        log.info("获取人力成本超支概览");
        return Result.success(costWarningService.getCostOverrunOverview());
    }
}
