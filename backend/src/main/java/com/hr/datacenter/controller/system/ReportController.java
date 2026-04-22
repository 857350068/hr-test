package com.hr.datacenter.controller.system;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.ReportShareLog;
import com.hr.datacenter.entity.ReportTask;
import com.hr.datacenter.service.ReportExportService;
import com.hr.datacenter.service.ReportTaskService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/system/report")
@CrossOrigin(origins = "*")
public class ReportController {
    @Autowired
    private ReportTaskService reportTaskService;
    @Autowired
    private ReportExportService reportExportService;

    @GetMapping("/task/list")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<List<ReportTask>> list() {
        return Result.success(reportTaskService.list(new LambdaQueryWrapper<ReportTask>()
                .orderByDesc(ReportTask::getUpdateTime)));
    }

    @PostMapping("/task/add")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> addTask(@RequestBody ReportTask task) {
        task.setTaskId(null);
        task.setCreateTime(LocalDateTime.now());
        task.setUpdateTime(LocalDateTime.now());
        if (task.getStatus() == null) task.setStatus(1);
        reportTaskService.save(task);
        return Result.success("新增成功", "");
    }

    @PutMapping("/task/update")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> updateTask(@RequestBody ReportTask task) {
        task.setUpdateTime(LocalDateTime.now());
        reportTaskService.updateById(task);
        return Result.success("更新成功", "");
    }

    @DeleteMapping("/task/delete/{id}")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> deleteTask(@PathVariable Long id) {
        reportTaskService.removeById(id);
        return Result.success("删除成功", "");
    }

    @GetMapping("/export")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<Map<String, String>> export(@RequestParam String reportType) {
        String normalizedType = StringUtils.hasText(reportType) ? reportType : "warning";
        ReportExportService.GeneratedReport generated = reportExportService.generateAndSaveReport(normalizedType);
        Map<String, String> data = new LinkedHashMap<>();
        data.put("fileName", generated.getFileName());
        data.put("downloadPath", "/api/system/report/export-file?reportType=" + normalizedType);
        data.put("message", "导出文件已生成，路径: " + generated.getFilePath());
        return Result.success("导出准备完成", data);
    }

    @GetMapping("/export-file")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public ResponseEntity<byte[]> exportFile(@RequestParam String reportType) {
        String normalizedType = StringUtils.hasText(reportType) ? reportType : "warning";
        ReportExportService.GeneratedReport generated = reportExportService.generateAndSaveReport(normalizedType);
        reportTaskService.recordExecution(null, "手工导出", normalizedType, generated.getFileName(), 1,
                "手工导出成功，文件路径: " + generated.getFilePath());
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename*=UTF-8''" + urlEncode(generated.getFileName()))
                .contentType(MediaType.parseMediaType("text/csv;charset=UTF-8"))
                .body(("\uFEFF" + generated.getCsvContent()).getBytes(StandardCharsets.UTF_8));
    }

    @GetMapping("/file/{fileName:.+}")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public ResponseEntity<byte[]> downloadGeneratedFile(@PathVariable String fileName,
                                                        @RequestParam(defaultValue = "attachment") String disposition) {
        byte[] fileBytes = reportExportService.readReportFile(fileName);
        String headerDisposition = "inline".equalsIgnoreCase(disposition) ? "inline" : "attachment";
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        headerDisposition + "; filename*=UTF-8''" + urlEncode(fileName))
                .contentType(MediaType.parseMediaType("text/csv;charset=UTF-8"))
                .body(fileBytes);
    }

    @PostMapping("/share")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> share(@RequestParam String reportType, @RequestParam String target) {
        reportTaskService.shareToTargets(null, reportType, target);
        return Result.success("报表分享成功：" + reportType + " -> " + target, "");
    }

    @GetMapping("/execution-log/list")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<List<Map<String, Object>>> executionLogs() {
        return Result.success(reportTaskService.getLatestExecutionLogsWithFileStatus());
    }

    @PostMapping("/execution-log/rebuild/{logId}")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> rebuildExecutionLogFile(@PathVariable Long logId) {
        String fileName = reportTaskService.rebuildExecutionLogFile(logId);
        return Result.success("重建成功", fileName);
    }

    @GetMapping("/share-log/list")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<List<ReportShareLog>> shareLogs() {
        return Result.success(reportTaskService.getLatestShareLogs());
    }

    private String urlEncode(String filename) {
        try {
            return java.net.URLEncoder.encode(filename, "UTF-8");
        } catch (Exception ex) {
            return filename;
        }
    }
}
