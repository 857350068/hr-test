package com.hr.backend.model.dto;

import lombok.Data;

import java.io.Serializable;

/**
 * 分析规则查询DTO
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Data
public class AnalysisRuleQueryDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 规则类型
     */
    private String ruleType;

    /**
     * 规则名称（模糊查询）
     */
    private String ruleName;

    /**
     * 生效状态
     */
    private Boolean isActive;

    /**
     * 页码
     */
    private Integer pageNum = 1;

    /**
     * 每页大小
     */
    private Integer pageSize = 10;
}
