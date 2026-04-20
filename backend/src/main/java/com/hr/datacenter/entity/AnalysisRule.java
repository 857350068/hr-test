package com.hr.datacenter.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("analysis_rule")
public class AnalysisRule {
    @TableId(value = "rule_id", type = IdType.AUTO)
    private Long ruleId;
    private String ruleName;
    private String ruleType;
    private String ruleKey;
    private String ruleValue;
    private Integer effectStatus;
    private String changeLog;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
