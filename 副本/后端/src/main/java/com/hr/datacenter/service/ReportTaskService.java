package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.Message;
import com.hr.datacenter.entity.ReportExecutionLog;
import com.hr.datacenter.entity.ReportShareLog;
import com.hr.datacenter.entity.ReportTask;
import com.hr.datacenter.entity.User;
import com.hr.datacenter.mapper.mysql.ReportTaskMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.scheduling.support.CronExpression;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

@Service
public class ReportTaskService extends ServiceImpl<ReportTaskMapper, ReportTask> {

    @Autowired
    private ReportExecutionLogService executionLogService;
    @Autowired
    private ReportShareLogService shareLogService;
    @Autowired
    private MessageService messageService;
    @Autowired
    private UserService userService;

    @Scheduled(cron = "0 * * * * ?")
    public void executeDueTasks() {
        List<ReportTask> tasks = this.list(new LambdaQueryWrapper<ReportTask>()
                .eq(ReportTask::getStatus, 1));
        LocalDateTime now = LocalDateTime.now();
        for (ReportTask task : tasks) {
            if (shouldRun(task, now)) {
                recordExecution(task, 1, buildFileName(task.getReportType()), "定时任务执行成功");
                task.setLastRunTime(now);
                this.updateById(task);
                if (StringUtils.hasText(task.getShareTarget())) {
                    shareToTargets(task.getTaskId(), task.getReportType(), task.getShareTarget());
                }
            }
        }
    }

    public void recordExecution(Long taskId, String taskName, String reportType, String fileName, int status, String message) {
        ReportExecutionLog log = new ReportExecutionLog();
        log.setTaskId(taskId);
        log.setTaskName(taskName);
        log.setReportType(reportType);
        log.setFileName(fileName);
        log.setStatus(status);
        log.setMessage(message);
        log.setRunTime(LocalDateTime.now());
        executionLogService.save(log);
    }

    public void recordExecution(ReportTask task, int status, String fileName, String message) {
        recordExecution(task == null ? null : task.getTaskId(),
                task == null ? null : task.getTaskName(),
                task == null ? null : task.getReportType(),
                fileName,
                status,
                message);
    }

    public void shareToTargets(Long taskId, String reportType, String targets) {
        if (!StringUtils.hasText(targets)) {
            return;
        }
        List<String> targetList = Arrays.asList(targets.split("[,;\\s]+"));
        for (String target : targetList) {
            if (!StringUtils.hasText(target)) {
                continue;
            }
            User receiver = userService.getByUsernameOrEmail(target.trim());
            ReportShareLog log = new ReportShareLog();
            log.setTaskId(taskId);
            log.setReportType(reportType);
            log.setTarget(target.trim());
            log.setShareChannel("message");
            log.setShareTime(LocalDateTime.now());
            if (receiver != null) {
                Message message = new Message();
                message.setSenderId(1L);
                message.setReceiverId(receiver.getUserId());
                message.setTitle("报表分享通知");
                message.setContent(String.format("报表类型：%s，分享目标：%s。请前往报表中心查看或下载。", reportType, target.trim()));
                message.setMessageType(1);
                message.setIsRead(0);
                messageService.save(message);
                log.setStatus(1);
                log.setMessage("已通过站内消息分享");
            } else {
                log.setStatus(0);
                log.setMessage("未找到分享目标对应用户");
            }
            shareLogService.save(log);
        }
    }

    public List<ReportExecutionLog> getLatestExecutionLogs() {
        return executionLogService.list(new LambdaQueryWrapper<ReportExecutionLog>()
                .orderByDesc(ReportExecutionLog::getRunTime)
                .last("LIMIT 20"));
    }

    public List<ReportShareLog> getLatestShareLogs() {
        return shareLogService.list(new LambdaQueryWrapper<ReportShareLog>()
                .orderByDesc(ReportShareLog::getShareTime)
                .last("LIMIT 20"));
    }

    private boolean shouldRun(ReportTask task, LocalDateTime now) {
        if (!StringUtils.hasText(task.getCronExpr())) {
            return false;
        }
        try {
            CronExpression expression = CronExpression.parse(task.getCronExpr());
            LocalDateTime base = task.getLastRunTime() != null ? task.getLastRunTime().minusSeconds(1) : now.minusMinutes(1);
            LocalDateTime next = expression.next(base);
            return next != null && !next.isAfter(now);
        } catch (Exception ex) {
            return false;
        }
    }

    private String buildFileName(String reportType) {
        String ts = LocalDateTime.now().toString().replace(":", "-");
        return "report_" + (StringUtils.hasText(reportType) ? reportType : "general") + "_" + ts + ".csv";
    }
}
