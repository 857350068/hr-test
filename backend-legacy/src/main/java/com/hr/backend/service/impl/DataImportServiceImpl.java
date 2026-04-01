package com.hr.backend.service.impl;

import com.alibaba.excel.EasyExcel;
import com.alibaba.excel.context.AnalysisContext;
import com.alibaba.excel.event.AnalysisEventListener;
import com.hr.backend.mapper.EmployeeProfileMapper;
import com.hr.backend.model.entity.EmployeeProfile;
import com.hr.backend.service.DataImportService;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * 数据导入服务实现类
 * <p>
 * 提供Excel文件的数据导入功能实现
 * 支持员工档案、用户数据等的批量导入
 */
@Service
public class DataImportServiceImpl implements DataImportService {

    @Resource
    private EmployeeProfileMapper employeeProfileMapper;

    @Resource
    private JdbcTemplate jdbcTemplate;

    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    /**
     * 导入员工档案数据
     */
    @Override
    public Map<String, Object> importEmployeeProfiles(MultipartFile file) {
        Map<String, Object> result = new HashMap<>();
        List<EmployeeProfile> successList = new ArrayList<>();
        List<String> errorList = new ArrayList<>();

        try {
            // 读取Excel文件
            EasyExcel.read(file.getInputStream(), Map.class, new AnalysisEventListener<Map>() {
                @Override
                public void invoke(Map data, AnalysisContext context) {
                    try {
                        // 解析数据
                        EmployeeProfile profile = new EmployeeProfile();
                        profile.setEmployeeNo((String) data.get("员工编号"));
                        profile.setName((String) data.get("姓名"));
                        profile.setDeptName((String) data.get("部门"));
                        profile.setJob((String) data.get("岗位"));
                        profile.setCategoryId(parseLong(data.get("数据分类")));
                        profile.setValue(parseDouble(data.get("指标值")));
                        profile.setPeriod((String) data.get("统计周期"));
                        profile.setCreateTime(new Date());

                        // 查询部门ID
                        if (profile.getDeptName() != null) {
                            Long deptId = jdbcTemplate.queryForObject(
                                    "SELECT id FROM hr_department WHERE name = ?", Long.class, profile.getDeptName());
                            profile.setDeptId(deptId);
                        }

                        // 保存到数据库
                        employeeProfileMapper.insert(profile);
                        successList.add(profile);

                    } catch (Exception e) {
                        errorList.add("第" + (context.readRowHolder().getRowIndex() + 1) + "行: " + e.getMessage());
                    }
                }

                @Override
                public void doAfterAllAnalysed(AnalysisContext context) {
                    // 导入完成后的处理
                }
            }).sheet().doRead();

            // 构建结果
            result.put("success", true);
            result.put("successCount", successList.size());
            result.put("errorCount", errorList.size());
            result.put("errors", errorList);

            if (!errorList.isEmpty()) {
                result.put("message", "导入完成，但有" + errorList.size() + "条数据失败");
            } else {
                result.put("message", "导入成功，共导入" + successList.size() + "条数据");
            }

        } catch (IOException e) {
            result.put("success", false);
            result.put("message", "文件读取失败：" + e.getMessage());
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "导入失败：" + e.getMessage());
        }

