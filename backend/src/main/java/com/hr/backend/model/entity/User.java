/**
 * ================================================================================
 * 人力资源数据中心系统 - 用户实体类
 * ================================================================================
 * 项目名称：HrDataCenter（人力资源数据中心系统）
 * 模块名称：模型层（model/entity）
 *
 * 类说明：User
 * 本类是系统用户实体，对应数据库表sys_user
 * 实现了Spring Security的UserDetails接口，用于认证和授权
 *
 * 设计目的：
 * 1. 映射数据库表sys_user
 * 2. 实现UserDetails接口，支持Spring Security认证
 * 3. 提供用户的权限信息
 * 4. 支持逻辑删除
 *
 * 数据库表：sys_user
 * ================================================================================
 */
package com.hr.backend.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * 用户实体类
 * <p>
 * 使用@Data注解自动生成getter/setter方法
 * 使用@TableName指定对应的数据库表名
 * 实现UserDetails接口，支持Spring Security认证
 */
@Data
@TableName("sys_user")
public class User implements UserDetails {

    /**
     * 用户ID
     * <p>
     * 主键，自增
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户名（工号）
     * <p>
     * 唯一索引，用于登录
     */
    private String username;

    /**
     * 密码
     * <p>
     * BCrypt加密后的密码
     */
    private String password;

    /**
     * 姓名
     * <p>
     * 用户真实姓名
     */
    private String name;

    /**
     * 角色
     * <p>
     * 可能的值：USER（普通用户）、ADMIN（管理员）
     * 支持多个角色，用逗号分隔
     */
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
     * 格式：部门ID列表，用逗号分隔
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

    /**
     * 状态
     * <p>
     * 1：正常，0：禁用
     */
    private Integer status;

    /**
     * 逻辑删除标记
     * <p>
     * 0：未删除，1：已删除
     * 使用@TableLogic注解实现逻辑删除
     */
    @TableLogic
    private Integer isDeleted;

    /**
     * 创建时间
     * <p>
     * 数据创建时间，插入时自动填充
     */
    @TableField(fill = FieldFill.INSERT)
    private Date createTime;

    /**
     * 更新时间
     * <p>
     * 数据更新时间，插入和更新时自动填充
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;

    /**
     * 获取用户权限列表
     * <p>
     * 功能：
     * - 从role字段中提取角色
     * - 将角色转换为Spring Security的GrantedAuthority对象
     * - 角色名称添加"ROLE_"前缀
     *
     * @return 权限列表
     */
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        if (role == null) return Collections.emptyList();
        List<GrantedAuthority> list = Stream.of(role.split(","))
                .map(r -> new SimpleGrantedAuthority("ROLE_" + r.trim()))
                .collect(Collectors.toList());
        return list;
    }

    /**
     * 账户是否未过期
     * <p>
     * 永远返回true，表示账户不会过期
     *
     * @return true
     */
    @Override
    public boolean isAccountNonExpired() { return true; }

    /**
     * 账户是否未锁定
     * <p>
     * 根据status字段判断
     * status为1表示未锁定
     *
     * @return true表示未锁定，false表示已锁定
     */
    @Override
    public boolean isAccountNonLocked() { return status != null && status == 1; }

    /**
     * 凭证是否未过期
     * <p>
     * 永远返回true，表示密码不会过期
     *
     * @return true
     */
    @Override
    public boolean isCredentialsNonExpired() { return true; }

    /**
     * 账户是否启用
     * <p>
     * 根据status字段判断
     * status为1表示启用
     *
     * @return true表示启用，false表示禁用
     */
    @Override
    public boolean isEnabled() { return status != null && status == 1; }
}
