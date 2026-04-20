package com.hr.datacenter.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.hr.datacenter.annotation.OperationLog;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.Employee;
import com.hr.datacenter.service.EmployeeService;
import com.hr.datacenter.util.CsvExportUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 员工控制器
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/employee")
@CrossOrigin(origins = "*")
public class EmployeeController {

    private static final Logger log = LoggerFactory.getLogger(EmployeeController.class);

    @Autowired
    private EmployeeService employeeService;

    /**
     * 分页查询员工列表
     */
    @GetMapping("/list")
    @OperationLog(module = "员工管理", type = "查询", description = "查询员工列表")
    public Result<IPage<Employee>> getEmployeeList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String keyword) {
        log.info("查询员工列表: page={}, size={}, keyword={}", page, size, keyword);
        IPage<Employee> employeePage = employeeService.getEmployeePage(page, size, keyword);
        return Result.success(employeePage);
    }

    /**
     * 根据ID查询员工
     */
    @GetMapping("/{id}")
    public Result<Employee> getEmployeeById(@PathVariable Long id) {
        log.info("查询员工详情: id={}", id);
        Employee employee = employeeService.getEmployeeById(id);
        if (employee == null) {
            return Result.error("员工不存在");
        }
        return Result.success(employee);
    }

    /**
     * 新增员工
     */
    @PostMapping("/add")
    @OperationLog(module = "员工管理", type = "新增", description = "新增员工信息")
    public Result<String> addEmployee(@RequestBody Employee employee) {
        log.info("新增员工: {}", employee.getEmpName());
        boolean success = employeeService.addEmployee(employee);
        if (success) {
            return Result.success("新增成功", "");
        }
        return Result.error("新增失败");
    }

    /**
     * 更新员工
     */
    @PutMapping("/update")
    @OperationLog(module = "员工管理", type = "更新", description = "更新员工信息")
    public Result<String> updateEmployee(@RequestBody Employee employee) {
        log.info("更新员工: id={}, name={}", employee.getEmpId(), employee.getEmpName());
        boolean success = employeeService.updateEmployee(employee);
        if (success) {
            return Result.success("更新成功", "");
        }
        return Result.error("更新失败");
    }

    /**
     * 删除员工
     */
    @DeleteMapping("/delete/{id}")
    @OperationLog(module = "员工管理", type = "删除", description = "删除员工信息")
    public Result<String> deleteEmployee(@PathVariable Long id) {
        log.info("删除员工: id={}", id);
        boolean success = employeeService.deleteEmployee(id);
        if (success) {
            return Result.success("删除成功", "");
        }
        return Result.error("删除失败");
    }

    /**
     * 获取员工总数
     */
    @GetMapping("/total")
    public Result<Long> getTotalCount() {
        long totalCount = employeeService.getTotalCount();
        return Result.success(totalCount);
    }

    @GetMapping("/dashboard-stats")
    public Result<Map<String, Object>> getDashboardStats() {
        return Result.success(employeeService.getDashboardStats());
    }

    /**
     * 批量导入员工
     */
    @PostMapping("/batch-import")
    public Result<BatchImportResult> batchImport(@RequestBody java.util.List<Employee> employees) {
        log.info("批量导入员工: 数量={}", employees.size());
        try {
            BatchImportResult result = employeeService.batchImport(employees);
            return Result.success(result);
        } catch (Exception e) {
            log.error("批量导入失败", e);
            return Result.error("批量导入失败: " + e.getMessage());
        }
    }

    /**
     * 导出员工数据（按关键词筛选）
     */
    @GetMapping("/export")
    @OperationLog(module = "员工管理", type = "导出", description = "导出员工数据")
    public ResponseEntity<byte[]> exportEmployees(@RequestParam(required = false) String keyword) {
        List<Employee> employees = employeeService.listByKeyword(keyword);
        List<Map<String, Object>> rows = new ArrayList<>();
        for (Employee e : employees) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("员工编号", e.getEmpNo());
            row.put("员工姓名", e.getEmpName());
            row.put("性别", e.getGender() != null && e.getGender() == 1 ? "男" : "女");
            row.put("部门", e.getDepartment());
            row.put("职位", e.getPosition());
            row.put("联系电话", e.getPhone());
            row.put("邮箱", e.getEmail());
            row.put("薪资", e.getSalary());
            row.put("状态", e.getStatus() == null ? "" : (e.getStatus() == 1 ? "在职" : (e.getStatus() == 2 ? "试用" : "离职")));
            row.put("入职日期", e.getHireDate());
            row.put("学历", e.getEducation());
            rows.add(row);
        }
        String csv = CsvExportUtil.toCsv(rows);
        String filename = CsvExportUtil.buildFileName("employee_export");
        return CsvExportUtil.buildCsvResponse(filename, csv);
    }

    /**
     * 批量导入结果
     */
    public static class BatchImportResult {
        private int successCount;
        private int failCount;
        private java.util.List<String> failReasons;

        public BatchImportResult(int successCount, int failCount, java.util.List<String> failReasons) {
            this.successCount = successCount;
            this.failCount = failCount;
            this.failReasons = failReasons;
        }

        public int getSuccessCount() {
            return successCount;
        }

        public void setSuccessCount(int successCount) {
            this.successCount = successCount;
        }

        public int getFailCount() {
            return failCount;
        }

        public void setFailCount(int failCount) {
            this.failCount = failCount;
        }

        public java.util.List<String> getFailReasons() {
            return failReasons;
        }

        public void setFailReasons(java.util.List<String> failReasons) {
            this.failReasons = failReasons;
        }
    }
}
