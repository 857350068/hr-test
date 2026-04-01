/**
 * ================================================================================
 * 人力资源数据中心系统 - 认证控制器
 * ================================================================================
 * 功能说明：
 * 本类负责处理用户认证相关的HTTP请求，包括登录、注册、获取用户信息、登出、修改密码等功能。
 *
 * 设计模式：
 * - 采用RESTful风格设计API
 * - 使用统一的Response<T>响应格式
 * - 使用JWT进行无状态认证
 *
 * 安全机制：
 * - 登录接口：公开访问，无需认证
 * - 注册接口：公开访问，无需认证
 * - 获取用户信息：需要JWT认证
 * - 登出接口：需要JWT认证（JWT是无状态的，客户端删除token即可）
 * - 修改密码：需要JWT认证
 *
 * 接口列表：
 * - POST /api/auth/login - 用户登录
 * - POST /api/auth/register - 用户注册
 * - GET /api/auth/info - 获取当前用户信息
 * - POST /api/auth/logout - 用户登出
 * - POST /api/auth/change-password - 修改密码
 * ================================================================================
 */
package com.hr.backend.controller;

// 导入统一的响应封装类
import com.hr.backend.common.Response;
// 导入修改密码请求DTO
import com.hr.backend.model.dto.ChangePasswordRequest;
// 导入登录请求DTO
import com.hr.backend.model.dto.LoginRequest;
// 导入登录响应DTO
import com.hr.backend.model.dto.LoginResponse;
// 导入注册请求DTO
import com.hr.backend.model.dto.RegisterRequest;
// 导入用户实体类
import com.hr.backend.model.entity.User;
// 导入安全工具类，用于获取当前登录用户
import com.hr.backend.security.SecurityUtil;
// 导入用户服务接口
import com.hr.backend.service.UserService;
// 导入Spring的参数校验注解
import org.springframework.validation.annotation.Validated;
// 导入Spring Web注解（@RestController, @RequestMapping, @PostMapping等）
import org.springframework.web.bind.annotation.*;

// 导入@Resource注解，用于依赖注入
import javax.annotation.Resource;