        return result;
    }

    /**
     * 导入用户数据
     */
    @Override
    public Map<String, Object> importUsers(MultipartFile file) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> successList = new ArrayList<>();
        List<String> errorList = new ArrayList<>();

        try {
            EasyExcel.read(file.getInputStream(), Map.class, new AnalysisEventListener<Map>() {
                @Override
                public void invoke(Map data, AnalysisContext context) {
                    try {
                        // 检查必填字段
                        String username = (String) data.get("工号");
                        String name = (String) data.get("姓名");
                        String role = (String) data.get("角色");

                        if (username == null || name == null || role == null) {
                            throw new RuntimeException("工号、姓名、角色不能为空");
                        }

                        // 检查用户是否已存在
                        Integer count = jdbcTemplate.queryForObject(
                                "SELECT COUNT(*) FROM sys_user WHERE username = ?", Integer.class, username);
                        if (count > 0) {
                            throw new RuntimeException("工号已存在");
                        }

                        // 插入用户数据
                        String sql = "INSERT INTO sys_user (username, password, name, role, dept_name, phone, email, status, create_time) " +
                                "VALUES (?, ?, ?, ?, ?, ?, ?, 1, NOW())";
                        jdbcTemplate.update(sql,
                                username,
                                "$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG", // 默认密码123456
                                name,
                                role,
                                data.get("部门"),
                                data.get("手机号"),
                                data.get("邮箱"));

                        successList.add(data);

                    } catch (Exception e) {
                        errorList.add("第" + (context.readRowHolder().getRowIndex() + 1) + "行: " + e.getMessage());
                    }
                }

                @Override
                public void doAfterAllAnalysed(AnalysisContext context) {
                    // 导入完成后的处理
                }
            }).sheet().doRead();

            // 构建结果
            result.put("success", true);
            result.put("successCount", successList.size());
            result.put("errorCount", errorList.size());
            result.put("errors", errorList);

            if (!errorList.isEmpty()) {
                result.put("message", "导入完成，但有" + errorList.size() + "条数据失败");
            } else {
                result.put("message", "导入成功，共导入" + successList.size() + "条数据");
            }

        } catch (IOException e) {
            result.put("success", false);
            result.put("message", "文件读取失败：" + e.getMessage());
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "导入失败：" + e.getMessage());
        }

        return result;
    }

    /**
     * 导入部门数据
     */
    @Override
    public Map<String, Object> importDepartments(MultipartFile file) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> successList = new ArrayList<>();
        List<String> errorList = new ArrayList<>();

        try {
            EasyExcel.read(file.getInputStream(), Map.class, new AnalysisEventListener<Map>() {
                @Override
                public void invoke(Map data, AnalysisContext context) {
                    try {
                        String name = (String) data.get("部门名称");
                        if (name == null || name.trim().isEmpty()) {
                            throw new RuntimeException("部门名称不能为空");
                        }

                        // 检查部门是否已存在
                        Integer count = jdbcTemplate.queryForObject(
                                "SELECT COUNT(*) FROM hr_department WHERE name = ?", Integer.class, name);
                        if (count > 0) {
                            throw new RuntimeException("部门已存在");
                        }

                        // 插入部门数据
                        String sql = "INSERT INTO hr_department (name, parent_id, sort_order) VALUES (?, ?, ?)";
                        jdbcTemplate.update(sql,
                                name,
                                parseLong(data.get("父部门ID")),
                                parseInteger(data.get("排序序号")));

                        successList.add(data);

                    } catch (Exception e) {
                        errorList.add("第" + (context.readRowHolder().getRowIndex() + 1) + "行: " + e.getMessage());
                    }
                }

                @Override
                public void doAfterAllAnalysed(AnalysisContext context) {
                    // 导入完成后的处理
                }
            }).sheet().doRead();

            // 构建结果
            result.put("success", true);
            result.put("successCount", successList.size());
            result.put("errorCount", errorList.size());
            result.put("errors", errorList);

            if (!errorList.isEmpty()) {
                result.put("message", "导入完成，但有" + errorList.size() + "条数据失败");
            } else {
                result.put("message", "导入成功，共导入" + successList.size() + "条数据");
            }

        } catch (IOException e) {
            result.put("success", false);
            result.put("message", "文件读取失败：" + e.getMessage());
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "导入失败：" + e.getMessage());
        }

        return result;
    }

    /**
     * 导入分析数据
     */
    @Override
    public Map<String, Object> importAnalysisData(MultipartFile file, Long categoryId) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> successList = new ArrayList<>();
        List<String> errorList = new ArrayList<>();

        try {
            EasyExcel.read(file.getInputStream(), Map.class, new AnalysisEventListener<Map>() {
                @Override
                public void invoke(Map data, AnalysisContext context) {
                    try {
                        String employeeNo = (String) data.get("员工编号");
                        String name = (String) data.get("姓名");

                        if (employeeNo == null || name == null) {
                            throw new RuntimeException("员工编号和姓名不能为空");
                        }

                        // 查询员工是否存在
                        Integer count = jdbcTemplate.queryForObject(
                                "SELECT COUNT(*) FROM sys_user WHERE username = ?", Integer.class, employeeNo);
                        if (count == 0) {
                            throw new RuntimeException("员工不存在");
                        }

                        // 插入分析数据
                        String sql = "INSERT INTO employee_profile (employee_no, name, dept_id, dept_name, job, category_id, value, period, create_time) " +
                                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())";
                        jdbcTemplate.update(sql,
                                employeeNo,
                                name,
                                data.get("部门ID"),
                                data.get("部门"),
                                data.get("岗位"),
                                categoryId,
                                parseDouble(data.get("指标值")),
                                data.get("统计周期"));

                        successList.add(data);

                    } catch (Exception e) {
                        errorList.add("第" + (context.readRowHolder().getRowIndex() + 1) + "行: " + e.getMessage());
                    }
                }

                @Override
                public void doAfterAllAnalysed(AnalysisContext context) {
                    // 导入完成后的处理
                }
            }).sheet().doRead();

            // 构建结果
            result.put("success", true);
            result.put("successCount", successList.size());
            result.put("errorCount", errorList.size());
            result.put("errors", errorList);

            if (!errorList.isEmpty()) {
                result.put("message", "导入完成，但有" + errorList.size() + "条数据失败");
            } else {
                result.put("message", "导入成功，共导入" + successList.size() + "条数据");
            }

        } catch (IOException e) {
            result.put("success", false);
            result.put("message", "文件读取失败：" + e.getMessage());
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "导入失败：" + e.getMessage());
        }

        return result;
    }

    /**
     * 批量导入多维度数据
     */
    @Override
    public Map<String, Object> importMultiDimensionData(MultipartFile file) {
        Map<String, Object> result = new HashMap<>();
        List<String> successSheets = new ArrayList<>();
        List<String> errorSheets = new ArrayList<>();

        try {
            // 读取多个Sheet
            EasyExcel.read(file.getInputStream(), new AnalysisEventListener<Map>() {
                @Override
                public void invoke(Map data, AnalysisContext context) {
                    // 每个Sheet的数据处理
                }

                @Override
                public void doAfterAllAnalysed(AnalysisContext context) {
                    String sheetName = context.readSheetHolder().getSheetName();
                    successSheets.add(sheetName);
                }
            }).doReadAll();

            result.put("success", true);
            result.put("successSheets", successSheets);
            result.put("errorSheets", errorSheets);
            result.put("message", "批量导入完成");

        } catch (IOException e) {
            result.put("success", false);
            result.put("message", "文件读取失败：" + e.getMessage());
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "导入失败：" + e.getMessage());
        }

        return result;
    }

    /**
     * 验证导入数据
     */
    @Override
    public Map<String, Object> validateImportData(MultipartFile file, String dataType) {
        Map<String, Object> result = new HashMap<>();
        List<String> errors = new ArrayList<>();

        try {
            EasyExcel.read(file.getInputStream(), Map.class, new AnalysisEventListener<Map>() {
                @Override
                public void invoke(Map data, AnalysisContext context) {
                    try {
                        // 根据数据类型验证
                        switch (dataType) {
                            case "employee_profile":
                                validateEmployeeProfile(data);
                                break;
                            case "user":
                                validateUserData(data);
                                break;
                            case "department":
                                validateDepartmentData(data);
                                break;
                            default:
                                throw new RuntimeException("不支持的数据类型");
                        }
                    } catch (Exception e) {
                        errors.add("第" + (context.readRowHolder().getRowIndex() + 1) + "行: " + e.getMessage());
                    }
                }

                @Override
                public void doAfterAllAnalysed(AnalysisContext context) {
                    // 验证完成后的处理
                }
            }).sheet().doRead();

            result.put("valid", errors.isEmpty());
            result.put("errors", errors);

            if (!errors.isEmpty()) {
                result.put("message", "数据验证失败，发现" + errors.size() + "个错误");
            } else {
                result.put("message", "数据验证通过");
            }

        } catch (IOException e) {
            result.put("valid", false);
            result.put("message", "文件读取失败：" + e.getMessage());
        } catch (Exception e) {
            result.put("valid", false);
            result.put("message", "验证失败：" + e.getMessage());
        }

        return result;
    }

    /**
     * 获取导入模板
     */
    @Override
    public byte[] getImportTemplate(String dataType) {
        try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            List<List<String>> headers = new ArrayList<>();

            switch (dataType) {
                case "employee_profile":
                    headers = Arrays.asList(
                            Arrays.asList("员工编号"),
                            Arrays.asList("姓名"),
                            Arrays.asList("部门"),
                            Arrays.asList("岗位"),
                            Arrays.asList("数据分类"),
                            Arrays.asList("指标值"),
                            Arrays.asList("统计周期")
                    );
                    break;
                case "user":
                    headers = Arrays.asList(
                            Arrays.asList("工号"),
                            Arrays.asList("姓名"),
                            Arrays.asList("角色"),
                            Arrays.asList("部门"),
                            Arrays.asList("手机号"),
                            Arrays.asList("邮箱")
                    );
                    break;
                case "department":
                    headers = Arrays.asList(
                            Arrays.asList("部门名称"),
                            Arrays.asList("父部门ID"),
                            Arrays.asList("排序序号")
                    );
                    break;
                default:
                    throw new RuntimeException("不支持的数据类型");
            }

            // 写入模板
            EasyExcel.write(outputStream)
                    .head(headers)
                    .sheet("模板")
                    .doWrite(new ArrayList<>());

            return outputStream.toByteArray();

        } catch (Exception e) {
            throw new RuntimeException("生成模板失败：" + e.getMessage());
        }
    }

    /**
     * 验证员工档案数据
     */
    private void validateEmployeeProfile(Map data) {
        if (data.get("员工编号") == null) {
            throw new RuntimeException("员工编号不能为空");
        }
        if (data.get("姓名") == null) {
            throw new RuntimeException("姓名不能为空");
        }
        if (data.get("数据分类") == null) {
            throw new RuntimeException("数据分类不能为空");
        }
        if (data.get("指标值") == null) {
            throw new RuntimeException("指标值不能为空");
        }
    }

    /**
     * 验证用户数据
     */
    private void validateUserData(Map data) {
        if (data.get("工号") == null) {
            throw new RuntimeException("工号不能为空");
        }
        if (data.get("姓名") == null) {
            throw new RuntimeException("姓名不能为空");
        }
        if (data.get("角色") == null) {
            throw new RuntimeException("角色不能为空");
        }
    }

    /**
     * 验证部门数据
     */
    private void validateDepartmentData(Map data) {
        if (data.get("部门名称") == null) {
            throw new RuntimeException("部门名称不能为空");
        }
    }

    /**
     * 解析Long类型
     */
    private Long parseLong(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number) {
            return ((Number) value).longValue();
        }
        return Long.parseLong(value.toString());
    }

    /**
     * 解析Integer类型
     */
    private Integer parseInteger(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        return Integer.parseInt(value.toString());
    }

    /**
     * 解析Double类型
     */
    private Double parseDouble(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number) {
            return ((Number) value).doubleValue();
        }
        return Double.parseDouble(value.toString());
    }
}
