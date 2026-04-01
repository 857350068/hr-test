package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.User;
import com.hr.datacenter.mapper.UserMapper;
import com.hr.datacenter.util.PasswordUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * 用户Service
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class UserService extends ServiceImpl<UserMapper, User> {

    private static final Logger log = LoggerFactory.getLogger(UserService.class);

    /**
     * 根据用户名查询用户
     */
    public User getUserByUsername(String username) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, username);
        return this.getOne(wrapper);
    }

    /**
     * 验证用户名和密码
     */
    public boolean validateUser(String username, String password) {
        User user = getUserByUsername(username);
        if (user == null) {
            log.warn("用户不存在: {}", username);
            return false;
        }

        if (user.getStatus() == 0) {
            log.warn("用户已被禁用: {}", username);
            return false;
        }

        return PasswordUtil.matches(password, user.getPassword());
    }
}
