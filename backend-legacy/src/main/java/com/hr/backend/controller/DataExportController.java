package com.hr.backend.controller;

import com.hr.backend.common.Response;
import com.hr.backend.service.DataExportService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * 数据导出控制器
 * <p>
 * 提供各种数据的Excel和CSV格式导出功能
 * 支持员工档案、分析数据、报表模板等的导出
 */
@RestController
@RequestMapping("/api/export")
public class DataExportController {

    @Resource
    private DataExportService dataExportService;

    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyyMMdd_HHmmss");

    /**
     * 导出员工档案数据为Excel
     *
     * @param response HTTP响应
     * @param deptId   部门ID（可选）
     * @param period   时间周期（可选）
     * @param job      岗位（可选）
     */
    @GetMapping("/employee-profile/excel")
    public void exportEmployeeProfileToExcel(
            HttpServletResponse response,
            @RequestParam(required = false) Long deptId,
            @RequestParam(required = false) String period,
            @RequestParam(required = false) String job) {

        try {
            // 构建筛选条件
            Map<String, Object> filters = new HashMap<>();
            if (deptId != null) {
                filters.put("deptId", deptId);
            }
            if (period != null && !period.isEmpty()) {
                filters.put("period", period);
            }
            if (job != null && !job.isEmpty()) {
                filters.put("job", job);
            }

            // 生成文件名
            String fileName = "员工档案_" + DATE_FORMAT.format(new Date()) + ".xlsx";

            // 设置响应头
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setCharacterEncoding("utf-8");
            response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + URLEncoder.encode(fileName, StandardCharsets.UTF_8));

            // 导出数据
            byte[] data = dataExportService.exportEmployeeProfileToExcel(filters);
            OutputStream outputStream = response.getOutputStream();
            outputStream.write(data);
            outputStream.flush();

        } catch (IOException e) {
            throw new RuntimeException("导出失败：" + e.getMessage());
        }
    }

    /**
     * 导出员工档案数据为CSV
     *
     * @param response HTTP响应
     * @param deptId   部门ID（可选）
     * @param period   时间周期（可选）
     * @param job      岗位（可选）
     */
    @GetMapping("/employee-profile/csv")
    public void exportEmployeeProfileToCsv(
            HttpServletResponse response,
            @RequestParam(required = false) Long deptId,
            @RequestParam(required = false) String period,
            @RequestParam(required = false) String job) {

        try {
            // 构建筛选条件
            Map<String, Object> filters = new HashMap<>();
            if (deptId != null) {
                filters.put("deptId", deptId);
            }
            if (period != null && !period.isEmpty()) {
                filters.put("period", period);
            }
            if (job != null && !job.isEmpty()) {
                filters.put("job", job);
            }

            // 生成文件名
            String fileName = "员工档案_" + DATE_FORMAT.format(new Date()) + ".csv";

            // 设置响应头
            response.setContentType("text/csv");
            response.setCharacterEncoding("utf-8");
            response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + URLEncoder.encode(fileName, StandardCharsets.UTF_8));

            // 导出数据
            byte[] data = dataExportService.exportEmployeeProfileToCsv(filters);
            OutputStream outputStream = response.getOutputStream();
            outputStream.write(data);
            outputStream.flush();

        } catch (IOException e) {
            throw new RuntimeException("导出失败：" + e.getMessage());
        }
    }

    /**
     * 导出分析数据为Excel
     *
     * @param response   HTTP响应
     * @param categoryId 数据分类ID
     * @param period     时间周期（可选）
     */
    @GetMapping("/analysis-data/excel")
    public void exportAnalysisDataToExcel(
            HttpServletResponse response,
            @RequestParam Long categoryId,
            @RequestParam(required = false) String period) {

        try {
            // 生成文件名
            String fileName = "分析数据_" + categoryId + "_" + DATE_FORMAT.format(new Date()) + ".xlsx";

            // 设置响应头
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setCharacterEncoding("utf-8");
            response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + URLEncoder.encode(fileName, StandardCharsets.UTF_8));

            // 导出数据
            byte[] data = dataExportService.exportAnalysisDataToExcel(categoryId, period);
            OutputStream outputStream = response.getOutputStream();
            outputStream.write(data);
            outputStream.flush();

        } catch (IOException e) {
            throw new RuntimeException("导出失败：" + e.getMessage());
        }
    }

    /**
     * 导出分析数据为CSV
     *
     * @param response   HTTP响应
     * @param categoryId 数据分类ID
     * @param period     时间周期（可选）
     */
    @GetMapping("/analysis-data/csv")
    public void exportAnalysisDataToCsv(
            HttpServletResponse response,
            @RequestParam Long categoryId,
            @RequestParam(required = false) String period) {

        try {
            // 生成文件名
            String fileName = "分析数据_" + categoryId + "_" + DATE_FORMAT.format(new Date()) + ".csv";

            // 设置响应头
            response.setContentType("text/csv");
            response.setCharacterEncoding("utf-8");
            response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + URLEncoder.encode(fileName, StandardCharsets.UTF_8));

            // 导出数据
            byte[] data = dataExportService.exportAnalysisDataToCsv(categoryId, period);
            OutputStream outputStream = response.getOutputStream();
            outputStream.write(data);
            outputStream.flush();

        } catch (IOException e) {
            throw new RuntimeException("导出失败：" + e.getMessage());
        }
    }

    /**
     * 导出报表为Excel
     *
     * @param response   HTTP响应
     * @param templateId 报表模板ID
     * @param parameters 报表参数（JSON格式）
     */
    @GetMapping("/report/excel")
    public void exportReportToExcel(
            HttpServletResponse response,
            @RequestParam Long templateId,
            @RequestParam(required = false) String parameters) {

        try {
            // 解析参数
            Map<String, Object> params = new HashMap<>();
            if (parameters != null && !parameters.isEmpty()) {
                // 简单的JSON解析，实际项目中应该使用Jackson或Gson
                String[] pairs = parameters.split(",");
                for (String pair : pairs) {
                    String[] kv = pair.split(":");
                    if (kv.length == 2) {
                        params.put(kv[0].trim(), kv[1].trim());
                    }
                }
            }

            // 生成文件名
            String fileName = "报表_" + templateId + "_" + DATE_FORMAT.format(new Date()) + ".xlsx";

            // 设置响应头
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setCharacterEncoding("utf-8");
            response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + URLEncoder.encode(fileName, StandardCharsets.UTF_8));

            // 导出数据
            byte[] data = dataExportService.exportReportToExcel(templateId, params);
            OutputStream outputStream = response.getOutputStream();
            outputStream.write(data);
            outputStream.flush();

        } catch (IOException e) {
            throw new RuntimeException("导出失败：" + e.getMessage());
        }
    }

    /**
     * 导出报表为CSV
     *
     * @param response   HTTP响应
     * @param templateId 报表模板ID
     * @param parameters 报表参数（JSON格式）
     */
    @GetMapping("/report/csv")
    public void exportReportToCsv(
            HttpServletResponse response,
            @RequestParam Long templateId,
            @RequestParam(required = false) String parameters) {

        try {
            // 解析参数
            Map<String, Object> params = new HashMap<>();
            if (parameters != null && !parameters.isEmpty()) {
                String[] pairs = parameters.split(",");
                for (String pair : pairs) {
                    String[] kv = pair.split(":");
                    if (kv.length == 2) {
                        params.put(kv[0].trim(), kv[1].trim());
                    }
                }
            }

            // 生成文件名
            String fileName = "报表_" + templateId + "_" + DATE_FORMAT.format(new Date()) + ".csv";

            // 设置响应头
            response.setContentType("text/csv");
            response.setCharacterEncoding("utf-8");
            response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + URLEncoder.encode(fileName, StandardCharsets.UTF_8));

            // 导出数据
            byte[] data = dataExportService.exportReportToCsv(templateId, params);
            OutputStream outputStream = response.getOutputStream();
            outputStream.write(data);
            outputStream.flush();

        } catch (IOException e) {
            throw new RuntimeException("导出失败：" + e.getMessage());
        }
    }

    /**
     * 导出用户数据为Excel
     *
     * @param response HTTP响应
     */
    @GetMapping("/users/excel")
    public void exportUsersToExcel(HttpServletResponse response) {
        try {
            // 生成文件名
            String fileName = "用户列表_" + DATE_FORMAT.format(new Date()) + ".xlsx";

            // 设置响应头
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setCharacterEncoding("utf-8");
            response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + URLEncoder.encode(fileName, StandardCharsets.UTF_8));

            // 导出数据
            byte[] data = dataExportService.exportUsersToExcel();
            OutputStream outputStream = response.getOutputStream();
            outputStream.write(data);
            outputStream.flush();

        } catch (IOException e) {
            throw new RuntimeException("导出失败：" + e.getMessage());
        }
    }

    /**
     * 导出部门数据为Excel
     *
     * @param response HTTP响应
     */
    @GetMapping("/departments/excel")
    public void exportDepartmentsToExcel(HttpServletResponse response) {
        try {
            // 生成文件名
            String fileName = "部门列表_" + DATE_FORMAT.format(new Date()) + ".xlsx";

            // 设置响应头
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setCharacterEncoding("utf-8");
            response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + URLEncoder.encode(fileName, StandardCharsets.UTF_8));

            // 导出数据
            byte[] data = dataExportService.exportDepartmentsToExcel();
            OutputStream outputStream = response.getOutputStream();
            outputStream.write(data);
            outputStream.flush();

        } catch (IOException e) {
            throw new RuntimeException("导出失败：" + e.getMessage());
        }
    }

    /**
     * 批量导出多维度数据为Excel
     *
     * @param response    HTTP响应
     * @param categoryIds 数据分类ID列表（逗号分隔）
     * @param period      时间周期（可选）
     */
    @GetMapping("/multi-dimension/excel")
    public void exportMultiDimensionDataToExcel(
            HttpServletResponse response,
            @RequestParam String categoryIds,
            @RequestParam(required = false) String period) {

        try {
            // 解析分类ID列表
            List<Long> categoryIdList = new ArrayList<>();
            String[] ids = categoryIds.split(",");
            for (String id : ids) {
                categoryIdList.add(Long.parseLong(id.trim()));
            }

            // 生成文件名
            String fileName = "多维度数据_" + DATE_FORMAT.format(new Date()) + ".xlsx";

            // 设置响应头
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setCharacterEncoding("utf-8");
            response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + URLEncoder.encode(fileName, StandardCharsets.UTF_8));

            // 导出数据
            byte[] data = dataExportService.exportMultiDimensionDataToExcel(categoryIdList, period);
            OutputStream outputStream = response.getOutputStream();
            outputStream.write(data);
            outputStream.flush();

        } catch (IOException e) {
            throw new RuntimeException("导出失败：" + e.getMessage());
        }
    }

    /**
     * 获取可用的导出格式列表
     *
     * @return 导出格式列表
     */
    @GetMapping("/formats")
    public Response<List<Map<String, String>>> getExportFormats() {
        List<Map<String, String>> formats = new ArrayList<>();

        Map<String, String> excel = new HashMap<>();
        excel.put("code", "excel");
        excel.put("name", "Excel格式");
        excel.put("extension", ".xlsx");
        excel.put("description", "支持复杂格式，适合数据分析");
        formats.add(excel);

        Map<String, String> csv = new HashMap<>();
        csv.put("code", "csv");
        csv.put("name", "CSV格式");
        csv.put("extension", ".csv");
        csv.put("description", "纯文本格式，适合数据交换");
        formats.add(csv);

        return Response.success(formats);
    }
}
