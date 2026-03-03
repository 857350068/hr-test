package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.common.BaseException;
import com.hr.backend.common.ErrorCode;
import com.hr.backend.mapper.UserMapper;
import com.hr.backend.model.dto.ChangePasswordRequest;
import com.hr.backend.model.dto.LoginRequest;
import com.hr.backend.model.dto.LoginResponse;
import com.hr.backend.model.dto.RegisterRequest;
import com.hr.backend.model.entity.User;
import com.hr.backend.security.JwtUtil;
import com.hr.backend.security.SecurityUtil;
import com.hr.backend.service.UserService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import javax.annotation.Resource;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Resource
    private PasswordEncoder passwordEncoder;

    @Resource
    private JwtUtil jwtUtil;

    @Override
    public LoginResponse login(LoginRequest request) {
        User user = baseMapper.selectByUsername(request.getUsername());
        if (user == null) {
            throw new BaseException(ErrorCode.UNAUTHORIZED.getCode(), "用户名或密码错误");
        }
        if (user.getStatus() != null && user.getStatus() != 1) {
            throw new BaseException(ErrorCode.FORBIDDEN.getCode(), "账号已禁用");
        }
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BaseException(ErrorCode.UNAUTHORIZED.getCode(), "用户名或密码错误");
        }
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
        return LoginResponse.of(token, user);
    }

    @Override
    public void register(RegisterRequest request) {
        if (baseMapper.selectByUsername(request.getUsername()) != null) {
            throw new BaseException(ErrorCode.USER_EXISTS.getCode(), "工号已存在");
        }
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setName(request.getName());
        user.setRole(request.getRole());
        user.setDeptId(request.getDeptId());
        user.setDeptName(request.getDeptName());
        user.setDeptScope(request.getDeptScope());
        user.setPhone(request.getPhone());
        user.setEmail(request.getEmail());
        user.setStatus(1);
        save(user);
    }

    @Override
    public void changePassword(ChangePasswordRequest request) {
        User current = SecurityUtil.getCurrentUser();
        if (current == null) {
            throw new BaseException(ErrorCode.UNAUTHORIZED.getCode(), "请先登录");
        }
        User user = getById(current.getId());
        if (user == null || !passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            throw new BaseException(ErrorCode.PARAM_ERROR.getCode(), "原密码错误");
        }
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        updateById(user);
    }

    @Override
    public User getById(Long id) {
        return super.getById(id);
    }

    @Override
    public IPage<User> page(Page<User> page, String username, String role) {
        LambdaQueryWrapper<User> q = new LambdaQueryWrapper<>();
        q.eq(User::getIsDeleted, 0);
        if (StringUtils.hasText(username)) q.like(User::getUsername, username);
        if (StringUtils.hasText(role)) q.eq(User::getRole, role);
        q.orderByDesc(User::getCreateTime);
        return super.page(page, q);
    }

    @Override
    public void saveUser(User user) {
        if (baseMapper.selectByUsername(user.getUsername()) != null) {
            throw new BaseException(ErrorCode.USER_EXISTS.getCode(), "工号已存在");
        }
        if (StringUtils.hasText(user.getPassword())) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        }
        user.setStatus(user.getStatus() != null ? user.getStatus() : 1);
        save(user);
    }
}
