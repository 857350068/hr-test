package com.hr.datacenter.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("report_share_log")
public class ReportShareLog {
    @TableId(value = "share_id", type = IdType.AUTO)
    private Long shareId;
    private Long taskId;
    private String reportType;
    private String target;
    private String shareChannel;
    private Integer status;
    private String message;
    private LocalDateTime shareTime;
}
