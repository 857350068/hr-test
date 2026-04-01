package com.hr.datacenter.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hr.datacenter.entity.Leave;
import org.apache.ibatis.annotations.Mapper;

/**
 * 请假Mapper接口
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Mapper
public interface LeaveMapper extends BaseMapper<Leave> {
}
