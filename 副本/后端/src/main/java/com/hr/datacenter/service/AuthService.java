package com.hr.datacenter.service;

import com.hr.datacenter.entity.User;
import com.hr.datacenter.util.JwtUtil;
import com.hr.datacenter.util.PasswordUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

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
        String roleCode = resolveRoleCode(user);
        String token = jwtUtil.generateToken(user.getUserId(), user.getUsername(), roleCode);

        // 返回登录信息
        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("userId", user.getUserId());
        result.put("username", user.getUsername());
        result.put("realName", user.getRealName());
        result.put("deptId", user.getDeptId());
        result.put("roleCode", roleCode);

        return result;
    }

    /**
     * 用户注册
     */
    public void register(String username, String password, String realName, String phone, String email, String roleCode) {
        if (userService.existsByUsername(username)) {
            throw new RuntimeException("用户名已存在");
        }

        User user = new User();
        user.setUsername(username);
        user.setPassword(PasswordUtil.encode(password));
        user.setRealName(realName);
        user.setPhone(phone);
        user.setEmail(email);
        user.setDeptId(1L);
        user.setStatus(1);
        user.setRoleCode(StringUtils.hasText(roleCode) ? roleCode : "ROLE_EMPLOYEE");

        boolean saved = userService.save(user);
        if (!saved) {
            throw new RuntimeException("注册失败，请稍后重试");
        }
    }

    public Map<String, Object> getProfile(String username) {
        User user = userService.getUserByUsername(username);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        Map<String, Object> profile = new HashMap<>();
        profile.put("userId", user.getUserId());
        profile.put("username", user.getUsername());
        profile.put("realName", user.getRealName());
        profile.put("phone", user.getPhone());
        profile.put("email", user.getEmail());
        profile.put("deptId", user.getDeptId());
        profile.put("status", user.getStatus());
        profile.put("roleCode", resolveRoleCode(user));
        return profile;
    }

    public void updateProfile(String username, String realName, String phone, String email) {
        User user = userService.getUserByUsername(username);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        user.setRealName(realName);
        user.setPhone(phone);
        user.setEmail(email);
        userService.updateById(user);
    }

    public void changePassword(String username, String oldPassword, String newPassword) {
        User user = userService.getUserByUsername(username);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        if (!PasswordUtil.matches(oldPassword, user.getPassword())) {
            throw new RuntimeException("原密码不正确");
        }
        user.setPassword(PasswordUtil.encode(newPassword));
        userService.updateById(user);
    }

    private String resolveRoleCode(User user) {
        if (user.getRoleCode() != null && !user.getRoleCode().trim().isEmpty()) {
            return user.getRoleCode();
        }
        return "ROLE_EMPLOYEE";
    }
}
