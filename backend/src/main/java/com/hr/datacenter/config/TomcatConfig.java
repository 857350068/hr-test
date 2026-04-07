package com.hr.datacenter.config;

import org.apache.catalina.Context;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Tomcat 配置类 - 禁用 JSP 支持
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Configuration
public class TomcatConfig {

    @Bean
    public WebServerFactoryCustomizer<TomcatServletWebServerFactory> tomcatCustomizer() {
        return factory -> {
            factory.addContextCustomizers((Context context) -> {
                // 禁用 JSP 相关功能
                context.setReloadable(false);
                // 禁用 JAR 扫描以避免 Jasper 初始化
                context.getJarScanner().setJarScanFilter((jarScanType, jarName) -> false);
            });
        };
    }
}
