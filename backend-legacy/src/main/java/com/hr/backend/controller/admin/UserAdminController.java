package com.hr.backend.controller.admin;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hr.backend.common.Response;
import com.hr.backend.model.entity.User;
import com.hr.backend.service.UserService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;

@RestController
@RequestMapping("/api/admin/users")
@PreAuthorize("hasRole('HR_ADMIN')")
public class UserAdminController {

    @Resource
    private UserService userService;

    @GetMapping
    public Response<IPage<User>> page(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String role) {
        IPage<User> page = userService.page(new Page<>(current, size), username, name, role);
        page.getRecords().forEach(u -> u.setPassword(null));
        return Response.success(page);
    }

    @GetMapping("/{id}")
    public Response<User> getById(@PathVariable Long id) {
        User u = userService.getById(id);
        if (u != null) u.setPassword(null);
        return Response.success(u);
    }

    @PostMapping
    public Response<Void> add(@RequestBody User user) {
        userService.saveUser(user);
        return Response.success();
    }

    @PutMapping("/{id}")
    public Response<Void> update(@PathVariable Long id, @RequestBody User user) {
        user.setId(id);
        user.setPassword(null);
        userService.updateById(user);
        return Response.success();
    }

    @DeleteMapping("/{id}")
    public Response<Void> delete(@PathVariable Long id) {
        userService.removeById(id);
        return Response.success();
    }
}
