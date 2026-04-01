package com.hr.datacenter.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.Employee;
import com.hr.datacenter.service.EmployeeService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

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
}
