/**
 * ================================================================================
 * 人力资源数据中心系统 - 统一响应结果类
 * ================================================================================
 * 项目名称：HrDataCenter（人力资源数据中心系统）
 * 模块名称：通用组件模块（common）
 *
 * 类说明：Response
 * 本类是系统中所有API接口的统一响应结果封装类
 * 采用泛型设计，支持返回任意类型的数据
 *
 * 设计目的：
 * 1. 统一API响应格式，便于前端处理
 * 2. 封装响应码、响应消息和响应数据
 * 3. 提供成功和失败的快速构建方法
 * 4. 支持泛型，灵活适应各种业务场景
 *
 * 响应格式：
 * {
 *   "code": 200,           // 响应码
 *   "message": "success",  // 响应消息
 *   "data": {...}          // 响应数据（可能为null）
 * }
 * ================================================================================
 */
package com.hr.backend.common;

import lombok.Data;

/**
 * 统一响应结果类
 * <p>
 * 使用泛型T支持返回任意类型的数据
 * 使用Lombok的@Data注解自动生成getter/setter方法
 *
 * 字段说明：
 * - code：响应码，200表示成功，其他表示失败
 * - message：响应消息，描述操作结果
 * - data：响应数据，泛型类型，可能为null
 */
@Data
public class Response<T> {

    /**
     * 响应码
     * <p>
     * 标准：
     * - 200：成功
     * - 400：参数错误
     * - 401：未授权
     * - 403：权限不足
     * - 404：资源不存在
     * - 500：系统错误
     */
    private int code;

    /**
     * 响应消息
     * <p>
     * 描述操作结果，如"success"、"参数错误"等
     */
    private String message;

    /**
     * 响应数据
     * <p>
     * 泛型类型，可以是任意业务数据
     * 如果不需要返回数据，则为null
     */
    private T data;

    /**
     * 构建成功响应（无数据）
     * <p>
     * 使用场景：
     * - 删除操作
     * - 更新操作
     * - 不需要返回数据的操作
     *
     * @param <T> 数据类型
     * @return 成功响应对象，data为null
     */
    public static <T> Response<T> success() {
        return success(null);
    }

    /**
     * 构建成功响应（带数据）
     * <p>
     * 使用场景：
     * - 查询操作
     * - 登录操作（返回token）
     * - 需要返回数据的操作
     *
     * @param data 响应数据
     * @param <T>  数据类型
     * @return 成功响应对象，包含指定数据
     */
    public static <T> Response<T> success(T data) {
        Response<T> r = new Response<>();
        r.setCode(200);
        r.setMessage("success");
        r.setData(data);
        return r;
    }

    /**
     * 构建错误响应
     * <p>
     * 使用场景：
     * - 业务异常
     * - 系统异常
     * - 参数校验失败
     *
     * @param code    错误码
     * @param message 错误消息
     * @param <T>     数据类型
     * @return 错误响应对象，data为null
     */
    public static <T> Response<T> error(int code, String message) {
        Response<T> r = new Response<>();
        r.setCode(code);
        r.setMessage(message);
        r.setData(null);
        return r;
    }

    /**
     * 构建错误响应（字符串错误码）
     * <p>
     * 使用场景：
     * - 业务异常（BusinessException）
     * - 自定义错误码
     *
     * @param code    错误码（字符串）
     * @param message 错误消息
     * @param <T>     数据类型
     * @return 错误响应对象，data为null
     */
    public static <T> Response<T> error(String code, String message) {
        Response<T> r = new Response<>();
        r.setCode(500); // 默认使用500作为HTTP状态码
        r.setMessage(message);
        r.setData(null);
        return r;
    }
}
