package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.SalaryAdjustment;
import com.hr.datacenter.mapper.mysql.SalaryAdjustmentMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * 薪资调整Service
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class SalaryAdjustmentService extends ServiceImpl<SalaryAdjustmentMapper, SalaryAdjustment> {

    /**
     * 分页查询薪资调整
     */
    public IPage<SalaryAdjustment> getAdjustmentPage(int page, int size, Long empId, Integer approvalStatus) {
        Page<SalaryAdjustment> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<SalaryAdjustment> wrapper = new LambdaQueryWrapper<>();
        
        if (empId != null) {
            wrapper.eq(SalaryAdjustment::getEmpId, empId);
        }
        if (approvalStatus != null) {
            wrapper.eq(SalaryAdjustment::getApprovalStatus, approvalStatus);
        }
        
        wrapper.orderByDesc(SalaryAdjustment::getCreateTime);
        return this.page(pageParam, wrapper);
    }

    /**
     * 申请薪资调整
     */
    public boolean applyAdjustment(SalaryAdjustment adjustment) {
        adjustment.setApprovalStatus(0); // 0-待审批
        return this.save(adjustment);
    }

    /**
     * 审批薪资调整
     */
    public boolean approveAdjustment(Long adjustmentId, Long approverId, Integer approvalStatus, String approvalComment) {
        SalaryAdjustment adjustment = this.getById(adjustmentId);
        if (adjustment == null) {
            throw new RuntimeException("调整记录不存在");
        }
        
        if (adjustment.getApprovalStatus() != 0) {
            throw new RuntimeException("该调整记录已审批");
        }
        
        adjustment.setApproverId(approverId);
        adjustment.setApprovalStatus(approvalStatus);
        adjustment.setApprovalComment(approvalComment);
        adjustment.setApprovalDate(java.time.LocalDateTime.now());
        
        return this.updateById(adjustment);
    }

    /**
     * 获取待审批列表
     */
    public IPage<SalaryAdjustment> getPendingApprovalList(int page, int size) {
        Page<SalaryAdjustment> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<SalaryAdjustment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SalaryAdjustment::getApprovalStatus, 0); // 0-待审批
        wrapper.orderByDesc(SalaryAdjustment::getCreateTime);
        return this.page(pageParam, wrapper);
    }
}
