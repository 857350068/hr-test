package com.hr.datacenter;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 人力资源数据中心启动类
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@SpringBootApplication
@MapperScan("com.hr.datacenter.mapper")
public class HrDataCenterApplication {

    public static void main(String[] args) {
        SpringApplication.run(HrDataCenterApplication.class, args);
        System.out.println("\n========================================");
        System.out.println("人力资源数据中心启动成功!");
        System.out.println("访问地址: http://localhost:8080/api");
        System.out.println("========================================\n");


    }


}
