package com.hr.datacenter.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.PerformanceGoal;
import com.hr.datacenter.service.PerformanceGoalService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 绩效目标Controller
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/performance/goal")
@CrossOrigin(origins = "*")
public class PerformanceGoalController {

    private static final Logger log = LoggerFactory.getLogger(PerformanceGoalController.class);

    @Autowired
    private PerformanceGoalService performanceGoalService;

    /**
     * 分页查询绩效目标
     */
    @GetMapping("/page")
    public Result<IPage<PerformanceGoal>> getGoalPage(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long empId,
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) Integer periodType) {
        try {
            IPage<PerformanceGoal> result = performanceGoalService.getGoalPage(page, size, empId, year, periodType);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("查询绩效目标失败: {}", e.getMessage());
            return Result.error("查询绩效目标失败");
        }
    }

    /**
     * 新增绩效目标
     */
    @PostMapping("/add")
    public Result<String> addGoal(@RequestBody PerformanceGoal goal) {
        try {
            boolean success = performanceGoalService.addGoal(goal);
            if (success) {
                return Result.success("添加成功", "");
            }
            return Result.error("添加失败");
        } catch (Exception e) {
            log.error("添加绩效目标失败: {}", e.getMessage());
            return Result.error("添加绩效目标失败");
        }
    }

    /**
     * 更新绩效目标
     */
    @PostMapping("/update")
    public Result<String> updateGoal(@RequestBody PerformanceGoal goal) {
        try {
            boolean success = performanceGoalService.updateGoal(goal);
            if (success) {
                return Result.success("更新成功", "");
            }
            return Result.error("更新失败");
        } catch (Exception e) {
            log.error("更新绩效目标失败: {}", e.getMessage());
            return Result.error("更新绩效目标失败");
        }
    }

    /**
     * 删除绩效目标
     */
    @PostMapping("/delete/{goalId}")
    public Result<String> deleteGoal(@PathVariable Long goalId) {
        try {
            boolean success = performanceGoalService.deleteGoal(goalId);
            if (success) {
                return Result.success("删除成功", "");
            }
            return Result.error("删除失败");
        } catch (Exception e) {
            log.error("删除绩效目标失败: {}", e.getMessage());
            return Result.error("删除绩效目标失败");
        }
    }

    /**
     * 获取员工绩效目标
     */
    @GetMapping("/employee")
    public Result<java.util.List<PerformanceGoal>> getEmployeeGoals(
            @RequestParam Long empId,
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) Integer periodType) {
        try {
            java.util.List<PerformanceGoal> result = performanceGoalService.getEmployeeGoals(empId, year, periodType);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("查询员工绩效目标失败: {}", e.getMessage());
            return Result.error("查询员工绩效目标失败");
        }
    }
}
