package com.hr.backend.service.impl;

import com.alibaba.excel.EasyExcel;
import com.alibaba.excel.ExcelWriter;
import com.alibaba.excel.write.metadata.WriteSheet;
import com.alibaba.excel.write.metadata.WriteTable;
import com.hr.backend.mapper.EmployeeProfileMapper;
import com.hr.backend.model.entity.EmployeeProfile;
import com.hr.backend.service.DataExportService;
import com.hr.backend.service.ReportTemplateService;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 数据导出服务实现类
 * <p>
 * 提供Excel和CSV格式的数据导出功能实现
 * 支持多种数据源的导出，包括分析数据、员工档案、报表等
 */
@Service
public class DataExportServiceImpl implements DataExportService {

    @Resource
    private EmployeeProfileMapper employeeProfileMapper;

    @Resource
    private JdbcTemplate jdbcTemplate;

    @Resource
    private ReportTemplateService reportTemplateService;

    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyyMMdd_HHmmss");

    /**
     * 导出员工档案数据为Excel
     */
    @Override
    public byte[] exportEmployeeProfileToExcel(Map<String, Object> filters) {
        try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            // 查询数据
            List<EmployeeProfile> dataList = employeeProfileMapper.selectList(null);

            // 应用筛选条件
            if (filters != null && !filters.isEmpty()) {
                dataList = applyFilters(dataList, filters);
            }

            // 转换为Excel友好的格式
            List<Map<String, Object>> excelData = convertToExcelData(dataList);

            // 设置表头
            List<List<String>> headers = Arrays.asList(
                    Arrays.asList("员工编号"),
                    Arrays.asList("姓名"),
                    Arrays.asList("部门"),
                    Arrays.asList("岗位"),
                    Arrays.asList("数据分类"),
                    Arrays.asList("指标值"),
                    Arrays.asList("统计周期"),
                    Arrays.asList("创建时间")
            );

            // 写入Excel
            EasyExcel.write(outputStream)
                    .head(headers)
                    .sheet("员工档案")
                    .doWrite(excelData);

            return outputStream.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("导出Excel失败：" + e.getMessage(), e);
        }
    }

    /**
     * 导出员工档案数据为CSV
     */
    @Override
    public byte[] exportEmployeeProfileToCsv(Map<String, Object> filters) {
        try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            // 查询数据
            List<EmployeeProfile> dataList = employeeProfileMapper.selectList(null);

            // 应用筛选条件
            if (filters != null && !filters.isEmpty()) {
                dataList = applyFilters(dataList, filters);
            }

            // 构建CSV内容
            StringBuilder csvContent = new StringBuilder();
            csvContent.append("员工编号,姓名,部门,岗位,数据分类,指标值,统计周期,创建时间\n");

            for (EmployeeProfile profile : dataList) {
                csvContent.append(String.format("%s,%s,%s,%s,%s,%s,%s,%s\n",
                        profile.getEmployeeNo(),
                        profile.getName(),
                        profile.getDeptName(),
                        profile.getJob(),
                        profile.getCategoryId(),
                        profile.getValue(),
                        profile.getPeriod(),
                        profile.getCreateTime()));
            }

            return csvContent.toString().getBytes(StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new RuntimeException("导出CSV失败：" + e.getMessage(), e);
        }
    }

    /**
     * 导出分析数据为Excel
     */
    @Override
    public byte[] exportAnalysisDataToExcel(Long categoryId, String period) {
        try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            // 查询分析数据
            String sql = "SELECT employee_no, name, dept_name, job, value, period, create_time " +
                    "FROM employee_profile WHERE category_id = ? AND is_deleted = 0";
            List<Object> params = new ArrayList<>();
            params.add(categoryId);

            if (period != null && !period.isEmpty()) {
                sql += " AND period = ?";
                params.add(period);
            }

            List<Map<String, Object>> dataList = jdbcTemplate.queryForList(sql, params.toArray());

            // 设置表头
            List<List<String>> headers = Arrays.asList(
                    Arrays.asList("员工编号"),
                    Arrays.asList("姓名"),
                    Arrays.asList("部门"),
                    Arrays.asList("岗位"),
                    Arrays.asList("指标值"),
                    Arrays.asList("统计周期"),
                    Arrays.asList("创建时间")
            );

            // 转换数据格式
            List<List<Object>> excelData = dataList.stream()
                    .map(row -> Arrays.asList(
                            row.get("employee_no"),
                            row.get("name"),
                            row.get("dept_name"),
                            row.get("job"),
                            row.get("value"),
                            row.get("period"),
                            row.get("create_time")
                    ))
                    .collect(Collectors.toList());

            // 写入Excel
            EasyExcel.write(outputStream)
                    .head(headers)
                    .sheet("分析数据")
                    .doWrite(excelData);

            return outputStream.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("导出分析数据Excel失败：" + e.getMessage(), e);
        }
    }

    /**
     * 导出分析数据为CSV
     */
    @Override
    public byte[] exportAnalysisDataToCsv(Long categoryId, String period) {
        try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            // 查询分析数据
            String sql = "SELECT employee_no, name, dept_name, job, value, period, create_time " +
                    "FROM employee_profile WHERE category_id = ? AND is_deleted = 0";
            List<Object> params = new ArrayList<>();
            params.add(categoryId);

            if (period != null && !period.isEmpty()) {
                sql += " AND period = ?";
                params.add(period);
            }

            List<Map<String, Object>> dataList = jdbcTemplate.queryForList(sql, params.toArray());

            // 构建CSV内容
            StringBuilder csvContent = new StringBuilder();
            csvContent.append("员工编号,姓名,部门,岗位,指标值,统计周期,创建时间\n");

            for (Map<String, Object> row : dataList) {
                csvContent.append(String.format("%s,%s,%s,%s,%s,%s,%s\n",
                        row.get("employee_no"),
                        row.get("name"),
                        row.get("dept_name"),
                        row.get("job"),
                        row.get("value"),
                        row.get("period"),
                        row.get("create_time")));
            }

            return csvContent.toString().getBytes(StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new RuntimeException("导出分析数据CSV失败：" + e.getMessage(), e);
        }
    }

    /**
     * 导出报表模板结果为Excel
     */
    @Override
    public byte[] exportReportToExcel(Long templateId, Map<String, Object> parameters) {
        try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            // 获取报表模板
            var template = reportTemplateService.getById(templateId);
            if (template == null) {
                throw new RuntimeException("报表模板不存在");
            }

            // 执行SQL查询
            String sql = template.getQuerySql();
            List<Map<String, Object>> dataList;

            if (parameters != null && !parameters.isEmpty()) {
                // 替换参数占位符
                for (Map.Entry<String, Object> entry : parameters.entrySet()) {
                    sql = sql.replace("?" + entry.getKey(), entry.getValue().toString());
                }
            }

            dataList = jdbcTemplate.queryForList(sql);

            if (dataList.isEmpty()) {
                throw new RuntimeException("报表查询结果为空");
            }

            // 动态生成表头
            List<List<String>> headers = new ArrayList<>();
            Set<String> columns = dataList.get(0).keySet();
            for (String column : columns) {
                headers.add(Arrays.asList(column));
            }

            // 转换数据
            List<List<Object>> excelData = dataList.stream()
                    .map(row -> new ArrayList<>(row.values()))
                    .collect(Collectors.toList());

            // 写入Excel
            EasyExcel.write(outputStream)
                    .head(headers)
                    .sheet(template.getName())
                    .doWrite(excelData);

            return outputStream.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("导出报表Excel失败：" + e.getMessage(), e);
        }
    }

    /**
     * 导出报表模板结果为CSV
     */
    @Override
    public byte[] exportReportToCsv(Long templateId, Map<String, Object> parameters) {
        try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            // 获取报表模板
            var template = reportTemplateService.getById(templateId);
            if (template == null) {
                throw new RuntimeException("报表模板不存在");
            }

            // 执行SQL查询
            String sql = template.getQuerySql();
            List<Map<String, Object>> dataList;

            if (parameters != null && !parameters.isEmpty()) {
                // 替换参数占位符
                for (Map.Entry<String, Object> entry : parameters.entrySet()) {
                    sql = sql.replace("?" + entry.getKey(), entry.getValue().toString());
                }
            }

            dataList = jdbcTemplate.queryForList(sql);

            if (dataList.isEmpty()) {
                throw new RuntimeException("报表查询结果为空");
            }

            // 构建CSV内容
            StringBuilder csvContent = new StringBuilder();

            // 添加表头
            Set<String> columns = dataList.get(0).keySet();
            csvContent.append(String.join(",", columns)).append("\n");

            // 添加数据行
            for (Map<String, Object> row : dataList) {
                List<String> values = columns.stream()
                        .map(column -> row.get(column) != null ? row.get(column).toString() : "")
                        .collect(Collectors.toList());
                csvContent.append(String.join(",", values)).append("\n");
            }

            return csvContent.toString().getBytes(StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new RuntimeException("导出报表CSV失败：" + e.getMessage(), e);
        }
    }

    /**
     * 导出用户数据为Excel
     */
    @Override
    public byte[] exportUsersToExcel() {
        try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            // 查询用户数据
            String sql = "SELECT username, name, role, dept_name, phone, email, status, create_time " +
                    "FROM sys_user WHERE is_deleted = 0";
            List<Map<String, Object>> dataList = jdbcTemplate.queryForList(sql);

            // 设置表头
            List<List<String>> headers = Arrays.asList(
                    Arrays.asList("工号"),
                    Arrays.asList("姓名"),
                    Arrays.asList("角色"),
                    Arrays.asList("部门"),
                    Arrays.asList("手机号"),
                    Arrays.asList("邮箱"),
                    Arrays.asList("状态"),
                    Arrays.asList("创建时间")
            );

            // 转换数据
            List<List<Object>> excelData = dataList.stream()
                    .map(row -> Arrays.asList(
                            row.get("username"),
                            row.get("name"),
                            row.get("role"),
                            row.get("dept_name"),
                            row.get("phone"),
                            row.get("email"),
                            row.get("status").equals(1) ? "启用" : "禁用",
                            row.get("create_time")
                    ))
                    .collect(Collectors.toList());

            // 写入Excel
            EasyExcel.write(outputStream)
                    .head(headers)
                    .sheet("用户列表")
                    .doWrite(excelData);

            return outputStream.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("导出用户Excel失败：" + e.getMessage(), e);
        }
    }

    /**
     * 导出部门数据为Excel
     */
    @Override
    public byte[] exportDepartmentsToExcel() {
        try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            // 查询部门数据
            String sql = "SELECT id, name, parent_id, sort_order " +
                    "FROM hr_department ORDER BY parent_id, sort_order";
            List<Map<String, Object>> dataList = jdbcTemplate.queryForList(sql);

            // 设置表头
            List<List<String>> headers = Arrays.asList(
                    Arrays.asList("部门ID"),
                    Arrays.asList("部门名称"),
                    Arrays.asList("父部门ID"),
                    Arrays.asList("排序序号")
            );

            // 转换数据
            List<List<Object>> excelData = dataList.stream()
                    .map(row -> Arrays.asList(
                            row.get("id"),
                            row.get("name"),
                            row.get("parent_id"),
                            row.get("sort_order")
                    ))
                    .collect(Collectors.toList());

            // 写入Excel
            EasyExcel.write(outputStream)
                    .head(headers)
                    .sheet("部门列表")
                    .doWrite(excelData);

            return outputStream.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("导出部门Excel失败：" + e.getMessage(), e);
        }
    }

    /**
     * 批量导出多维度数据为Excel
     */
    @Override
    public byte[] exportMultiDimensionDataToExcel(List<Long> categoryIds, String period) {
        try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            ExcelWriter excelWriter = EasyExcel.write(outputStream).build();

            // 为每个数据分类创建一个Sheet
            for (Long categoryId : categoryIds) {
                // 查询分类名称
                String categoryName = jdbcTemplate.queryForObject(
                        "SELECT name FROM hr_data_category WHERE id = ?", String.class, categoryId);

                // 查询数据
                String sql = "SELECT employee_no, name, dept_name, job, value, period " +
                        "FROM employee_profile WHERE category_id = ? AND is_deleted = 0";
                List<Object> params = new ArrayList<>();
                params.add(categoryId);

                if (period != null && !period.isEmpty()) {
                    sql += " AND period = ?";
                    params.add(period);
                }

                List<Map<String, Object>> dataList = jdbcTemplate.queryForList(sql, params.toArray());

                // 设置表头
                List<List<String>> headers = Arrays.asList(
                        Arrays.asList("员工编号"),
                        Arrays.asList("姓名"),
                        Arrays.asList("部门"),
                        Arrays.asList("岗位"),
                        Arrays.asList("指标值"),
                        Arrays.asList("统计周期")
                );

                // 转换数据
                List<List<Object>> excelData = dataList.stream()
                        .map(row -> Arrays.asList(
                                row.get("employee_no"),
                                row.get("name"),
                                row.get("dept_name"),
                                row.get("job"),
                                row.get("value"),
                                row.get("period")
                        ))
                        .collect(Collectors.toList());

                // 写入Sheet
                WriteSheet writeSheet = EasyExcel.writerSheet(categoryName).build();
                excelWriter.write(excelData, writeSheet);
            }

            excelWriter.finish();
            return outputStream.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("批量导出多维度数据Excel失败：" + e.getMessage(), e);
        }
    }

    /**
     * 应用筛选条件
     */
    private List<EmployeeProfile> applyFilters(List<EmployeeProfile> dataList, Map<String, Object> filters) {
        List<EmployeeProfile> filteredList = new ArrayList<>(dataList);

        // 按部门筛选
        if (filters.containsKey("deptId")) {
            Long deptId = Long.parseLong(filters.get("deptId").toString());
            filteredList = filteredList.stream()
                    .filter(item -> item.getDeptId() != null && item.getDeptId().equals(deptId))
                    .collect(Collectors.toList());
        }

        // 按时间周期筛选
        if (filters.containsKey("period")) {
            String period = filters.get("period").toString();
            filteredList = filteredList.stream()
                    .filter(item -> item.getPeriod() != null && item.getPeriod().equals(period))
                    .collect(Collectors.toList());
        }

        // 按岗位筛选
        if (filters.containsKey("job")) {
            String job = filters.get("job").toString();
            filteredList = filteredList.stream()
                    .filter(item -> item.getJob() != null && item.getJob().contains(job))
                    .collect(Collectors.toList());
        }

        return filteredList;
    }

    /**
     * 转换为Excel友好的数据格式
     */
    private List<Map<String, Object>> convertToExcelData(List<EmployeeProfile> dataList) {
        return dataList.stream()
                .map(profile -> {
                    Map<String, Object> row = new HashMap<>();
                    row.put("employeeNo", profile.getEmployeeNo());
                    row.put("name", profile.getName());
                    row.put("deptName", profile.getDeptName());
                    row.put("job", profile.getJob());
                    row.put("categoryId", profile.getCategoryId());
                    row.put("value", profile.getValue());
                    row.put("period", profile.getPeriod());
                    row.put("createTime", profile.getCreateTime());
                    return row;
                })
                .collect(Collectors.toList());
    }
}
