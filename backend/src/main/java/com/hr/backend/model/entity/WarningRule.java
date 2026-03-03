package com.hr.backend.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("warning_rule")
public class WarningRule {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String ruleType;
    private Float threshold;
    private String description;
    private Integer effective;
    private String updateLog;
    private Date createTime;
    private Date updateTime;
}
