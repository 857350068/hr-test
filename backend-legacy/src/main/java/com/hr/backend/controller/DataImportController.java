package com.hr.backend.controller;

import com.hr.backend.common.Response;
import com.hr.backend.service.DataImportService;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

/**
 * 数据导入控制器
 * <p>
 * 提供Excel文件的数据导入功能
 * 支持员工档案、用户数据、部门数据等的批量导入
 */
@RestController
@RequestMapping("/api/import")
public class DataImportController {

    @Resource
    private DataImportService dataImportService;

    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyyMMdd_HHmmss");

    /**
     * 导入员工档案数据
     *
     * @param file Excel文件
     * @return 导入结果
     */
    @PostMapping("/employee-profile")
    public Response<Map<String, Object>> importEmployeeProfiles(@RequestParam("file") MultipartFile file) {
        try {
            // 验证文件
            if (file.isEmpty()) {
                return Response.error(400, "文件不能为空");
            }

            String fileName = file.getOriginalFilename();
            if (fileName == null || (!fileName.endsWith(".xlsx") && !fileName.endsWith(".xls"))) {
                return Response.error(400, "只支持Excel文件格式");
            }

            // 执行导入
            Map<String, Object> result = dataImportService.importEmployeeProfiles(file);
            return Response.success(result);

        } catch (Exception e) {
            return Response.error(500, "导入失败：" + e.getMessage());
        }
    }

    /**
     * 导入用户数据
     *
     * @param file Excel文件
     * @return 导入结果
     */
    @PostMapping("/users")
    public Response<Map<String, Object>> importUsers(@RequestParam("file") MultipartFile file) {
        try {
            // 验证文件
            if (file.isEmpty()) {
                return Response.error(400, "文件不能为空");
            }

            String fileName = file.getOriginalFilename();
            if (fileName == null || (!fileName.endsWith(".xlsx") && !fileName.endsWith(".xls"))) {
                return Response.error(400, "只支持Excel文件格式");
            }

            // 执行导入
            Map<String, Object> result = dataImportService.importUsers(file);
            return Response.success(result);

        } catch (Exception e) {
            return Response.error(500, "导入失败：" + e.getMessage());
        }
    }

    /**
     * 导入部门数据
     *
     * @param file Excel文件
     * @return 导入结果
     */
    @PostMapping("/departments")
    public Response<Map<String, Object>> importDepartments(@RequestParam("file") MultipartFile file) {
        try {
            // 验证文件
            if (file.isEmpty()) {
                return Response.error(400, "文件不能为空");
            }

            String fileName = file.getOriginalFilename();
            if (fileName == null || (!fileName.endsWith(".xlsx") && !fileName.endsWith(".xls"))) {
                return Response.error(400, "只支持Excel文件格式");
            }

            // 执行导入
            Map<String, Object> result = dataImportService.importDepartments(file);
            return Response.success(result);

        } catch (Exception e) {
            return Response.error(500, "导入失败：" + e.getMessage());
        }
    }

    /**
     * 导入分析数据
     *
     * @param file       Excel文件
     * @param categoryId 数据分类ID
     * @return 导入结果
     */
    @PostMapping("/analysis-data")
    public Response<Map<String, Object>> importAnalysisData(
            @RequestParam("file") MultipartFile file,
            @RequestParam Long categoryId) {
        try {
            // 验证文件
            if (file.isEmpty()) {
                return Response.error(400, "文件不能为空");
            }

            String fileName = file.getOriginalFilename();
            if (fileName == null || (!fileName.endsWith(".xlsx") && !fileName.endsWith(".xls"))) {
                return Response.error(400, "只支持Excel文件格式");
            }

            // 执行导入
            Map<String, Object> result = dataImportService.importAnalysisData(file, categoryId);
            return Response.success(result);

        } catch (Exception e) {
            return Response.error(500, "导入失败：" + e.getMessage());
        }
    }

    /**
     * 批量导入多维度数据
     *
     * @param file Excel文件（多个Sheet）
     * @return 导入结果
     */
    @PostMapping("/multi-dimension")
    public Response<Map<String, Object>> importMultiDimensionData(@RequestParam("file") MultipartFile file) {
        try {
            // 验证文件
            if (file.isEmpty()) {
                return Response.error(400, "文件不能为空");
            }

            String fileName = file.getOriginalFilename();
            if (fileName == null || (!fileName.endsWith(".xlsx") && !fileName.endsWith(".xls"))) {
                return Response.error(400, "只支持Excel文件格式");
            }

            // 执行导入
            Map<String, Object> result = dataImportService.importMultiDimensionData(file);
            return Response.success(result);

        } catch (Exception e) {
            return Response.error(500, "导入失败：" + e.getMessage());
        }
    }

    /**
     * 验证导入数据
     *
     * @param file     Excel文件
     * @param dataType 数据类型
     * @return 验证结果
     */
    @PostMapping("/validate")
    public Response<Map<String, Object>> validateImportData(
            @RequestParam("file") MultipartFile file,
            @RequestParam String dataType) {
        try {
            // 验证文件
            if (file.isEmpty()) {
                return Response.error(400, "文件不能为空");
            }

            String fileName = file.getOriginalFilename();
            if (fileName == null || (!fileName.endsWith(".xlsx") && !fileName.endsWith(".xls"))) {
                return Response.error(400, "只支持Excel文件格式");
            }

            // 执行验证
            Map<String, Object> result = dataImportService.validateImportData(file, dataType);
            return Response.success(result);

        } catch (Exception e) {
            return Response.error(500, "验证失败：" + e.getMessage());
        }
    }

    /**
     * 下载导入模板
     *
     * @param response HTTP响应
     * @param dataType 数据类型（employee_profile/user/department）
     */
    @GetMapping("/template/{dataType}")
    public void downloadImportTemplate(
            HttpServletResponse response,
            @PathVariable String dataType) {

        try {
            // 生成文件名
            String fileName = dataType + "_导入模板_" + DATE_FORMAT.format(new Date()) + ".xlsx";

            // 设置响应头
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setCharacterEncoding("utf-8");
            response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + URLEncoder.encode(fileName, StandardCharsets.UTF_8));

            // 生成模板
            byte[] template = dataImportService.getImportTemplate(dataType);
            OutputStream outputStream = response.getOutputStream();
            outputStream.write(template);
            outputStream.flush();

        } catch (IOException e) {
            throw new RuntimeException("下载模板失败：" + e.getMessage());
        }
    }

    /**
     * 获取支持的数据类型列表
     *
     * @return 数据类型列表
     */
    @GetMapping("/data-types")
    public Response<Map<String, Object>> getSupportedDataTypes() {
        Map<String, Object> result = new java.util.HashMap<>();

        java.util.List<Map<String, String>> dataTypes = new java.util.ArrayList<>();

        Map<String, String> employeeProfile = new java.util.HashMap<>();
        employeeProfile.put("code", "employee_profile");
        employeeProfile.put("name", "员工档案");
        employeeProfile.put("description", "员工基本信息和分析数据");
        dataTypes.add(employeeProfile);

        Map<String, String> user = new java.util.HashMap<>();
        user.put("code", "user");
        user.put("name", "用户数据");
        user.put("description", "系统用户账号信息");
        dataTypes.add(user);

        Map<String, String> department = new java.util.HashMap<>();
        department.put("code", "department");
        department.put("name", "部门数据");
        department.put("description", "组织架构部门信息");
        dataTypes.add(department);

        result.put("dataTypes", dataTypes);
        result.put("message", "获取成功");

        return Response.success(result);
    }
}
