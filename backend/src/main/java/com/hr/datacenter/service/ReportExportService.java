package com.hr.datacenter.service;

import com.hr.datacenter.util.CsvExportUtil;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import javax.sql.DataSource;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class ReportExportService {

    @Autowired
    @Qualifier("hiveDataSource")
    private DataSource hiveDataSource;

    @Value("${report.export.dir:report-exports}")
    private String exportDir;

    public GeneratedReport generateAndSaveReport(String reportType) {
        String normalizedType = StringUtils.hasText(reportType) ? reportType.trim() : "warning";
        String csvContent = buildCsvByHive(normalizedType);
        String filename = buildFileName(normalizedType);
        Path path = ensureExportDir().resolve(filename);
        try {
            Files.write(path, ("\uFEFF" + csvContent).getBytes(StandardCharsets.UTF_8));
            return new GeneratedReport(filename, path, csvContent);
        } catch (Exception ex) {
            throw new IllegalStateException("写入报表文件失败: " + path, ex);
        }
    }

    public String buildCsvByHive(String reportType) {
        String normalizedType = StringUtils.hasText(reportType) ? reportType.trim() : "warning";
        JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
        try {
            List<Map<String, Object>> rows = queryReportRows(hiveJdbc, normalizedType);
            return CsvExportUtil.toCsv(rows);
        } catch (Exception ex) {
            log.warn("Hive报表查询失败，降级为兼容查询，type={}", normalizedType, ex);
            List<Map<String, Object>> fallbackRows = queryFallbackRows(hiveJdbc, normalizedType);
            return CsvExportUtil.toCsv(fallbackRows);
        }
    }

    private List<Map<String, Object>> queryReportRows(JdbcTemplate hiveJdbc, String reportType) {
        String latestDt = getLatestDt(hiveJdbc);
        switch (reportType) {
            case "org":
                if (StringUtils.hasText(latestDt)) {
                    return hiveJdbc.queryForList(
                            "SELECT department AS `部门`, COUNT(*) AS `在职人数`, ROUND(AVG(current_salary),2) AS `平均薪资` " +
                                    "FROM dim_employee WHERE dt = ? AND status = 1 GROUP BY department ORDER BY COUNT(*) DESC",
                            latestDt);
                }
                return hiveJdbc.queryForList(
                        "SELECT department AS `部门`, COUNT(*) AS `在职人数`, ROUND(AVG(current_salary),2) AS `平均薪资` " +
                                "FROM dim_employee WHERE status = 1 GROUP BY department ORDER BY COUNT(*) DESC");
            case "salary":
                return hiveJdbc.queryForList(
                        "SELECT department AS `部门`, year AS `年份`, month AS `月份`, ROUND(SUM(total_net_salary),2) AS `实发总额` " +
                                "FROM fact_salary GROUP BY department, year, month ORDER BY year DESC, month DESC LIMIT 500");
            case "warning":
            default:
                if (StringUtils.hasText(latestDt)) {
                    return hiveJdbc.queryForList(
                            "SELECT department AS `部门`, emp_no AS `员工编号`, emp_name AS `员工姓名`, position AS `岗位`, current_salary AS `当前薪资` " +
                                    "FROM dim_employee WHERE dt = ? AND status = 1 ORDER BY current_salary ASC LIMIT 200",
                            latestDt);
                }
                return hiveJdbc.queryForList(
                        "SELECT department AS `部门`, emp_no AS `员工编号`, emp_name AS `员工姓名`, position AS `岗位`, current_salary AS `当前薪资` " +
                                "FROM dim_employee WHERE status = 1 ORDER BY current_salary ASC LIMIT 200");
        }
    }

    private List<Map<String, Object>> queryFallbackRows(JdbcTemplate hiveJdbc, String reportType) {
        if ("salary".equals(reportType)) {
            return hiveJdbc.queryForList(
                    "SELECT department AS `部门`, year AS `年份`, month AS `月份`, ROUND(SUM(total_net_salary),2) AS `实发总额` " +
                            "FROM (SELECT e.department AS department, sp.year AS year, sp.month AS month, sp.total_net_salary AS total_net_salary " +
                            "      FROM salary_payment sp JOIN employee e ON e.emp_id = sp.emp_id " +
                            "      WHERE sp.deleted = 0 AND e.deleted = 0) t " +
                            "GROUP BY department, year, month ORDER BY year DESC, month DESC");
        }
        if ("org".equals(reportType)) {
            return hiveJdbc.queryForList(
                    "SELECT department AS `部门`, COUNT(*) AS `在职人数`, ROUND(AVG(salary),2) AS `平均薪资` " +
                            "FROM employee WHERE deleted = 0 AND status = 1 GROUP BY department ORDER BY COUNT(*) DESC");
        }
        return hiveJdbc.queryForList(
                "SELECT department AS `部门`, emp_no AS `员工编号`, emp_name AS `员工姓名`, position AS `岗位`, salary AS `当前薪资` " +
                        "FROM employee WHERE deleted = 0 AND status = 1 ORDER BY salary ASC LIMIT 200");
    }

    private String getLatestDt(JdbcTemplate hiveJdbc) {
        try {
            return hiveJdbc.queryForObject("SELECT MAX(dt) FROM dim_employee", String.class);
        } catch (Exception ex) {
            return null;
        }
    }

    private Path ensureExportDir() {
        try {
            Path dir = Paths.get(exportDir);
            Files.createDirectories(dir);
            return dir;
        } catch (Exception ex) {
            throw new IllegalStateException("创建报表目录失败: " + exportDir, ex);
        }
    }

    private String buildFileName(String reportType) {
        String ts = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        return "hr_report_" + reportType + "_" + ts + ".csv";
    }

    public byte[] readReportFile(String fileName) {
        Path filePath = resolveReportFilePath(fileName);
        if (!Files.exists(filePath)) {
            throw new IllegalArgumentException("报表文件不存在: " + fileName);
        }
        try {
            return Files.readAllBytes(filePath);
        } catch (Exception ex) {
            throw new IllegalStateException("读取报表文件失败: " + filePath, ex);
        }
    }

    public boolean existsReportFile(String fileName) {
        try {
            return Files.exists(resolveReportFilePath(fileName));
        } catch (Exception ex) {
            return false;
        }
    }

    private Path resolveReportFilePath(String fileName) {
        if (!StringUtils.hasText(fileName)) {
            throw new IllegalArgumentException("文件名不能为空");
        }
        String safeFileName = Paths.get(fileName).getFileName().toString();
        Path baseDir = ensureExportDir().toAbsolutePath().normalize();
        Path targetPath = baseDir.resolve(safeFileName).normalize();
        if (!targetPath.startsWith(baseDir)) {
            throw new IllegalArgumentException("非法文件路径");
        }
        return targetPath;
    }

    @Getter
    public static class GeneratedReport {
        private final String fileName;
        private final Path filePath;
        private final String csvContent;

        public GeneratedReport(String fileName, Path filePath, String csvContent) {
            this.fileName = fileName;
            this.filePath = filePath;
            this.csvContent = csvContent;
        }
    }
}
