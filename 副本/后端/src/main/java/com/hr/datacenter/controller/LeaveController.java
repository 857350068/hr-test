package com.hr.datacenter.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.Leave;
import com.hr.datacenter.service.LeaveService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 请假控制器
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/leave")
@CrossOrigin(origins = "*")
public class LeaveController {

    private static final Logger log = LoggerFactory.getLogger(LeaveController.class);

    @Autowired
    private LeaveService leaveService;

    /**
     * 申请请假
     */
    @PostMapping("/apply")
    public Result<String> applyLeave(@RequestBody Leave leave) {
        log.info("申请请假: empId={}", leave.getEmpId());
        try {
            leaveService.applyLeave(leave);
            return Result.success("申请成功", "");
        } catch (Exception e) {
            log.error("申请失败: {}", e.getMessage());
            return Result.error(e.getMessage());
        }
    }

    /**
     * 审批请假
     */
    @PostMapping("/approve")
    public Result<String> approveLeave(
            @RequestParam Long leaveId,
            @RequestParam Long approverId,
            @RequestParam Integer status,
            @RequestParam(required = false) String comment) {
        log.info("审批请假: leaveId={}, approverId={}, status={}", leaveId, approverId, status);
        try {
            leaveService.approveLeave(leaveId, approverId, status, comment);
            return Result.success("审批成功", "");
        } catch (Exception e) {
            log.error("审批失败: {}", e.getMessage());
            return Result.error(e.getMessage());
        }
    }

    /**
     * 撤回请假
     */
    @PostMapping("/withdraw")
    public Result<String> withdrawLeave(@RequestParam Long leaveId, @RequestParam Long empId) {
        log.info("撤回请假: leaveId={}, empId={}", leaveId, empId);
        try {
            leaveService.withdrawLeave(leaveId, empId);
            return Result.success("撤回成功", "");
        } catch (Exception e) {
            log.error("撤回失败: {}", e.getMessage());
            return Result.error(e.getMessage());
        }
    }

    /**
     * 分页查询请假记录
     */
    @GetMapping("/list")
    public Result<IPage<Leave>> getLeaveList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long empId,
            @RequestParam(required = false) Integer leaveType,
            @RequestParam(required = false) Integer approvalStatus) {
        log.info("查询请假列表: page={}, size={}, empId={}", page, size, empId);
        IPage<Leave> leavePage = leaveService.getLeavePage(page, size, empId, leaveType, approvalStatus);
        return Result.success(leavePage);
    }

    /**
     * 获取待审批列表
     */
    @GetMapping("/pending")
    public Result<IPage<Leave>> getPendingApprovalList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long approverId) {
        log.info("查询待审批列表: page={}, size={}", page, size);
        IPage<Leave> leavePage = leaveService.getPendingApprovalList(page, size, approverId);
        return Result.success(leavePage);
    }
}
