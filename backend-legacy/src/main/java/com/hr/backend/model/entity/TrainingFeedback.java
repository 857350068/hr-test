package com.hr.backend.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 培训效果反馈实体类
 * 对应数据库表：training_feedback
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Data
@TableName("training_feedback")
public class TrainingFeedback implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 反馈唯一标识
     */
    private String feedbackId;

    /**
     * 关联的培训记录ID
     */
    private String trainingId;

    /**
     * 员工ID
     */
    private String employeeId;

    /**
     * 培训满意度评分，取值范围1-5
     */
    private Integer satisfactionScore;

    /**
     * 技能提升程度，取值范围1-5
     */
    private Integer skillImprovement;

    /**
     * 应用效果，取值范围1-5
     */
    private Integer applicationEffect;

    /**
     * 反馈内容
     */
    private String feedbackContent;

    /**
     * 反馈人
     */
    private String feedbackBy;

    /**
     * 反馈时间
     */
    private LocalDateTime feedbackTime;
}
