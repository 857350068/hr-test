package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.mapper.DepartmentMapper;
import com.hr.backend.model.entity.Department;
import com.hr.backend.service.DepartmentService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 部门服务实现类
 */
@Service
public class DepartmentServiceImpl extends ServiceImpl<DepartmentMapper, Department> implements DepartmentService {

    @Resource
    private DepartmentMapper departmentMapper;

    @Override
    public List<Department> tree() {
        List<Department> allDepartments = departmentMapper.selectList(null);
        return buildTree(allDepartments, 0L);
    }

    @Override
    public List<Department> getAllDepartments() {
        return departmentMapper.selectList(null);
    }

    @Override
    public IPage<Department> page(Page<Department> page, String name) {
        LambdaQueryWrapper<Department> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.isNotBlank(name)) {
            wrapper.like(Department::getName, name);
        }
        wrapper.orderByAsc(Department::getId);
        return this.page(page, wrapper);
    }

    /**
     * 构建树形结构
     * @param departments 所有部门列表
     * @param parentId 父部门ID
     * @return 树形结构列表
     */
    private List<Department> buildTree(List<Department> departments, Long parentId) {
        return departments.stream()
                .filter(dept -> dept.getParentId().equals(parentId))
                .map(dept -> {
                    dept.setChildren(buildTree(departments, dept.getId()));
                    return dept;
                })
                .collect(Collectors.toList());
    }
}
