package com.hr.datacenter.controller;

import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.User;
import com.hr.datacenter.entity.UserFavorite;
import com.hr.datacenter.service.UserFavoriteService;
import com.hr.datacenter.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/favorite")
@CrossOrigin(origins = "*")
@Validated
public class FavoriteController {

    @Autowired
    private UserFavoriteService favoriteService;
    @Autowired
    private UserService userService;

    @GetMapping("/list")
    public Result<List<UserFavorite>> list(@RequestParam(required = false) String favoriteType, Principal principal) {
        User user = userService.getUserByUsername(principal.getName());
        List<UserFavorite> data = favoriteService.listByUserId(user.getUserId());
        if (favoriteType != null && !favoriteType.isEmpty()) {
            data = data.stream().filter(item -> favoriteType.equals(item.getFavoriteType())).collect(Collectors.toList());
        }
        return Result.success(data);
    }

    @PostMapping("/add")
    public Result<String> add(@RequestBody UserFavorite favorite, Principal principal) {
        User user = userService.getUserByUsername(principal.getName());
        UserFavorite exists = favoriteService.getOne(new LambdaQueryWrapper<UserFavorite>()
                .eq(UserFavorite::getUserId, user.getUserId())
                .eq(UserFavorite::getFavoriteType, favorite.getFavoriteType())
                .eq(UserFavorite::getTargetKey, favorite.getTargetKey())
                .last("LIMIT 1"));
        if (exists != null) {
            return Result.success("已存在相同收藏", "");
        }
        favorite.setFavoriteId(null);
        favorite.setUserId(user.getUserId());
        favoriteService.save(favorite);
        return Result.success("收藏成功", "");
    }

    @DeleteMapping("/delete/{id}")
    public Result<String> delete(@PathVariable Long id, Principal principal) {
        User user = userService.getUserByUsername(principal.getName());
        UserFavorite row = favoriteService.getById(id);
        if (row == null || !user.getUserId().equals(row.getUserId())) {
            return Result.error("收藏不存在");
        }
        favoriteService.removeById(id);
        return Result.success("取消收藏成功", "");
    }
}
