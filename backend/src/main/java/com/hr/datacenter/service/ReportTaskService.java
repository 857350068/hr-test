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
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

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
    @Autowired
    private ReportExportService reportExportService;

    @Scheduled(cron = "0 * * * * ?")
    public void executeDueTasks() {
        List<ReportTask> tasks = this.list(new LambdaQueryWrapper<ReportTask>()
                .eq(ReportTask::getStatus, 1));
        LocalDateTime now = LocalDateTime.now();
        for (ReportTask task : tasks) {
            if (shouldRun(task, now)) {
                try {
                    ReportExportService.GeneratedReport generated = reportExportService.generateAndSaveReport(task.getReportType());
                    recordExecution(task, 1, generated.getFileName(), "定时任务执行成功，文件路径: " + generated.getFilePath());
                    task.setLastRunTime(now);
                    this.updateById(task);
                    if (StringUtils.hasText(task.getShareTarget())) {
                        shareToTargets(task.getTaskId(), task.getReportType(), task.getShareTarget());
                    }
                } catch (Exception ex) {
                    recordExecution(task, 0, null, "定时任务执行失败: " + ex.getMessage());
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
                messageService.saveMessage(message);
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

    public List<Map<String, Object>> getLatestExecutionLogsWithFileStatus() {
        List<ReportExecutionLog> logs = getLatestExecutionLogs();
        return logs.stream().map(log -> {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("logId", log.getLogId());
            row.put("taskId", log.getTaskId());
            row.put("taskName", log.getTaskName());
            row.put("reportType", log.getReportType());
            row.put("fileName", log.getFileName());
            row.put("status", log.getStatus());
            row.put("message", log.getMessage());
            row.put("runTime", log.getRunTime());
            row.put("fileExists", reportExportService.existsReportFile(log.getFileName()));
            return row;
        }).collect(Collectors.toList());
    }

    public List<ReportShareLog> getLatestShareLogs() {
        return shareLogService.list(new LambdaQueryWrapper<ReportShareLog>()
                .orderByDesc(ReportShareLog::getShareTime)
                .last("LIMIT 20"));
    }

    public String rebuildExecutionLogFile(Long logId) {
        ReportExecutionLog log = executionLogService.getById(logId);
        if (log == null) {
            throw new IllegalArgumentException("执行记录不存在: " + logId);
        }
        if (!StringUtils.hasText(log.getReportType())) {
            throw new IllegalArgumentException("执行记录缺少报表类型，无法重建");
        }
        try {
            ReportExportService.GeneratedReport generated = reportExportService.generateAndSaveReport(log.getReportType());
            log.setFileName(generated.getFileName());
            log.setStatus(1);
            log.setMessage("文件已重建，路径: " + generated.getFilePath());
            log.setRunTime(LocalDateTime.now());
            executionLogService.updateById(log);
            return generated.getFileName();
        } catch (Exception ex) {
            log.setStatus(0);
            log.setMessage("重建失败: " + ex.getMessage());
            log.setRunTime(LocalDateTime.now());
            executionLogService.updateById(log);
            throw new IllegalStateException("重建失败", ex);
        }
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

}
