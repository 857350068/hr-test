package com.hr.backend.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hr.backend.model.dto.ChangePasswordRequest;
import com.hr.backend.model.dto.LoginRequest;
import com.hr.backend.model.dto.LoginResponse;
import com.hr.backend.model.dto.RegisterRequest;
import com.hr.backend.model.entity.User;

public interface UserService extends IService<User> {

    LoginResponse login(LoginRequest request);

    void register(RegisterRequest request);

    void changePassword(ChangePasswordRequest request);

    User getById(Long id);

    IPage<User> page(Page<User> page, String username, String name, String role);

    void saveUser(User user);
}
