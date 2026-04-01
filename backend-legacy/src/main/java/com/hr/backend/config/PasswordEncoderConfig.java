/**
 * ================================================================================
 * 人力资源数据中心系统 - 密码编码器配置类
 * ================================================================================
 * 项目名称：HrDataCenter（人力资源数据中心系统）
 * 模块名称：配置模块（config）
 *
 * 类说明：PasswordEncoderConfig
 * 本类用于配置Spring Security的密码编码器，用于用户密码的加密和校验
 *
 * 设计目的：
 * 1. 提供安全的密码加密存储方案
 * 2. 使用BCrypt算法进行密码加密
 * 3. 避免循环依赖问题（将PasswordEncoder Bean从SecurityConfig中分离）
 *
 * BCrypt算法特点：
 * - 单向加密：无法解密，只能通过加密后比较
 * - 自动加盐：每次加密结果都不同，防止彩虹表攻击
 * - 可调节强度：默认强度为10，可根据需要调整
 * - 安全性高：适合密码存储场景
 * ================================================================================
 */
package com.hr.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * 密码编码器配置类
 * <p>
 * 使用@Configuration注解标记为配置类
 * 创建PasswordEncoder Bean供整个应用使用
 */
@Configuration
public class PasswordEncoderConfig {

    /**
     * 创建密码编码器Bean
     * <p>
     * 使用BCryptPasswordEncoder实现：
     * - BCrypt是一种基于Blowfish的密码哈希算法
     * - 每次加密都会自动生成随机盐值
     * - 相同的明文密码每次加密结果都不同
     * - 但可以通过matches方法正确校验密码
     *
     * 使用场景：
     * 1. 用户注册时：使用encode()方法加密密码后存储
     * 2. 用户登录时：使用matches()方法比对明文密码和加密后的密码
     *
     * 示例：
     * // 加密
     * String encodedPassword = passwordEncoder.encode("123456");
     * // 校验
     * boolean matches = passwordEncoder.matches("123456", encodedPassword);
     *
     * @return BCrypt密码编码器实例
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
