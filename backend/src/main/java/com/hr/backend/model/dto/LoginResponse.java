/**
 * ================================================================================
 * 人力资源数据中心系统 - 登录响应DTO
 * ================================================================================
 * 项目名称：HrDataCenter（人力资源数据中心系统）
 * 模块名称：模型层（model/dto）
 *
 * 类说明：LoginResponse
 * 本类是用户登录响应的数据传输对象（Data Transfer Object）
 *
 * 设计目的：
 * 1. 封装登录成功后的响应数据
 * 2. 返回JWT Token和用户信息
 * 3. 隐藏敏感信息（如密码）
 *
 * 使用场景：
 * - 用户登录接口：POST /api/auth/login
 * ================================================================================
 */
package com.hr.backend.model.dto;

import com.hr.backend.model.entity.User;
import lombok.Data;

/**
 * 登录响应DTO
 * <p>
 * 使用@Data注解自动生成getter/setter方法
 */
@Data
public class LoginResponse {

    /**
     * JWT Token
     * <p>
     * 用于后续接口的认证
     * 有效期：2小时
     */
    private String token;

    /**
     * 用户信息
     * <p>
     * 不包含密码等敏感信息
     */
    private User user;

    /**
     * 静态工厂方法：创建登录响应对象
     * <p>
     * 功能：
     * 1. 设置Token
     * 2. 复制用户信息（排除密码）
     * 3. 返回安全的用户信息
     *
     * @param token JWT Token
     * @param user  用户信息
     * @return 登录响应对象
     */
    public static LoginResponse of(String token, User user) {
        LoginResponse r = new LoginResponse();
        r.setToken(token);

        // 创建安全的用户对象，不包含密码
        User safe = new User();
        safe.setId(user.getId());
        safe.setUsername(user.getUsername());
        safe.setName(user.getName());
        safe.setRole(user.getRole());
        safe.setDeptId(user.getDeptId());
        safe.setDeptName(user.getDeptName());
        safe.setDeptScope(user.getDeptScope());
        safe.setPhone(user.getPhone());
        safe.setEmail(user.getEmail());
        safe.setStatus(user.getStatus());
        safe.setPassword(null);  // 隐藏密码

        r.setUser(safe);
        return r;
    }
}
