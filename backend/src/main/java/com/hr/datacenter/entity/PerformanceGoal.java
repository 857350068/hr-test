package com.hr.datacenter.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 绩效目标实体类
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Data
@TableName("performance_goal")
public class PerformanceGoal implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 目标ID
     */
    @TableId(value = "goal_id", type = IdType.AUTO)
    private Long goalId;

    /**
     * 员工ID
     */
    private Long empId;

    /**
     * 评估年度
     */
    private Integer year;

    /**
     * 评估周期(1-年度 2-季度 3-月度)
     */
    private Integer periodType;

    /**
     * 目标描述
     */
    private String goalDescription;

    /**
     * 权重(百分比)
     */
    private Integer weight;

    /**
     * 完成标准
     */
    private String completionStandard;

    /**
     * 目标状态(0-草稿 1-进行中 2-已完成)
     */
    private Integer goalStatus;

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
    public Long getGoalId() {
        return goalId;
    }

    public void setGoalId(Long goalId) {
        this.goalId = goalId;
    }

    public Long getEmpId() {
        return empId;
    }

    public void setEmpId(Long empId) {
        this.empId = empId;
    }

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public Integer getPeriodType() {
        return periodType;
    }

    public void setPeriodType(Integer periodType) {
        this.periodType = periodType;
    }

    public String getGoalDescription() {
        return goalDescription;
    }

    public void setGoalDescription(String goalDescription) {
        this.goalDescription = goalDescription;
    }

    public Integer getWeight() {
        return weight;
    }

    public void setWeight(Integer weight) {
        this.weight = weight;
    }

    public String getCompletionStandard() {
        return completionStandard;
    }

    public void setCompletionStandard(String completionStandard) {
        this.completionStandard = completionStandard;
    }

    public Integer getGoalStatus() {
        return goalStatus;
    }

    public void setGoalStatus(Integer goalStatus) {
        this.goalStatus = goalStatus;
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
