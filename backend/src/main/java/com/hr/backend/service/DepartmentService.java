package com.hr.backend.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hr.backend.model.entity.Department;
import java.util.List;

/**
 * 部门服务接口
 * 提供部门相关的业务逻辑功能
 */
public interface DepartmentService extends IService<Department> {

    /**
     * 获取部门树形结构
     * @return 部门树形列表
     */
    List<Department> tree();

    /**
     * 获取所有部门列表
     * @return 部门列表
     */
    List<Department> getAllDepartments();
}
