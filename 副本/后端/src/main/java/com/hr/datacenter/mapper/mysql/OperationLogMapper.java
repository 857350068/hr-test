package com.hr.datacenter.mapper.mysql;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hr.datacenter.entity.SysOperationLog;
import org.apache.ibatis.annotations.Mapper;

/**
 * 操作日志Mapper
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Mapper
public interface OperationLogMapper extends BaseMapper<SysOperationLog> {
}
