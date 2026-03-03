/**
 * ================================================================================
 * 人力资源数据中心系统 - 数据管理控制器
 * ================================================================================
 * 项目名称：HrDataCenter（人力资源数据中心系统）
 * 模块名称：控制器层（controller）
 *
 * 类说明：DataController
 * 本类负责处理员工档案数据相关的HTTP请求，提供数据的增删改查功能
 *
 * 设计目的：
 * 1. 提供员工档案的CRUD接口
 * 2. 支持分页查询
 * 3. 支持多条件筛选（工号、部门、时间周期、分类）
 * 4. 提供RESTful风格的API接口
 *
 * 主要功能：
 * 1. 分页查询员工列表
 * 2. 根据ID查询员工详情
 * 3. 新增员工档案
 * 4. 更新员工档案
 * 5. 删除员工档案（逻辑删除）
 * ================================================================================
 */
package com.hr.backend.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hr.backend.common.Response;
import com.hr.backend.model.entity.EmployeeProfile;
import com.hr.backend.service.EmployeeProfileService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;

/**
 * 数据管理控制器
 * <p>
 * 使用@RestController注解标记为REST控制器
 * 使用@RequestMapping指定基础路径为/api/data
 * 所有接口都需要JWT认证（由SecurityConfig配置）
 */
@RestController
@RequestMapping("/api/data")
public class DataController {

    /**
     * 员工档案服务
     * <p>
     * 负责员工档案数据的业务逻辑处理
     */
    @Resource
    private EmployeeProfileService employeeProfileService;

    /**
     * 分页查询员工列表
     * <p>
     * 功能：
     * - 支持分页查询
     * - 支持按工号筛选
     * - 支持按部门筛选
     * - 支持按时间周期筛选
     * - 支持按分类筛选
     *
     * @param current   当前页码，默认为1
     * @param size      每页大小，默认为10
     * @param employeeNo 工号（可选）
     * @param deptName  部门名称（可选）
     * @param period    时间周期（可选）
     * @param categoryId 分类ID（可选）
     * @return 分页结果，包含员工列表和分页信息
     */
    @GetMapping("/employee/page")
    public Response<IPage<EmployeeProfile>> page(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) String employeeNo,
            @RequestParam(required = false) String deptName,
            @RequestParam(required = false) String period,
            @RequestParam(required = false) Long categoryId) {
        IPage<EmployeeProfile> page = employeeProfileService.page(new Page<>(current, size), employeeNo, deptName, period, categoryId);
        return Response.success(page);
    }

    /**
     * 根据ID查询员工详情
     * <p>
     * 功能：
     * - 根据员工ID查询详细信息
     * - 返回完整的员工档案信息
     *
     * @param id 员工ID
     * @return 员工详细信息
     */
    @GetMapping("/employee/{id}")
    public Response<EmployeeProfile> getById(@PathVariable Long id) {
        return Response.success(employeeProfileService.getById(id));
    }

    /**
     * 新增员工档案
     * <p>
     * 功能：
     * - 创建新的员工档案
     * - 自动设置创建时间和更新时间
     * - 工号不能重复
     *
     * @param profile 员工档案信息
     * @return 操作结果
     */
    @PostMapping("/employee")
    public Response<Void> add(@RequestBody EmployeeProfile profile) {
        employeeProfileService.save(profile);
        return Response.success();
    }

    /**
     * 更新员工档案
     * <p>
     * 功能：
     * - 更新指定ID的员工档案
     * - 自动更新更新时间
     * - 不修改的字段保持原值
     *
     * @param id      员工ID
     * @param profile 员工档案信息
     * @return 操作结果
     */
    @PutMapping("/employee/{id}")
    public Response<Void> update(@PathVariable Long id, @RequestBody EmployeeProfile profile) {
        profile.setId(id);
        employeeProfileService.updateById(profile);
        return Response.success();
    }

    /**
     * 删除员工档案
     * <p>
     * 功能：
     * - 逻辑删除指定ID的员工档案
     * - 将is_deleted字段设置为1
     * - 数据仍然保留在数据库中
     *
     * @param id 员工ID
     * @return 操作结果
     */
    @DeleteMapping("/employee/{id}")
    public Response<Void> delete(@PathVariable Long id) {
        employeeProfileService.removeById(id);
        return Response.success();
    }
}
