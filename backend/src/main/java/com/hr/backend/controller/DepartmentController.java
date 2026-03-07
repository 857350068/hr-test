package com.hr.backend.controller;

import com.hr.backend.common.Response;
import com.hr.backend.model.entity.Department;
import com.hr.backend.service.DepartmentService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

/**
 * 部门管理控制器
 * 提供部门的增删改查功能
 */
@RestController
@RequestMapping("/api/department")
@PreAuthorize("hasRole('HR_ADMIN')")
public class DepartmentController {

    @Resource
    private DepartmentService departmentService;

    /**
     * 获取所有部门列表
     * @return 部门列表
     */
    @GetMapping("/list")
    public Response<List<Department>> list() {
        return Response.success(departmentService.getAllDepartments());
    }

    /**
     * 获取部门树形结构
     * @return 部门树
     */
    @GetMapping("/tree")
    public Response<List<Department>> tree() {
        return Response.success(departmentService.tree());
    }

    /**
     * 根据ID获取部门详情
     * @param id 部门ID
     * @return 部门详情
     */
    @GetMapping("/{id}")
    public Response<Department> getById(@PathVariable Long id) {
        return Response.success(departmentService.getById(id));
    }

    /**
     * 新增部门
     * @param department 部门信息
     * @return 操作结果
     */
    @PostMapping
    public Response<Void> add(@RequestBody Department department) {
        departmentService.save(department);
        return Response.success();
    }

    /**
     * 更新部门
     * @param id 部门ID
     * @param department 部门信息
     * @return 操作结果
     */
    @PutMapping("/{id}")
    public Response<Void> update(@PathVariable Long id, @RequestBody Department department) {
        department.setId(id);
        departmentService.updateById(department);
        return Response.success();
    }

    /**
     * 删除部门
     * @param id 部门ID
     * @return 操作结果
     */
    @DeleteMapping("/{id}")
    public Response<Void> delete(@PathVariable Long id) {
        departmentService.removeById(id);
        return Response.success();
    }
}
