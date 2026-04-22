package com.hr.datacenter.controller;

import com.hr.datacenter.dto.ChangePasswordRequest;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.dto.LoginRequest;
import com.hr.datacenter.dto.RegisterRequest;
import com.hr.datacenter.dto.UpdateProfileRequest;
import com.hr.datacenter.exception.BusinessException;
import com.hr.datacenter.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.Map;

/**
 * 认证控制器
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private static final Logger log = LoggerFactory.getLogger(AuthController.class);

    @Autowired
    private AuthService authService;

    /**
     * 用户登录
     */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@Validated @RequestBody LoginRequest loginRequest) {
        log.info("用户登录: {}", loginRequest.getUsername());
        try {
            Map<String, Object> result = authService.login(
                    loginRequest.getUsername(),
                    loginRequest.getPassword()
            );
            return Result.success("登录成功", result);
        } catch (BusinessException e) {
            log.warn("登录业务异常: {}", e.getMessage());
            return Result.error(e.getCode(), e.getMessage());
        } catch (RuntimeException e) {
            log.warn("登录失败: {}", e.getMessage());
            return Result.error(e.getMessage());
        } catch (Exception e) {
            log.error("登录系统异常", e);
            return Result.error("登录失败，请稍后重试");
        }
    }

    /**
     * 用户登出
     */
    @PostMapping("/logout")
    public Result<String> logout() {
        log.info("用户登出");
        return Result.success("登出成功", "");
    }

    /**
     * 用户注册
     */
    @PostMapping("/register")
    public Result<String> register(@Validated @RequestBody RegisterRequest registerRequest) {
        log.info("用户注册: {}", registerRequest.getUsername());
        try {
            authService.register(
                    registerRequest.getUsername(),
                    registerRequest.getPassword(),
                    registerRequest.getRealName(),
                    registerRequest.getPhone(),
                    registerRequest.getEmail()
            );
            return Result.success("注册成功", "");
        } catch (Exception e) {
            log.error("注册失败: {}", e.getMessage());
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/profile")
    public Result<Map<String, Object>> getProfile(Principal principal) {
        try {
            Map<String, Object> data = authService.getProfile(principal.getName());
            return Result.success(data);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PutMapping("/profile")
    public Result<String> updateProfile(@Validated @RequestBody UpdateProfileRequest request, Principal principal) {
        try {
            authService.updateProfile(principal.getName(), request.getRealName(), request.getPhone(), request.getEmail());
            return Result.success("更新成功", "");
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PutMapping("/change-password")
    public Result<String> changePassword(@Validated @RequestBody ChangePasswordRequest request, Principal principal) {
        try {
            authService.changePassword(principal.getName(), request.getOldPassword(), request.getNewPassword());
            return Result.success("密码修改成功", "");
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
