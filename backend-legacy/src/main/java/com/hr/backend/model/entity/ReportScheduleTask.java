package com.hr.backend.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 报表定时任务实体类
 * 对应数据库表：report_schedule_task
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Data
@TableName("report_schedule_task")
public class ReportScheduleTask implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 任务唯一标识
     */
    private String taskId;

    /**
     * 关联的报表模板ID
     */
    private String templateId;

    /**
     * 任务名称
     */
    private String taskName;

    /**
     * 调度类型
     * DAILY-日报
     * WEEKLY-周报
     * MONTHLY-月报
     */
    private String scheduleType;

    /**
     * 执行时间
     * 格式：HH:MM（日报）或DAY HH:MM（周报/月报）
     */
    private String executeTime;

    /**
     * 分享权限，JSON数组格式
     * 如：["HR_ADMIN", "DEPT_HEAD"]
     */
    private String sharePermissions;

    /**
     * 链接有效期天数，取值范围1-365
     */
    private Integer linkExpiryDays;

    /**
     * 是否启用
     * true-已启用，false-未启用
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
}
