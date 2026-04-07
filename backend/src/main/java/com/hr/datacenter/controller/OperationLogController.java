package com.hr.datacenter.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hr.datacenter.annotation.OperationLog;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.SysOperationLog;
import com.hr.datacenter.service.OperationLogService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 操作日志控制器
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@RestController
@RequestMapping("/operation-log")
@CrossOrigin(origins = "*")
public class OperationLogController {

    @Autowired
    private OperationLogService operationLogService;

    /**
     * 分页查询日志列表
     */
    @GetMapping("/list")
    @OperationLog(module = "系统管理", type = "查询", description = "查询操作日志列表")
    public Result<Page<SysOperationLog>> getLogList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String module,
            @RequestParam(required = false) String operator,
            @RequestParam(required = false) Integer status) {
        Page<SysOperationLog> logPage = operationLogService.getLogList(page, size, module, operator, status);
        return Result.success(logPage);
    }

    /**
     * 获取日志详情
     */
    @GetMapping("/{logId}")
    @OperationLog(module = "系统管理", type = "查询", description = "查询操作日志详情")
    public Result<SysOperationLog> getLogDetail(@PathVariable Long logId) {
        SysOperationLog log = operationLogService.getLogDetail(logId);
        if (log == null) {
            return Result.error("日志不存在");
        }
        return Result.success(log);
    }

    /**
     * 删除日志
     */
    @DeleteMapping("/delete/{logId}")
    @OperationLog(module = "系统管理", type = "删除", description = "删除操作日志")
    public Result<String> deleteLog(@PathVariable Long logId) {
        boolean success = operationLogService.deleteLog(logId);
        if (success) {
            return Result.success("删除成功");
        }
        return Result.error("删除失败");
    }

    /**
     * 批量删除日志
     */
    @DeleteMapping("/batch-delete")
    @OperationLog(module = "系统管理", type = "删除", description = "批量删除操作日志")
    public Result<String> batchDeleteLog(@RequestBody List<Long> logIds) {
        boolean success = operationLogService.batchDeleteLog(logIds);
        if (success) {
            return Result.success("删除成功");
        }
        return Result.error("删除失败");
    }

    /**
     * 清空日志
     */
    @DeleteMapping("/clear")
    @OperationLog(module = "系统管理", type = "删除", description = "清空操作日志")
    public Result<String> clearLog(@RequestParam(defaultValue = "30") int days) {
        boolean success = operationLogService.clearLog(days);
        if (success) {
            return Result.success("清空成功");
        }
        return Result.error("清空失败");
    }
}
