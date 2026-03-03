package com.hr.backend.controller;

import com.hr.backend.common.Response;
import com.hr.backend.model.dto.ChangePasswordRequest;
import com.hr.backend.model.dto.LoginRequest;
import com.hr.backend.model.dto.LoginResponse;
import com.hr.backend.model.dto.RegisterRequest;
import com.hr.backend.model.entity.User;
import com.hr.backend.security.SecurityUtil;
import com.hr.backend.service.UserService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Resource
    private UserService userService;

    @PostMapping("/login")
    public Response<LoginResponse> login(@RequestBody @Validated LoginRequest request) {
        LoginResponse response = userService.login(request);
        return Response.success(response);
    }

    @PostMapping("/register")
    public Response<Void> register(@RequestBody @Validated RegisterRequest request) {
        userService.register(request);
        return Response.success();
    }

    @GetMapping("/info")
    public Response<User> getUserInfo() {
        User user = SecurityUtil.getCurrentUser();
        if (user != null) user.setPassword(null);
        return Response.success(user);
    }

    @PostMapping("/logout")
    public Response<Void> logout() {
        return Response.success();
    }

    @PostMapping("/change-password")
    public Response<Void> changePassword(@RequestBody @Validated ChangePasswordRequest request) {
        userService.changePassword(request);
        return Response.success();
    }
}
