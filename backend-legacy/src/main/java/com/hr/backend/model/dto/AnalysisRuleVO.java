package com.hr.backend.model.dto;

import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 分析规则响应VO
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Data
public class AnalysisRuleVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 规则唯一标识
     */
    private String ruleId;

    /**
     * 规则类型
     */
    private String ruleType;

    /**
     * 规则名称
     */
    private String ruleName;

    /**
     * 规则参数，JSON格式
     */
    private String ruleParams;

    /**
     * 生效状态
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

    /**
     * 最后修改人
     */
    private String updatedBy;

    /**
     * 最后修改时间
     */
    private LocalDateTime updatedTime;
}
