package com.hr.backend.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 报表分享记录实体类
 * 对应数据库表：report_share_record
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Data
@TableName("report_share_record")
public class ReportShareRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 分享记录唯一标识
     */
    private String shareId;

    /**
     * 关联的定时任务ID
     */
    private String taskId;

    /**
     * 报表文件存储路径
     */
    private String reportFilePath;

    /**
     * 分享链接，包含唯一token
     */
    private String shareLink;

    /**
     * 分享权限，JSON数组格式
     */
    private String sharePermissions;

    /**
     * 链接过期时间
     */
    private LocalDateTime expiryTime;

    /**
     * 创建时间
     */
    private LocalDateTime createdTime;
}
