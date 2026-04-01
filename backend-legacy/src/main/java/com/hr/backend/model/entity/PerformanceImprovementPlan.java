package com.hr.backend.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 绩效改进计划实体类
 * 对应数据库表：performance_improvement_plan
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Data
@TableName("performance_improvement_plan")
public class PerformanceImprovementPlan implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 计划唯一标识
     */
    private String planId;

    /**
     * 员工ID
     */
    private String employeeId;

    /**
     * 改进目标
     */
    private String improvementGoal;

    /**
     * 执行步骤，JSON数组格式
     */
    private String actionSteps;

    /**
     * 目标完成时间
     */
    private LocalDate targetCompletionTime;

    /**
     * 当前进度，取值范围0-100
     */
    private Integer currentProgress;

    /**
     * 完成状态
     * NOT_STARTED-未开始
     * IN_PROGRESS-进行中
     * COMPLETED-已完成
     * DELAYED-延期
     */
    private String completionStatus;

    /**
     * 实际完成时间
     */
    private LocalDate actualCompletionTime;

    /**
     * 改进效果
     */
    private String improvementEffect;

    /**
     * 创建人
     */
    private String createdBy;

    /**
     * 创建时间
     */
    private LocalDateTime createdTime;

    /**
     * 最后更新人
     */
    private String updatedBy;

    /**
     * 最后更新时间
     */
    private LocalDateTime updatedTime;
}
