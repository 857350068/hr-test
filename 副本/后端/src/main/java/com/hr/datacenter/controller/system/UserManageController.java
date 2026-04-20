package com.hr.datacenter.controller.system;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hr.datacenter.annotation.OperationLog;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.User;
import com.hr.datacenter.service.UserService;
import com.hr.datacenter.util.PasswordUtil;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/system/user")
@CrossOrigin(origins = "*")
public class UserManageController {

    @Autowired
    private UserService userService;

    @GetMapping("/list")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<IPage<User>> list(@RequestParam(defaultValue = "1") int page,
                                    @RequestParam(defaultValue = "10") int size,
                                    @RequestParam(required = false) String keyword,
                                    @RequestParam(required = false) String roleCode,
                                    @RequestParam(required = false) Integer status) {
        Page<User> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(User::getUsername, keyword)
                    .or().like(User::getRealName, keyword)
                    .or().like(User::getPhone, keyword));
        }
        if (StringUtils.hasText(roleCode)) {
            wrapper.eq(User::getRoleCode, roleCode);
        }
        if (status != null) {
            wrapper.eq(User::getStatus, status);
        }
        wrapper.orderByDesc(User::getCreateTime);
        return Result.success(userService.page(pageParam, wrapper));
    }

    @PostMapping("/add")
    @OperationLog(module = "用户管理", type = "新增", description = "新增系统用户")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<String> add(@RequestBody User user) {
        if (!StringUtils.hasText(user.getUsername()) || !StringUtils.hasText(user.getPassword())) {
            return Result.error("用户名和密码不能为空");
        }
        if (userService.existsByUsername(user.getUsername())) {
            return Result.error("用户名已存在");
        }
        if (!StringUtils.hasText(user.getRoleCode())) {
            user.setRoleCode("ROLE_EMPLOYEE");
        }
        if (user.getStatus() == null) {
            user.setStatus(1);
        }
        user.setPassword(PasswordUtil.encode(user.getPassword()));
        userService.save(user);
        return Result.success("新增成功", "");
    }

    @PutMapping("/update")
    @OperationLog(module = "用户管理", type = "更新", description = "更新系统用户")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<String> update(@RequestBody User user) {
        User dbUser = userService.getById(user.getUserId());
        if (dbUser == null) {
            return Result.error("用户不存在");
        }
        if (StringUtils.hasText(user.getRealName())) {
            dbUser.setRealName(user.getRealName());
        }
        if (StringUtils.hasText(user.getPhone())) {
            dbUser.setPhone(user.getPhone());
        }
        if (StringUtils.hasText(user.getEmail())) {
            dbUser.setEmail(user.getEmail());
        }
        if (StringUtils.hasText(user.getRoleCode())) {
            dbUser.setRoleCode(user.getRoleCode());
        }
        if (user.getStatus() != null) {
            dbUser.setStatus(user.getStatus());
        }
        if (user.getDeptId() != null) {
            dbUser.setDeptId(user.getDeptId());
        }
        userService.updateById(dbUser);
        return Result.success("更新成功", "");
    }

    @DeleteMapping("/delete/{id}")
    @OperationLog(module = "用户管理", type = "删除", description = "删除系统用户")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<String> delete(@PathVariable Long id) {
        if (id == 1L) {
            return Result.error("超级管理员不可删除");
        }
        userService.removeById(id);
        return Result.success("删除成功", "");
    }

    @PutMapping("/reset-password/{id}")
    @OperationLog(module = "用户管理", type = "更新", description = "重置用户密码")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public Result<String> resetPassword(@PathVariable Long id, @RequestParam(defaultValue = "123456") String password) {
        User user = userService.getById(id);
        if (user == null) {
            return Result.error("用户不存在");
        }
        user.setPassword(PasswordUtil.encode(password));
        userService.updateById(user);
        return Result.success("密码重置成功", "");
    }
}
