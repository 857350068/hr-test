package com.hr.backend.model.dto;

import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * 预警模型响应VO
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Data
public class WarningModelVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 模型唯一标识
     */
    private String modelId;

    /**
     * 模型类型
     */
    private String modelType;

    /**
     * 模型名称
     */
    private String modelName;

    /**
     * 特征权重
     */
    private Map<String, Double> featureWeights;

    /**
     * 准确率
     */
    private BigDecimal accuracyRate;

    /**
     * 模型版本
     */
    private String version;

    /**
     * 是否启用
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
