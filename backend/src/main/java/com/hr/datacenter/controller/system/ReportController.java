package com.hr.datacenter.controller.system;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.ReportExecutionLog;
import com.hr.datacenter.entity.ReportShareLog;
import com.hr.datacenter.entity.ReportTask;
import com.hr.datacenter.service.ReportTaskService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.nio.charset.StandardCharsets;
import java.net.URLEncoder;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/system/report")
@CrossOrigin(origins = "*")
public class ReportController {
    @Autowired
    private ReportTaskService reportTaskService;
    @Autowired
    private JdbcTemplate jdbcTemplate;

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
        String filename = buildFileName(normalizedType);
        Map<String, String> data = new LinkedHashMap<>();
        data.put("fileName", filename);
        data.put("downloadPath", "/api/system/report/export-file?reportType=" + normalizedType);
        data.put("message", "导出文件已生成，可直接下载");
        return Result.success("导出准备完成", data);
    }

    @GetMapping("/export-file")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public ResponseEntity<byte[]> exportFile(@RequestParam String reportType) {
        String normalizedType = StringUtils.hasText(reportType) ? reportType : "warning";
        String csvContent = buildCsv(normalizedType);
        String filename = buildFileName(normalizedType);
        reportTaskService.recordExecution(null, "手工导出", normalizedType, filename, 1, "手工导出成功");
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename*=UTF-8''" + urlEncode(filename))
                .contentType(MediaType.parseMediaType("text/csv;charset=UTF-8"))
                .body(("\uFEFF" + csvContent).getBytes(StandardCharsets.UTF_8));
    }

    @PostMapping("/share")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> share(@RequestParam String reportType, @RequestParam String target) {
        reportTaskService.shareToTargets(null, reportType, target);
        return Result.success("报表分享成功：" + reportType + " -> " + target, "");
    }

    @GetMapping("/execution-log/list")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<List<ReportExecutionLog>> executionLogs() {
        return Result.success(reportTaskService.getLatestExecutionLogs());
    }

    @GetMapping("/share-log/list")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<List<ReportShareLog>> shareLogs() {
        return Result.success(reportTaskService.getLatestShareLogs());
    }

    private String buildFileName(String reportType) {
        String ts = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        return "hr_report_" + reportType + "_" + ts + ".csv";
    }

    private String urlEncode(String filename) {
        try {
            return URLEncoder.encode(filename, "UTF-8");
        } catch (Exception ex) {
            return filename;
        }
    }

    private String buildCsv(String reportType) {
        String sql;
        switch (reportType) {
            case "org":
                sql = "SELECT department AS `部门`, COUNT(*) AS `在职人数`, ROUND(AVG(salary),2) AS `平均薪资` " +
                        "FROM employee WHERE deleted = 0 AND status = 1 GROUP BY department ORDER BY COUNT(*) DESC";
                break;
            case "salary":
                sql = "SELECT e.department AS `部门`, sp.year AS `年份`, sp.month AS `月份`, " +
                        "ROUND(SUM(sp.total_net_salary),2) AS `实发总额` " +
                        "FROM salary_payment sp JOIN employee e ON e.emp_id = sp.emp_id " +
                        "WHERE sp.deleted = 0 AND e.deleted = 0 GROUP BY e.department, sp.year, sp.month " +
                        "ORDER BY sp.year DESC, sp.month DESC";
                break;
            case "warning":
            default:
                sql = "SELECT department AS `部门`, emp_no AS `员工编号`, emp_name AS `员工姓名`, position AS `岗位`, salary AS `当前薪资` " +
                        "FROM employee WHERE deleted = 0 AND status = 1 ORDER BY salary ASC LIMIT 200";
                break;
        }
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql);
        return convertToCsv(rows);
    }

    private String convertToCsv(List<Map<String, Object>> rows) {
        if (rows == null || rows.isEmpty()) {
            return "无数据\n";
        }
        StringBuilder sb = new StringBuilder();
        Map<String, Object> first = rows.get(0);
        List<String> headers = first.keySet().stream().collect(Collectors.toList());
        sb.append(String.join(",", headers)).append("\n");
        for (Map<String, Object> row : rows) {
            for (int i = 0; i < headers.size(); i++) {
                String key = headers.get(i);
                String value = row.get(key) == null ? "" : String.valueOf(row.get(key));
                String escaped = value.replace("\"", "\"\"");
                if (escaped.contains(",") || escaped.contains("\"") || escaped.contains("\n")) {
                    sb.append("\"").append(escaped).append("\"");
                } else {
                    sb.append(escaped);
                }
                if (i < headers.size() - 1) {
                    sb.append(",");
                }
            }
            sb.append("\n");
        }
        return sb.toString();
    }
}
