package com.hr.backend.config;

import org.apache.catalina.Context;
import org.apache.tomcat.util.scan.StandardJarScanner;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 禁用 Tomcat Tld/ClassPath 扫描，避免 Hive 等依赖带入的老旧 TldScanner 与 Spring Boot 内置 Tomcat 9 冲突导致的 AbstractMethodError
 */
@Configuration
public class TomcatConfig {

    @Bean
    public WebServerFactoryCustomizer<TomcatServletWebServerFactory> tomcatCustomizer() {
        return factory -> factory.addContextCustomizers(this::disableTldScanning);
    }

    private void disableTldScanning(Context context) {
        if (context.getJarScanner() instanceof StandardJarScanner) {
            StandardJarScanner scanner = (StandardJarScanner) context.getJarScanner();
            scanner.setScanManifest(false);
            scanner.setScanClassPath(false);
        }
    }
}
