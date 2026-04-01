package com.hr.backend.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 预警模型实体类
 * 对应数据库表：warning_model
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Data
@TableName("warning_model")
public class WarningModel implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 模型唯一标识，格式：MODEL_YYYYMMDD_NNNN
     */
    private String modelId;

    /**
     * 模型类型
     * TURNOVER_PREDICTION-流失预测
     * TALENT_GAP-人才缺口
     * COST_OVERSPEED-成本超支
     */
    private String modelType;

    /**
     * 模型名称
     */
    private String modelName;

    /**
     * 特征权重，JSON格式
     * 如：{"age": 0.2, "performance": 0.3, "salary": 0.5}
     * 所有权重之和必须等于1
     */
    private String featureWeights;

    /**
     * 准确率，取值范围0-1
     */
    private BigDecimal accuracyRate;

    /**
     * 模型版本，格式：v1.0, v1.1等
     */
    private String version;

    /**
     * 是否启用
     * true-已启用，false-未启用
     */
    private Boolean isActive;

    /**
     * 创建人
     */
    private String createdBy;

    /**
     * 创建时间
     */
    private LocalDateTime createdTime;
}
