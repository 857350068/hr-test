package com.hr.backend.model.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.io.Serializable;
import java.util.Map;

/**
 * 预警模型请求DTO
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Data
public class WarningModelDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 模型类型
     */
    @NotBlank(message = "模型类型不能为空")
    private String modelType;

    /**
     * 模型名称
     */
    @NotBlank(message = "模型名称不能为空")
    @Size(max = 50, message = "模型名称长度不能超过50个字符")
    private String modelName;

    /**
     * 特征权重
     * Map格式，如：{"age": 0.2, "performance": 0.3, "salary": 0.5}
     */
    @NotNull(message = "特征权重不能为空")
    private Map<String, Double> featureWeights;
}
