package com.hr.backend.model.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.io.Serializable;

/**
 * 分析规则请求DTO
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Data
public class AnalysisRuleDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 规则类型
     */
    @NotBlank(message = "规则类型不能为空")
    private String ruleType;

    /**
     * 规则名称
     */
    @NotBlank(message = "规则名称不能为空")
    @Size(max = 50, message = "规则名称长度不能超过50个字符")
    private String ruleName;

    /**
     * 规则参数，JSON格式
     */
    @NotBlank(message = "规则参数不能为空")
    private String ruleParams;

    /**
     * 生效状态
     */
    @NotNull(message = "生效状态不能为空")
    private Boolean isActive;
}
