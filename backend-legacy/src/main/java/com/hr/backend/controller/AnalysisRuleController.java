package com.hr.backend.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hr.backend.common.Response;
import com.hr.backend.model.dto.AnalysisRuleDTO;
import com.hr.backend.model.dto.AnalysisRuleQueryDTO;
import com.hr.backend.model.dto.AnalysisRuleVO;
import com.hr.backend.service.AnalysisRuleService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

/**
 * 分析规则管理控制器
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Slf4j
@Api(tags = "分析规则管理")
@RestController
@RequestMapping("/api/analysis-rules")
public class AnalysisRuleController {

    private final AnalysisRuleService analysisRuleService;

    public AnalysisRuleController(AnalysisRuleService analysisRuleService) {
        this.analysisRuleService = analysisRuleService;
    }

    /**
     * 创建分析规则
     */
    @ApiOperation("创建分析规则")
    @PostMapping
    @PreAuthorize("hasRole('HR_ADMIN')")
    public Response<String> createRule(@Valid @RequestBody AnalysisRuleDTO dto) {
        String ruleId = analysisRuleService.createRule(dto);
        return Response.success(ruleId);
    }

    /**
     * 更新分析规则
     */
    @ApiOperation("更新分析规则")
    @PutMapping("/{ruleId}")
    @PreAuthorize("hasRole('HR_ADMIN')")
    public Response<Void> updateRule(@PathVariable String ruleId, @Valid @RequestBody AnalysisRuleDTO dto) {
        analysisRuleService.updateRule(ruleId, dto);
        return Response.success();
    }

    /**
     * 删除分析规则
     */
    @ApiOperation("删除分析规则")
    @DeleteMapping("/{ruleId}")
    @PreAuthorize("hasRole('HR_ADMIN')")
    public Response<Void> deleteRule(@PathVariable String ruleId) {
        analysisRuleService.deleteRule(ruleId);
        return Response.success();
    }

    /**
     * 查询分析规则
     */
    @ApiOperation("查询分析规则")
    @GetMapping("/{ruleId}")
    @PreAuthorize("hasAnyRole('HR_ADMIN', 'DEPT_HEAD', 'MANAGEMENT')")
    public Response<AnalysisRuleVO> getRule(@PathVariable String ruleId) {
        AnalysisRuleVO vo = analysisRuleService.getRule(ruleId);
        return Response.success(vo);
    }

    /**
     * 分页查询分析规则
     */
    @ApiOperation("分页查询分析规则")
    @GetMapping
    @PreAuthorize("hasAnyRole('HR_ADMIN', 'DEPT_HEAD', 'MANAGEMENT')")
    public Response<Page<AnalysisRuleVO>> queryRules(AnalysisRuleQueryDTO query) {
        Page<AnalysisRuleVO> page = analysisRuleService.queryRules(query);
        return Response.success(page);
    }

    /**
     * 切换规则生效状态
     */
    @ApiOperation("切换规则生效状态")
    @PutMapping("/{ruleId}/status")
    @PreAuthorize("hasRole('HR_ADMIN')")
    public Response<Void> toggleRuleStatus(@PathVariable String ruleId, @RequestParam Boolean active) {
        analysisRuleService.toggleRuleStatus(ruleId, active);
        return Response.success();
    }
}
