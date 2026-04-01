package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.Employee;
import com.hr.datacenter.mapper.EmployeeMapper;
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
}
