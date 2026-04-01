package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.mapper.SysLogMapper;
import com.hr.backend.model.entity.SysLog;
import com.hr.backend.service.SysLogService;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 操作日志服务实现类
 */
@Service
public class SysLogServiceImpl extends ServiceImpl<SysLogMapper, SysLog> implements SysLogService {

    @Override
    public IPage<SysLog> page(Page<SysLog> page, String username, String operation) {
        LambdaQueryWrapper<SysLog> queryWrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(username)) {
            queryWrapper.like(SysLog::getUsername, username);
        }
        if (StringUtils.hasText(operation)) {
            queryWrapper.like(SysLog::getOperation, operation);
        }
        queryWrapper.orderByDesc(SysLog::getCreateTime);
        return page(page, queryWrapper);
    }
}
