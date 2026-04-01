package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.Leave;
import com.hr.datacenter.mapper.LeaveMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;

/**
 * 请假Service
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class LeaveService extends ServiceImpl<LeaveMapper, Leave> {

    /**
     * 申请请假
     */
    public boolean applyLeave(Leave leave) {
        // 计算请假时长(小时)
        if (leave.getStartTime() != null && leave.getEndTime() != null) {
            long hours = Duration.between(leave.getStartTime(), leave.getEndTime()).toHours();
            leave.setLeaveDuration((int) hours);
        }
        
        // 设置初始状态为待审批
        leave.setApprovalStatus(0);
        
        return this.save(leave);
    }

    /**
     * 审批请假
     */
    public boolean approveLeave(Long leaveId, Long approverId, Integer status, String comment) {
        Leave leave = this.getById(leaveId);
        if (leave == null) {
            throw new RuntimeException("请假记录不存在");
        }
        
        if (leave.getApprovalStatus() != 0) {
            throw new RuntimeException("该请假申请已处理");
        }
        
        leave.setApproverId(approverId);
        leave.setApprovalStatus(status); // 1-同意 2-拒绝
        leave.setApprovalComment(comment);
        leave.setApprovalTime(LocalDateTime.now());
        
        return this.updateById(leave);
    }

    /**
     * 撤回请假
     */
    public boolean withdrawLeave(Long leaveId, Long empId) {
        Leave leave = this.getById(leaveId);
        if (leave == null) {
            throw new RuntimeException("请假记录不存在");
        }
        
        if (!leave.getEmpId().equals(empId)) {
            throw new RuntimeException("只能撤回自己的请假申请");
        }
        
        if (leave.getApprovalStatus() != 0) {
            throw new RuntimeException("该请假申请已处理,无法撤回");
        }
        
        leave.setApprovalStatus(3); // 3-已撤回
        return this.updateById(leave);
    }

    /**
     * 分页查询请假记录
     */
    public IPage<Leave> getLeavePage(int page, int size, Long empId, Integer leaveType, Integer approvalStatus) {
        Page<Leave> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Leave> wrapper = new LambdaQueryWrapper<>();
        
        if (empId != null) {
            wrapper.eq(Leave::getEmpId, empId);
        }
        if (leaveType != null) {
            wrapper.eq(Leave::getLeaveType, leaveType);
        }
        if (approvalStatus != null) {
            wrapper.eq(Leave::getApprovalStatus, approvalStatus);
        }
        
        wrapper.orderByDesc(Leave::getCreateTime);
        return this.page(pageParam, wrapper);
    }

    /**
     * 获取待审批列表
     */
    public IPage<Leave> getPendingApprovalList(int page, int size, Long approverId) {
        Page<Leave> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Leave> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Leave::getApprovalStatus, 0); // 0-待审批
        wrapper.orderByDesc(Leave::getCreateTime);
        return this.page(pageParam, wrapper);
    }
}
