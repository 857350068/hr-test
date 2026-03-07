package com.hr.backend.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hr.backend.common.Response;
import com.hr.backend.model.entity.SysLog;
import com.hr.backend.service.SysLogService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;

/**
 * 操作日志管理控制器
 */
@RestController
@RequestMapping("/api/admin/logs")
@PreAuthorize("hasRole('HR_ADMIN')")
public class SysLogController {

    @Resource
    private SysLogService sysLogService;

    /**
     * 分页查询操作日志
     * @param current 当前页
     * @param size 每页大小
     * @param username 用户名
     * @param operation 操作类型
     * @return 分页结果
     */
    @GetMapping
    public Response<IPage<SysLog>> page(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String operation) {
        IPage<SysLog> page = sysLogService.page(new Page<>(current, size), username, operation);
        return Response.success(page);
    }

    /**
     * 根据ID获取日志详情
     * @param id 日志ID
     * @return 日志详情
     */
    @GetMapping("/{id}")
    public Response<SysLog> getById(@PathVariable Long id) {
        return Response.success(sysLogService.getById(id));
    }

    /**
     * 删除日志
     * @param id 日志ID
     * @return 操作结果
     */
    @DeleteMapping("/{id}")
    public Response<Void> delete(@PathVariable Long id) {
        sysLogService.removeById(id);
        return Response.success();
    }
}
