package com.hr.backend.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 分析规则实体类
 * 对应数据库表：analysis_rule
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Data
@TableName("analysis_rule")
public class AnalysisRule implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 规则唯一标识，格式：RULE_YYYYMMDD_NNNN
     */
    private String ruleId;

    /**
     * 规则类型
     * TURNOVER_WARNING-流失预警
     * COMPENSATION_BENCHMARK-薪酬对标
     * TRAINING_ROI-培训ROI
     * PERFORMANCE_EVAL-绩效评估
     * TALENT_GAP-人才缺口
     */
    private String ruleType;

    /**
     * 规则名称
     */
    private String ruleName;

    /**
     * 规则参数，JSON格式
     * 包含具体的阈值、权重等参数
     */
    private String ruleParams;

    /**
     * 生效状态
     * true-已生效，false-未生效
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
