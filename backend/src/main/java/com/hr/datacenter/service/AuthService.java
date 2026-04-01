package com.hr.datacenter.service;

import com.hr.datacenter.entity.User;
import com.hr.datacenter.util.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 认证Service
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class AuthService {

    @Autowired
    private UserService userService;

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * 用户登录
     */
    public Map<String, Object> login(String username, String password) {
        // 验证用户名和密码
        boolean isValid = userService.validateUser(username, password);
        if (!isValid) {
            throw new RuntimeException("用户名或密码错误");
        }

        // 获取用户信息
        User user = userService.getUserByUsername(username);

        // 更新最后登录时间
        user.setLastLoginTime(LocalDateTime.now());
        userService.updateById(user);

        // 生成Token
        String token = jwtUtil.generateToken(user.getUserId(), user.getUsername());

        // 返回登录信息
        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("userId", user.getUserId());
        result.put("username", user.getUsername());
        result.put("realName", user.getRealName());
        result.put("deptId", user.getDeptId());

        return result;
    }
}
