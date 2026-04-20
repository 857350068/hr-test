package com.hr.datacenter.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.SalaryAdjustment;
import com.hr.datacenter.service.SalaryAdjustmentService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 薪资调整Controller
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/salary/adjustment")
@CrossOrigin(origins = "*")
public class SalaryAdjustmentController {

    private static final Logger log = LoggerFactory.getLogger(SalaryAdjustmentController.class);

    @Autowired
    private SalaryAdjustmentService salaryAdjustmentService;

    /**
     * 分页查询薪资调整
     */
    @GetMapping("/page")
    public Result<IPage<SalaryAdjustment>> getAdjustmentPage(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long empId,
            @RequestParam(required = false) Integer approvalStatus) {
        try {
            IPage<SalaryAdjustment> result = salaryAdjustmentService.getAdjustmentPage(page, size, empId, approvalStatus);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("查询薪资调整失败: {}", e.getMessage());
            return Result.error("查询薪资调整失败");
        }
    }

    /**
     * 申请薪资调整
     */
    @PostMapping("/apply")
    public Result<String> applyAdjustment(@RequestBody SalaryAdjustment adjustment) {
        try {
            boolean success = salaryAdjustmentService.applyAdjustment(adjustment);
            if (success) {
                return Result.success("申请成功", "");
            }
            return Result.error("申请失败");
        } catch (Exception e) {
            log.error("申请薪资调整失败: {}", e.getMessage());
            return Result.error("申请薪资调整失败");
        }
    }

    /**
     * 审批薪资调整
     */
    @PostMapping("/approve")
    public Result<String> approveAdjustment(
            @RequestParam Long adjustmentId,
            @RequestParam Long approverId,
            @RequestParam Integer approvalStatus,
            @RequestParam(required = false) String approvalComment) {
        try {
            boolean success = salaryAdjustmentService.approveAdjustment(adjustmentId, approverId, approvalStatus, approvalComment);
            if (success) {
                return Result.success("审批成功", "");
            }
            return Result.error("审批失败");
        } catch (Exception e) {
            log.error("审批薪资调整失败: {}", e.getMessage());
            return Result.error("审批薪资调整失败");
        }
    }

    /**
     * 获取待审批列表
     */
    @GetMapping("/pending")
    public Result<IPage<SalaryAdjustment>> getPendingApprovalList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        try {
            IPage<SalaryAdjustment> result = salaryAdjustmentService.getPendingApprovalList(page, size);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("查询待审批列表失败: {}", e.getMessage());
            return Result.error("查询待审批列表失败");
        }
    }
}
