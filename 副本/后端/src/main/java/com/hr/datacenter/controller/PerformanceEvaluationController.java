package com.hr.datacenter.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.PerformanceEvaluation;
import com.hr.datacenter.service.PerformanceEvaluationService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 绩效评估Controller
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/performance/evaluation")
@CrossOrigin(origins = "*")
public class PerformanceEvaluationController {

    private static final Logger log = LoggerFactory.getLogger(PerformanceEvaluationController.class);

    @Autowired
    private PerformanceEvaluationService performanceEvaluationService;

    /**
     * 分页查询绩效评估
     */
    @GetMapping("/page")
    public Result<IPage<PerformanceEvaluation>> getEvaluationPage(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long empId,
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) Integer periodType) {
        try {
            IPage<PerformanceEvaluation> result = performanceEvaluationService.getEvaluationPage(page, size, empId, year, periodType);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("查询绩效评估失败: {}", e.getMessage());
            return Result.error("查询绩效评估失败");
        }
    }

    @GetMapping("/improvement/overview")
    public Result<Object> getImprovementOverview() {
        try {
            return Result.success("查询成功", performanceEvaluationService.getImprovementOverview());
        } catch (Exception e) {
            log.error("查询绩效改进概览失败: {}", e.getMessage());
            return Result.error("查询绩效改进概览失败");
        }
    }

    /**
     * 自评
     */
    @PostMapping("/self")
    public Result<String> selfEvaluate(@RequestBody PerformanceEvaluation evaluation) {
        try {
            boolean success = performanceEvaluationService.selfEvaluate(evaluation);
            if (success) {
                return Result.success("自评成功", "");
            }
            return Result.error("自评失败");
        } catch (Exception e) {
            log.error("自评失败: {}", e.getMessage());
            return Result.error("自评失败");
        }
    }

    /**
     * 上级评价
     */
    @PostMapping("/supervisor")
    public Result<String> supervisorEvaluate(@RequestBody PerformanceEvaluation evaluation) {
        try {
            boolean success = performanceEvaluationService.supervisorEvaluate(evaluation);
            if (success) {
                return Result.success("评价成功", "");
            }
            return Result.error("评价失败");
        } catch (Exception e) {
            log.error("评价失败: {}", e.getMessage());
            return Result.error("评价失败");
        }
    }

    /**
     * 更新面谈记录
     */
    @PostMapping("/interview")
    public Result<String> updateInterviewRecord(
            @RequestParam Long evaluationId,
            @RequestParam String interviewRecord,
            @RequestParam String interviewDate) {
        try {
            boolean success = performanceEvaluationService.updateInterviewRecord(
                evaluationId,
                interviewRecord,
                java.time.LocalDateTime.parse(interviewDate)
            );
            if (success) {
                return Result.success("更新成功", "");
            }
            return Result.error("更新失败");
        } catch (Exception e) {
            log.error("更新面谈记录失败: {}", e.getMessage());
            return Result.error("更新面谈记录失败");
        }
    }
}
