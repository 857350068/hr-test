package com.hr.datacenter.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 绩效评估实体类
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Data
@TableName("performance_evaluation")
public class PerformanceEvaluation implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 评估ID
     */
    @TableId(value = "evaluation_id", type = IdType.AUTO)
    private Long evaluationId;

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
     * 季度(季度评估时使用)
     */
    private Integer quarter;

    /**
     * 月份(月度评估时使用)
     */
    private Integer month;

    /**
     * 自评分
     */
    private Double selfScore;

    /**
     * 自评说明
     */
    private String selfComment;

    /**
     * 上级评分
     */
    private Double supervisorScore;

    /**
     * 上级评价意见
     */
    private String supervisorComment;

    /**
     * 综合评分
     */
    private Double finalScore;

    /**
     * 绩效等级(S-优秀 A-良好 B-合格 C-需改进 D-不合格)
     */
    private String performanceLevel;

    /**
     * 改进建议
     */
    private String improvementPlan;

    /**
     * 面谈记录
     */
    private String interviewRecord;

    /**
     * 面谈时间
     */
    private LocalDateTime interviewDate;

    /**
     * 评估状态(0-未评估 1-已自评 2-已评价 3-已完成)
     */
    private Integer evaluationStatus;

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
    public Long getEvaluationId() {
        return evaluationId;
    }

    public void setEvaluationId(Long evaluationId) {
        this.evaluationId = evaluationId;
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

    public Integer getQuarter() {
        return quarter;
    }

    public void setQuarter(Integer quarter) {
        this.quarter = quarter;
    }

    public Integer getMonth() {
        return month;
    }

    public void setMonth(Integer month) {
        this.month = month;
    }

    public Double getSelfScore() {
        return selfScore;
    }

    public void setSelfScore(Double selfScore) {
        this.selfScore = selfScore;
    }

    public String getSelfComment() {
        return selfComment;
    }

    public void setSelfComment(String selfComment) {
        this.selfComment = selfComment;
    }

    public Double getSupervisorScore() {
        return supervisorScore;
    }

    public void setSupervisorScore(Double supervisorScore) {
        this.supervisorScore = supervisorScore;
    }

    public String getSupervisorComment() {
        return supervisorComment;
    }

    public void setSupervisorComment(String supervisorComment) {
        this.supervisorComment = supervisorComment;
    }

    public Double getFinalScore() {
        return finalScore;
    }

    public void setFinalScore(Double finalScore) {
        this.finalScore = finalScore;
    }

    public String getPerformanceLevel() {
        return performanceLevel;
    }

    public void setPerformanceLevel(String performanceLevel) {
        this.performanceLevel = performanceLevel;
    }

    public String getImprovementPlan() {
        return improvementPlan;
    }

    public void setImprovementPlan(String improvementPlan) {
        this.improvementPlan = improvementPlan;
    }

    public String getInterviewRecord() {
        return interviewRecord;
    }

    public void setInterviewRecord(String interviewRecord) {
        this.interviewRecord = interviewRecord;
    }

    public LocalDateTime getInterviewDate() {
        return interviewDate;
    }

    public void setInterviewDate(LocalDateTime interviewDate) {
        this.interviewDate = interviewDate;
    }

    public Integer getEvaluationStatus() {
        return evaluationStatus;
    }

    public void setEvaluationStatus(Integer evaluationStatus) {
        this.evaluationStatus = evaluationStatus;
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
