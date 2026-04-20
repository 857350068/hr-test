package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.SysOperationLog;
import com.hr.datacenter.mapper.mysql.OperationLogMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 操作日志服务
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class OperationLogService extends ServiceImpl<OperationLogMapper, SysOperationLog> {

    /**
     * 异步保存日志
     */
    @Async
    public void saveLog(SysOperationLog logEntity) {
        try {
            this.save(logEntity);
        } catch (Exception e) {
            log.error("保存操作日志失败", e);
        }
    }

    /**
     * 分页查询日志列表
     */
    public Page<SysOperationLog> getLogList(int page, int size, String module, String operator, Integer status) {
        Page<SysOperationLog> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<SysOperationLog> wrapper = new LambdaQueryWrapper<>();

        if (module != null && !module.isEmpty()) {
            wrapper.like(SysOperationLog::getModule, module);
        }
        if (operator != null && !operator.isEmpty()) {
            wrapper.like(SysOperationLog::getOperator, operator);
        }
        if (status != null) {
            wrapper.eq(SysOperationLog::getStatus, status);
        }

        wrapper.orderByDesc(SysOperationLog::getOperationTime);
        return this.page(pageParam, wrapper);
    }

    /**
     * 获取日志详情
     */
    public SysOperationLog getLogDetail(Long logId) {
        return this.getById(logId);
    }

    /**
     * 删除日志
     */
    public boolean deleteLog(Long logId) {
        return this.removeById(logId);
    }

    /**
     * 批量删除日志
     */
    public boolean batchDeleteLog(List<Long> logIds) {
        return this.removeByIds(logIds);
    }

    /**
     * 清空日志（保留最近N天）
     */
    public boolean clearLog(int days) {
        // 实现清空逻辑
        return true;
    }
}
