package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.Employee;
import com.hr.datacenter.mapper.mysql.EmployeeMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * 员工Service
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class EmployeeService extends ServiceImpl<EmployeeMapper, Employee> {

    /**
     * 分页查询员工列表
     */
    public IPage<Employee> getEmployeePage(int page, int size, String keyword) {
        Page<Employee> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Employee> wrapper = new LambdaQueryWrapper<>();

        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(Employee::getEmpName, keyword)
                    .or().like(Employee::getEmpNo, keyword)
                    .or().like(Employee::getDepartment, keyword));
        }

        wrapper.orderByDesc(Employee::getCreateTime);
        return this.page(pageParam, wrapper);
    }

    /**
     * 根据ID查询员工
     */
    public Employee getEmployeeById(Long empId) {
        return this.getById(empId);
    }

    /**
     * 新增员工
     */
    public boolean addEmployee(Employee employee) {
        return this.save(employee);
    }

    /**
     * 更新员工
     */
    public boolean updateEmployee(Employee employee) {
        return this.updateById(employee);
    }

    /**
     * 删除员工
     */
    public boolean deleteEmployee(Long empId) {
        return this.removeById(empId);
    }

    /**
     * 获取员工总数
     */
    public long getTotalCount() {
        return this.count();
    }

    /**
     * 批量导入员工
     */
    public com.hr.datacenter.controller.EmployeeController.BatchImportResult batchImport(java.util.List<Employee> employees) {
        int successCount = 0;
        int failCount = 0;
        java.util.List<String> failReasons = new java.util.ArrayList<>();

        for (int i = 0; i < employees.size(); i++) {
            try {
                Employee employee = employees.get(i);

                // 数据校验
                if (employee.getEmpNo() == null || employee.getEmpNo().isEmpty()) {
                    failCount++;
                    failReasons.add("第" + (i + 1) + "条: 员工编号不能为空");
                    continue;
                }

                if (employee.getEmpName() == null || employee.getEmpName().isEmpty()) {
                    failCount++;
                    failReasons.add("第" + (i + 1) + "条: 员工姓名不能为空");
                    continue;
                }

                // 检查员工编号是否已存在
                LambdaQueryWrapper<Employee> wrapper = new LambdaQueryWrapper<>();
                wrapper.eq(Employee::getEmpNo, employee.getEmpNo());
                if (this.count(wrapper) > 0) {
                    failCount++;
                    failReasons.add("第" + (i + 1) + "条: 员工编号 " + employee.getEmpNo() + " 已存在");
                    continue;
                }

                // 设置默认值
                if (employee.getStatus() == null) {
                    employee.setStatus(1); // 默认在职
                }
                if (employee.getGender() == null) {
                    employee.setGender(1); // 默认男
                }

                // 保存员工
                boolean success = this.save(employee);
                if (success) {
                    successCount++;
                } else {
                    failCount++;
                    failReasons.add("第" + (i + 1) + "条: 保存失败");
                }
            } catch (Exception e) {
                failCount++;
                failReasons.add("第" + (i + 1) + "条: " + e.getMessage());
                log.error("导入第" + (i + 1) + "条数据失败", e);
            }
        }

        return new com.hr.datacenter.controller.EmployeeController.BatchImportResult(successCount, failCount, failReasons);
    }
}
