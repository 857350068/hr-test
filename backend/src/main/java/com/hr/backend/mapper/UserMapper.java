package com.hr.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hr.backend.model.entity.User;
import org.apache.ibatis.annotations.Param;

@org.apache.ibatis.annotations.Mapper
public interface UserMapper extends BaseMapper<User> {

    User selectByUsername(@Param("username") String username);
}
