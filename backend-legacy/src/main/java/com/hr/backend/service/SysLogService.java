package com.hr.backend.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hr.backend.model.entity.SysLog;

/**
 * 操作日志服务接口
 */
public interface SysLogService extends IService<SysLog> {

    /**
     * 分页查询操作日志
     * @param page 分页参数
     * @param username 用户名
     * @param operation 操作类型
     * @return 分页结果
     */
    IPage<SysLog> page(Page<SysLog> page, String username, String operation);
}
