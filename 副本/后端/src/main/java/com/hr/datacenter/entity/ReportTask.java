package com.hr.datacenter.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("report_task")
public class ReportTask {
    @TableId(value = "task_id", type = IdType.AUTO)
    private Long taskId;
    private String taskName;
    private String reportType;
    private String cronExpr;
    private String shareTarget;
    private Integer status;
    private LocalDateTime lastRunTime;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
