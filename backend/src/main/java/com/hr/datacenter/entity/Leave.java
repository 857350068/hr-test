package com.hr.datacenter.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 请假记录实体类
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Data
@TableName("`leave`")
public class Leave implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 请假ID
     */
    @TableId(value = "leave_id", type = IdType.AUTO)
    private Long leaveId;

    /**
     * 员工ID
     */
    private Long empId;

    /**
     * 请假类型
     * 0-事假 1-病假 2-年假 3-婚假 4-产假 5-丧假 6-其他
     */
    private Integer leaveType;

    /**
     * 请假开始时间
     */
    private LocalDateTime startTime;

    /**
     * 请假结束时间
     */
    private LocalDateTime endTime;

    /**
     * 请假时长(小时)
     */
    private Integer leaveDuration;

    /**
     * 请假原因
     */
    private String reason;

    /**
     * 审批人ID
     */
    private Long approverId;

    /**
     * 审批状态
     * 0-待审批 1-已同意 2-已拒绝 3-已撤回
     */
    private Integer approvalStatus;

    /**
     * 审批意见
     */
    private String approvalComment;

    /**
     * 审批时间
     */
    private LocalDateTime approvalTime;

    /**
     * 附件路径
     */
    private String attachment;

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
    public Long getLeaveId() {
        return leaveId;
    }

    public void setLeaveId(Long leaveId) {
        this.leaveId = leaveId;
    }

    public Long getEmpId() {
        return empId;
    }

    public void setEmpId(Long empId) {
        this.empId = empId;
    }

    public Integer getLeaveType() {
        return leaveType;
    }

    public void setLeaveType(Integer leaveType) {
        this.leaveType = leaveType;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public Integer getLeaveDuration() {
        return leaveDuration;
    }

    public void setLeaveDuration(Integer leaveDuration) {
        this.leaveDuration = leaveDuration;
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

    public LocalDateTime getApprovalTime() {
        return approvalTime;
    }

    public void setApprovalTime(LocalDateTime approvalTime) {
        this.approvalTime = approvalTime;
    }

    public String getAttachment() {
        return attachment;
    }

    public void setAttachment(String attachment) {
        this.attachment = attachment;
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
