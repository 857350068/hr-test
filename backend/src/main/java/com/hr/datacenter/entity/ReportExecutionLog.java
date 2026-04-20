package com.hr.datacenter.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("report_execution_log")
public class ReportExecutionLog {
    @TableId(value = "log_id", type = IdType.AUTO)
    private Long logId;
    private Long taskId;
    private String taskName;
    private String reportType;
    private String fileName;
    private Integer status;
    private String message;
    private LocalDateTime runTime;
}
