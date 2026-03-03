/**
 * ================================================================================
 * 人力资源数据中心系统 - 注册请求DTO
 * ================================================================================
 * 项目名称：HrDataCenter（人力资源数据中心系统）
 * 模块名称：模型层（model/dto）
 *
 * 类说明：RegisterRequest
 * 本类是用户注册请求的数据传输对象（Data Transfer Object）
 *
 * 设计目的：
 * 1. 封装用户注册请求参数
 * 2. 提供参数校验注解
 * 3. 作为Controller方法的参数类型
 *
 * 使用场景：
 * - 用户注册接口：POST /api/auth/register
 * ================================================================================
 */
package com.hr.backend.model.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 注册请求DTO
 * <p>
 * 使用@Data注解自动生成getter/setter方法
 * 使用@NotBlank注解进行参数校验
 */
@Data
public class RegisterRequest {

    /**
     * 工号（用户名）
     * <p>
     * 不能为空，必须唯一
     */
    @NotBlank(message = "工号不能为空")
    private String username;

    /**
     * 密码
     * <p>
     * 不能为空，会自动BCrypt加密
     */
    @NotBlank(message = "密码不能为空")
    private String password;

    /**
     * 姓名
     * <p>
     * 用户真实姓名
     */
    @NotBlank(message = "姓名不能为空")
    private String name;

    /**
     * 角色
     * <p>
     * 不能为空，可选值：USER、ADMIN
     */
    @NotBlank(message = "角色不能为空")
    private String role;

    /**
     * 部门ID
     * <p>
     * 所属部门的主键ID
     */
    private Long deptId;

    /**
     * 部门名称
     * <p>
     * 冗余字段，便于查询
     */
    private String deptName;

    /**
     * 数据权限范围
     * <p>
     * 定义用户可以访问的数据范围
     */
    private String deptScope;

    /**
     * 电话
     * <p>
     * 联系电话
     */
    private String phone;

    /**
     * 邮箱
     * <p>
     * 电子邮箱
     */
    private String email;
}
