package com.hr.backend.config;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MyBatis-Plus配置类
 *
 * 配置MyBatis-Plus分页插件，支持数据库分页查询
 *
 * @author HrDataCenter
 * @since 2026-03-25
 */
@Configuration
public class MybatisPlusConfig {

    /**
     * 配置MyBatis-Plus分页插件
     *
     * @return MybatisPlusInterceptor实例
     */
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();

        // 添加MySQL分页插件
        PaginationInnerInterceptor paginationInterceptor = new PaginationInnerInterceptor(DbType.MYSQL);

        // 设置请求的页面大于最大页后操作，true调回到首页，false继续请求  默认false
        paginationInterceptor.setOverflow(false);

        // 单页分页条数限制（默认无限制）
        paginationInterceptor.setMaxLimit(100L);

        interceptor.addInnerInterceptor(paginationInterceptor);

        return interceptor;
    }
}
