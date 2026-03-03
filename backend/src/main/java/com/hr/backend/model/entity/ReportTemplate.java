package com.hr.backend.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("report_template")
public class ReportTemplate {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private String description;
    private String category;
    private String content;
    private String querySql;
    private String parameters;
    private String chartConfig;
    private Integer enabled;
    private Date createTime;
    private Date updateTime;
    private Long createdBy;
    private Long updatedBy;
    private Integer version;
}
