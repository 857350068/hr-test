package com.hr.datacenter.config;

import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.SqlSessionTemplate;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;

import javax.sql.DataSource;

/**
 * Hive数据源配置
 * 分析数据源，用于大数据分析和报表查询
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Configuration
@MapperScan(basePackages = "com.hr.datacenter.mapper.hive", sqlSessionFactoryRef = "hiveSqlSessionFactory")
public class HiveDataSourceConfig {

    /**
     * 创建Hive数据源
     * 用于连接Hive数据仓库
     */
    @Bean(name = "hiveDataSource")
    @ConfigurationProperties(prefix = "spring.datasource.hive")
    public DataSource hiveDataSource() {
        return DataSourceBuilder.create().build();
    }

    /**
     * 创建Hive SqlSessionFactory
     * 配置MyBatis
     */
    @Bean(name = "hiveSqlSessionFactory")
    public SqlSessionFactory hiveSqlSessionFactory(@Qualifier("hiveDataSource") DataSource dataSource) throws Exception {
        SqlSessionFactoryBean factory = new SqlSessionFactoryBean();
        factory.setDataSource(dataSource);
        factory.setMapperLocations(new PathMatchingResourcePatternResolver()
                .getResources("classpath*:/mapper/hive/**/*.xml"));
        
        // MyBatis配置
        org.apache.ibatis.session.Configuration configuration = new org.apache.ibatis.session.Configuration();
        configuration.setMapUnderscoreToCamelCase(true);
        configuration.setLogImpl(org.apache.ibatis.logging.stdout.StdOutImpl.class);
        factory.setConfiguration(configuration);
        
        return factory.getObject();
    }

    /**
     * 创建Hive事务管理器
     * 注意：Hive不支持事务，这里仅作为配置占位
     */
    @Bean(name = "hiveTransactionManager")
    public DataSourceTransactionManager hiveTransactionManager(@Qualifier("hiveDataSource") DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }

    /**
     * 创建Hive SqlSessionTemplate
     */
    @Bean(name = "hiveSqlSessionTemplate")
    public SqlSessionTemplate hiveSqlSessionTemplate(@Qualifier("hiveSqlSessionFactory") SqlSessionFactory sqlSessionFactory) {
        return new SqlSessionTemplate(sqlSessionFactory);
    }
}
