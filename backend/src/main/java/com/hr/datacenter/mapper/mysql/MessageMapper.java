package com.hr.datacenter.mapper.mysql;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hr.datacenter.entity.Message;
import org.apache.ibatis.annotations.Mapper;

/**
 * 消息Mapper
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Mapper
public interface MessageMapper extends BaseMapper<Message> {
}
