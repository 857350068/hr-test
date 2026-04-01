/**
 * ================================================================================
 * 人力资源数据中心系统 - 登录请求DTO
 * ================================================================================
 * 项目名称：HrDataCenter（人力资源数据中心系统）
 * 模块名称：模型层（model/dto）
 *
 * 类说明：LoginRequest
 * 本类是用户登录请求的数据传输对象（Data Transfer Object）
 *
 * 设计目的：
 * 1. 封装用户登录请求参数
 * 2. 提供参数校验注解
 * 3. 作为Controller方法的参数类型
 *
 * 使用场景：
 * - 用户登录接口：POST /api/auth/login
 * ================================================================================
 */
package com.hr.backend.model.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 登录请求DTO
 * <p>
 * 使用@Data注解自动生成getter/setter方法
 * 使用@NotBlank注解进行参数校验
 */
@Data
public class LoginRequest {

    /**
     * 用户名（工号）
     * <p>
     * 不能为空，否则会返回400错误
     */
    @NotBlank(message = "用户名不能为空")
    private String username;

    /**
     * 密码
     * <p>
     * 不能为空，否则会返回400错误
     */
    @NotBlank(message = "密码不能为空")
    private String password;
}
