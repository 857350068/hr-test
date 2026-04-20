package com.hr.datacenter.annotation;

import java.lang.annotation.*;

/**
 * 操作日志注解
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Target({ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface OperationLog {
    /**
     * 操作模块
     */
    String module() default "";

    /**
     * 操作类型
     */
    String type() default "";

    /**
     * 操作描述
     */
    String description() default "";

    /**
     * 是否记录请求参数
     */
    boolean isSaveRequestData() default true;

    /**
     * 是否记录响应结果
     */
    boolean isSaveResponseData() default true;
}
