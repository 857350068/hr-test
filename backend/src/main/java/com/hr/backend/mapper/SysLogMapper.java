package com.hr.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hr.backend.model.entity.SysLog;
import org.apache.ibatis.annotations.Mapper;

/**
 * 操作日志Mapper接口
 */
@Mapper
public interface SysLogMapper extends BaseMapper<SysLog> {
}
