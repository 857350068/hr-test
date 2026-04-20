package com.hr.datacenter.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 薪资调整实体类
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Data
@TableName("salary_adjustment")
public class SalaryAdjustment implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 调整ID
     */
    @TableId(value = "adjustment_id", type = IdType.AUTO)
    private Long adjustmentId;

    /**
     * 员工ID
     */
    private Long empId;

    /**
     * 调整类型(1-晋升 2-降职 3-调薪 4-转正)
     */
    private Integer adjustmentType;

    /**
     * 调整前基本工资
     */
    private BigDecimal beforeSalary;

    /**
     * 调整后基本工资
     */
    private BigDecimal afterSalary;

    /**
     * 调整幅度(%)
     */
    private BigDecimal adjustmentRate;

    /**
     * 生效日期
     */
    private LocalDateTime effectiveDate;

    /**
     * 调整原因
     */
    private String reason;

    /**
     * 审批人ID
     */
    private Long approverId;

    /**
     * 审批状态(0-待审批 1-已同意 2-已拒绝)
     */
    private Integer approvalStatus;

    /**
     * 审批意见
     */
    private String approvalComment;

    /**
     * 审批时间
     */
    private LocalDateTime approvalDate;

    /**
     * 创建人ID
     */
    private Long creatorId;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /**
     * 删除标记
     */
    @TableLogic
    private Integer deleted;

    // Getter and Setter methods
    public Long getAdjustmentId() {
        return adjustmentId;
    }

    public void setAdjustmentId(Long adjustmentId) {
        this.adjustmentId = adjustmentId;
    }

    public Long getEmpId() {
        return empId;
    }

    public void setEmpId(Long empId) {
        this.empId = empId;
    }

    public Integer getAdjustmentType() {
        return adjustmentType;
    }

    public void setAdjustmentType(Integer adjustmentType) {
        this.adjustmentType = adjustmentType;
    }

    public BigDecimal getBeforeSalary() {
        return beforeSalary;
    }

    public void setBeforeSalary(BigDecimal beforeSalary) {
        this.beforeSalary = beforeSalary;
    }

    public BigDecimal getAfterSalary() {
        return afterSalary;
    }

    public void setAfterSalary(BigDecimal afterSalary) {
        this.afterSalary = afterSalary;
    }

    public BigDecimal getAdjustmentRate() {
        return adjustmentRate;
    }

    public void setAdjustmentRate(BigDecimal adjustmentRate) {
        this.adjustmentRate = adjustmentRate;
    }

    public LocalDateTime getEffectiveDate() {
        return effectiveDate;
    }

    public void setEffectiveDate(LocalDateTime effectiveDate) {
        this.effectiveDate = effectiveDate;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public Long getApproverId() {
        return approverId;
    }

    public void setApproverId(Long approverId) {
        this.approverId = approverId;
    }

    public Integer getApprovalStatus() {
        return approvalStatus;
    }

    public void setApprovalStatus(Integer approvalStatus) {
        this.approvalStatus = approvalStatus;
    }

    public String getApprovalComment() {
        return approvalComment;
    }

    public void setApprovalComment(String approvalComment) {
        this.approvalComment = approvalComment;
    }

    public LocalDateTime getApprovalDate() {
        return approvalDate;
    }

    public void setApprovalDate(LocalDateTime approvalDate) {
        this.approvalDate = approvalDate;
    }

    public Long getCreatorId() {
        return creatorId;
    }

    public void setCreatorId(Long creatorId) {
        this.creatorId = creatorId;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public LocalDateTime getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }

    public Integer getDeleted() {
        return deleted;
    }

    public void setDeleted(Integer deleted) {
        this.deleted = deleted;
    }
}