/**
 * 认证控制器
 * <p>
 * 使用@RestController注解标记为REST控制器，返回JSON格式的响应
 * 使用@RequestMapping注解指定基础路径为"/api/auth"，所有接口都在这个路径下
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    /**
     * 注入用户服务
     * <p>
     * @Resource注解是JDK提供的注解，功能与@Autowired类似
     * Spring会自动将UserService的实现类注入到这个字段中
     * 使用服务层的好处：
     * 1. 业务逻辑与控制层分离
     * 2. 便于单元测试
     * 3. 提高代码复用性
     */
    @Resource
    private UserService userService;

    /**
     * 用户登录接口
     * <p>
     * 功能说明：
     * 1. 接收用户名和密码
     * 2. 验证用户名和密码是否正确
     * 3. 如果验证成功，生成JWT令牌
     * 4. 返回JWT令牌和用户信息
     *
     * 请求示例：
     * POST /api/auth/login
     * Content-Type: application/json
     * {
     *   "username": "admin",
     *   "password": "123456"
     * }
     *
     * 响应示例：
     * {
     *   "code": 200,
     *   "message": "success",
     *   "data": {
     *     "token": "eyJhbGciOiJIUzI1NiJ9...",
     *     "user": {
     *       "id": 23,
     *       "username": "admin",
     *       "name": "王建国",
     *       "role": "HR_ADMIN",
     *       ...
     *     }
     *   }
     * }
     *
     * @param request 登录请求对象，包含username和password字段
     *                @Validated注解表示需要进行参数校验
     *                @RequestBody注解表示从请求体中获取JSON数据
     * @return 返回登录响应，包含JWT令牌和用户信息
     */
    @PostMapping("/login") // 映射POST请求到/api/auth/login路径
    public Response<LoginResponse> login(@RequestBody @Validated LoginRequest request) {
        // 调用用户服务层处理登录逻辑
        // 返回的LoginResponse包含token和user信息
        LoginResponse response = userService.login(request);

        // 封装成统一的响应格式返回
        // code: 200表示成功
        // message: "success"
        // data: LoginResponse对象
        return Response.success(response);
    }

    /**
     * 用户注册接口
     * <p>
     * 功能说明：
     * 1. 接收用户注册信息（工号、密码、姓名、角色、部门等）
     * 2. 验证工号是否已存在
     * 3. 使用BCrypt加密密码
     * 4. 保存用户信息到数据库
     *
     * 请求示例：
     * POST /api/auth/register
     * Content-Type: application/json
     * {
     *   "username": "E001",
     *   "password": "123456",
     *   "name": "张三",
     *   "role": "EMPLOYEE",
     *   "deptId": 1,
     *   "deptName": "销售部"
     * }
     *
     * 响应示例：
     * {
     *   "code": 200,
     *   "message": "success",
     *   "data": null
     * }
     *
     * @param request 注册请求对象，包含用户注册所需的所有字段
     *                @Validated注解表示需要进行参数校验（如必填字段、格式验证等）
     *                @RequestBody注解表示从请求体中获取JSON数据
     * @return 返回操作结果，成功时code为200，data为null
     */
    @PostMapping("/register") // 映射POST请求到/api/auth/register路径
    public Response<Void> register(@RequestBody @Validated RegisterRequest request) {
        // 调用用户服务层处理注册逻辑
        // 包括：验证工号是否存在、密码加密、保存用户信息
        userService.register(request);

        // 返回成功响应
        // code: 200表示成功
        // message: "success"
        // data: null（注册接口不需要返回数据）
        return Response.success();
    }

    /**
     * 获取当前用户信息接口
     * <p>
     * 功能说明：
     * 1. 从JWT令牌中解析出用户信息
     * 2. 从数据库查询用户详细信息
     * 3. 返回用户信息（不包含密码）
     *
     * 安全机制：
     * - 需要JWT认证（在请求头中携带token）
     * - SecurityUtil.getCurrentUser()会从JWT中获取当前登录用户
     *
     * 请求示例：
     * GET /api/auth/info
     * Headers: Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
     *
     * 响应示例：
     * {
     *   "code": 200,
     *   "message": "success",
     *   "data": {
     *     "id": 23,
     *     "username": "admin",
     *     "name": "王建国",
     *     "role": "HR_ADMIN",
     *     "deptName": "人事部",
     *     "phone": "13800138001",
     *     "email": "wangjianguo@company.com",
     *     ...
     *   }
     * }
     *
     * @return 返回当前登录用户的信息，不包含密码字段
     */
    @GetMapping("/info") // 映射GET请求到/api/auth/info路径
    public Response<User> getUserInfo() {
        // 从JWT中获取当前登录用户
        // SecurityUtil.getCurrentUser()会：
        // 1. 从请求头中获取JWT令牌
        // 2. 解析JWT令牌，获取用户ID
        // 3. 从数据库查询用户信息
        // 4. 返回用户对象
        User user = SecurityUtil.getCurrentUser();

        // 安全处理：将密码字段设置为null
        // 原因：
        // 1. 密码是敏感信息，不应该返回给前端
        // 2. 防止密码泄露
        if (user != null) {
            user.setPassword(null);
        }

        // 返回用户信息
        return Response.success(user);
    }

    /**
     * 用户登出接口
     * <p>
     * 功能说明：
     * JWT是无状态的认证方式，服务端不保存会话状态。
     * 因此，登出操作只需要客户端删除本地存储的JWT令牌即可。
     * 服务端返回成功响应，表示登出操作完成。
     *
     * 安全机制：
     * - 虽然JWT是无状态的，但这个接口仍然需要JWT认证
     * - 原因：记录用户登出日志，防止未认证用户调用
     *
     * 请求示例：
     * POST /api/auth/logout
     * Headers: Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
     *
     * 响应示例：
     * {
     *   "code": 200,
     *   "message": "success",
     *   "data": null
     * }
     *
     * @return 返回登出成功响应
     */
    @PostMapping("/logout") // 映射POST请求到/api/auth/logout路径
    public Response<Void> logout() {
        // JWT是无状态的，服务端不需要做任何操作
        // 客户端需要：
        // 1. 删除本地存储的JWT令牌
        // 2. 清除用户信息
        // 3. 跳转到登录页面

        // 返回成功响应，表示登出操作完成
        return Response.success();
    }

    /**
     * 修改密码接口
     * <p>
     * 功能说明：
     * 1. 验证原密码是否正确
     * 2. 验证新密码是否符合要求
     * 3. 使用BCrypt加密新密码
     * 4. 更新数据库中的密码
     *
     * 安全机制：
     * - 需要JWT认证（在请求头中携带token）
     * - 需要验证原密码，防止恶意修改
     * - 新密码必须符合安全要求（长度、复杂度等）
     *
     * 请求示例：
     * POST /api/auth/change-password
     * Headers: Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
     * Content-Type: application/json
     * {
     *   "oldPassword": "123456",
     *   "newPassword": "654321"
     * }
     *
     * 响应示例：
     * {
     *   "code": 200,
     *   "message": "success",
     *   "data": null
     * }
     *
     * @param request 修改密码请求对象，包含oldPassword和newPassword字段
     *                @Validated注解表示需要进行参数校验（如新旧密码不能相同等）
     *                @RequestBody注解表示从请求体中获取JSON数据
     * @return 返回操作结果，成功时code为200，data为null
     */
    @PostMapping("/change-password") // 映射POST请求到/api/auth/change-password路径
    public Response<Void> changePassword(@RequestBody @Validated ChangePasswordRequest request) {
        // 调用用户服务层处理修改密码逻辑
        // 包括：验证原密码、验证新密码、加密新密码、更新数据库
        userService.changePassword(request);

        // 返回成功响应
        // code: 200表示成功
        // message: "success"
        // data: null（修改密码接口不需要返回数据）
        return Response.success();
    }
}
