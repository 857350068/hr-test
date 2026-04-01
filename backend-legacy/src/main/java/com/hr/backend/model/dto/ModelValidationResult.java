package com.hr.backend.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 模型验证结果DTO
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ModelValidationResult implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 准确率
     */
    private BigDecimal accuracyRate;

    /**
     * 样本数量
     */
    private Integer sampleSize;

    /**
     * 验证时间
     */
    private LocalDateTime validationTime;
}
