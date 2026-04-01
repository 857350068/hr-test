/**
 * ================================================================================
 * 人力资源数据中心系统 - 自定义业务异常类
 * ================================================================================
 * 项目名称：HrDataCenter（人力资源数据中心系统）
 * 模块名称：通用组件模块（common）
 *
 * 类说明：BaseException
 * 本类是系统中所有业务异常的基类，继承自RuntimeException
 * 用于封装业务逻辑中的异常情况，提供统一的异常处理机制
 *
 * 设计目的：
 * 1. 区分业务异常和系统异常，提供更精确的错误信息
 * 2. 支持自定义错误码和错误消息
 * 3. 配合GlobalExceptionHandler实现统一异常处理
 * 4. 便于前端根据错误码进行相应的提示和处理
 *
 * 使用场景：
 * - 用户名或密码错误
 * - 用户已存在
 * - 参数校验失败
 * - 权限不足
 * - 资源不存在
 * 等业务场景中的异常情况
 * ================================================================================
 */
package com.hr.backend.common; // 声明包名，表示这个类属于com.hr.backend.common包

// 导入Lombok的Getter注解，用于自动生成getter方法
// Lombok是一个Java库，通过注解简化Java代码的编写
// @Gette注解会自动为类的所有字段生成对应的getter方法
import lombok.Getter;

/**
 * 自定义业务异常基类
 * <p>
 * 继承自RuntimeException，表示这是一个运行时异常
 * Spring的@Transactional注解默认只对RuntimeException进行回滚
 *
 * 功能特性：
 * 1. 封装错误码（code）和错误消息（message）
 * 2. 提供两种构造方式：使用ErrorCode枚举或直接指定码和消息
 * 3. 使用Lombok的@Getter注解自动生成getter方法
 *
 * 异常处理流程：
 * 1. 业务代码抛出BaseException
 * 2. GlobalExceptionHandler捕获该异常
 * 3. 封装为统一的Response对象返回给前端
 * 4. 前端根据错误码进行相应的UI提示
 */
@Getter // 使用Lombok注解，自动生成所有字段的getter方法，无需手动编写
public class BaseException extends RuntimeException { // 定义BaseException类，继承RuntimeException（运行时异常）

    /**
     * 错误码
     * <p>
     * 说明：
     * - 使用HTTP状态码风格的错误码
     * - 200：成功
     * - 400：参数错误
     * - 401：未授权
     * - 403：权限不足
     * - 404：资源不存在
     * - 409：冲突（如用户已存在）
     * - 500：系统错误
     */
    private final int code; // 定义错误码字段，final表示一旦赋值就不能修改，int类型表示整数

    /**
     * 构造方法1：使用ErrorCode枚举创建异常
     * <p>
     * 使用场景：
     * - 使用预定义的标准错误码和错误消息
     * - 保持错误信息的一致性
     *
     * @param errorCode 错误码枚举对象，包含code和message
     */
    public BaseException(ErrorCode errorCode) { // 定义构造方法，接收ErrorCode枚举类型参数
        super(errorCode.getMessage()); // 调用父类RuntimeException的构造方法，传入错误消息
        this.code = errorCode.getCode(); // 将errorCode对象的错误码赋值给当前类的code字段
    }

    /**
     * 构造方法2：使用自定义错误码和消息创建异常
     * <p>
     * 使用场景：
     * - 需要自定义错误消息（如具体的业务提示）
     * - 错误码需要动态确定
     *
     * @param code    错误码，建议使用HTTP状态码风格
     * @param message 错误消息，描述具体的错误原因
     */
    public BaseException(int code, String message) { // 定义构造方法，接收int类型的错误码和String类型的错误消息
        super(message); // 调用父类RuntimeException的构造方法，传入错误消息
        this.code = code; // 将传入的错误码参数赋值给当前类的code字段
    }
}
