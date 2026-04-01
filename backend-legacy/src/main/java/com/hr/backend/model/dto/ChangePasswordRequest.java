/**
 * ================================================================================
 * 人力资源数据中心系统 - 修改密码请求DTO
 * ================================================================================
 * 项目名称：HrDataCenter（人力资源数据中心系统）
 * 模块名称：模型层（model/dto）
 *
 * 类说明：ChangePasswordRequest
 * 本类是修改密码请求的数据传输对象（Data Transfer Object）
 *
 * 设计目的：
 * 1. 封装修改密码请求参数
 * 2. 提供参数校验注解
 * 3. 作为Controller方法的参数类型
 *
 * 使用场景：
 * - 修改密码接口：POST /api/auth/change-password
 * ================================================================================
 */
package com.hr.backend.model.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 修改密码请求DTO
 * <p>
 * 使用@Data注解自动生成getter/setter方法
 * 使用@NotBlank注解进行参数校验
 */
@Data
public class ChangePasswordRequest {

    /**
     * 原密码
     * <p>
     * 不能为空，需要与当前密码匹配
     */
    @NotBlank(message = "原密码不能为空")
    private String oldPassword;

    /**
     * 新密码
     * <p>
     * 不能为空，会自动BCrypt加密
     */
    @NotBlank(message = "新密码不能为空")
    private String newPassword;
}
