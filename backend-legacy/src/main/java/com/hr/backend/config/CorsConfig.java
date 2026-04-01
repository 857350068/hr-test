/**
 * ================================================================================
 * 人力资源数据中心系统 - 跨域配置类
 * ================================================================================
 * 项目名称：HrDataCenter（人力资源数据中心系统）
 * 模块名称：配置模块（config）
 *
 * 类说明：CorsConfig
 * 本类用于配置跨域资源共享（CORS）策略，解决前后端分离时的跨域问题
 *
 * 设计目的：
 * 1. 允许前端应用（运行在不同端口或域名）访问后端API
 * 2. 配置允许的请求方法、请求头和来源
 * 3. 支持携带凭证（如Cookie、Authorization头）
 *
 * 跨域场景：
 * - 前端：http://localhost:5173（Vue开发服务器）
 * - 后端：http://localhost:8081（Spring Boot服务器）
 * - 生产环境：可能部署在不同域名下
 * ================================================================================
 */
package com.hr.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

/**
 * 跨域配置类
 * <p>
 * 使用@Configuration注解标记为配置类
 * 创建CorsFilter Bean来处理跨域请求
 */
@Configuration
public class CorsConfig {

    /**
     * 创建CORS过滤器Bean
     * <p>
     * 配置说明：
     * - 允许所有来源（Origin）：使用addAllowedOriginPattern("*")支持动态origin
     * - 允许所有请求头：addAllowedHeader("*")
     * - 允许所有HTTP方法：addAllowedMethod("*")（GET、POST、PUT、DELETE等）
     * - 允许携带凭证：setAllowCredentials(true)（如Cookie、JWT Token等）
     * - 应用到所有路径：/** 表示匹配所有请求路径
     *
     * 注意事项：
     * - 当设置allowCredentials为true时，不能使用addAllowedOrigin("*")
     * - 必须使用addAllowedOriginPattern("*")或指定具体的origin
     * - 生产环境建议限制具体的origin，提高安全性
     *
     * @return CORS过滤器实例
     */
    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        // 允许所有来源（支持动态origin，如localhost的不同端口）
        config.addAllowedOriginPattern("*");
        // 允许所有请求头
        config.addAllowedHeader("*");
        // 允许所有HTTP方法（GET、POST、PUT、DELETE、OPTIONS等）
        config.addAllowedMethod("*");
        // 允许携带凭证（Cookie、Authorization头等）
        config.setAllowCredentials(true);

        // 创建CORS配置源，应用到所有路径
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}
