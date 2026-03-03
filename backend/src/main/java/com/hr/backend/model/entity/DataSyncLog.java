package com.hr.backend.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("data_sync_log")
public class DataSyncLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Date startTime;
    private Date endTime;
    private String status;
    private Long recordsProcessed;
    private String details;
    private Date createTime;
}
