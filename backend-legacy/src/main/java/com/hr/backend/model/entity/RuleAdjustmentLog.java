package com.hr.backend.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 规则调整日志实体类
 * 对应数据库表：rule_adjustment_log
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Data
@TableName("rule_adjustment_log")
public class RuleAdjustmentLog implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 日志唯一标识
     */
    private String logId;

    /**
     * 关联的分析规则ID
     */
    private String ruleId;

    /**
     * 调整类型
     * CREATE-创建
     * UPDATE-更新
     * ACTIVATE-激活
     * DEACTIVATE-失效
     * DELETE-删除
     */
    private String adjustmentType;

    /**
     * 调整前的值，JSON格式
     */
    private String oldValue;

    /**
     * 调整后的值，JSON格式
     */
    private String newValue;

    /**
     * 调整人
     */
    private String adjustedBy;

    /**
     * 调整时间
     */
    private LocalDateTime adjustedTime;

    /**
     * 调整备注
     */
    private String remark;
}
