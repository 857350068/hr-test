package com.hr.backend.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hr.backend.common.Response;
import com.hr.backend.model.entity.Favorite;
import com.hr.backend.security.SecurityUtil;
import com.hr.backend.service.FavoriteService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/favorite")
public class FavoriteController {

    @Resource
    private FavoriteService favoriteService;

    @GetMapping("/list")
    public Response<List<Favorite>> list() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Response.success(favoriteService.listByUserId(userId));
    }

    /**
     * 分页查询当前用户的收藏列表（实现用户数据隔离）
     * @param current 当前页码，默认1
     * @param size 每页条数，默认10
     * @param favType 收藏类型（可选，支持精确查询）
     * @return 分页结果
     */
    @GetMapping("/page")
    public Response<IPage<Favorite>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) String favType) {
        Long userId = SecurityUtil.getCurrentUserId();
        Page<Favorite> page = new Page<>(current, size);
        IPage<Favorite> result = favoriteService.pageByUser(page, userId, favType);
        return Response.success(result);
    }

    @PostMapping
    public Response<Void> add(@RequestBody Favorite favorite) {
        favorite.setUserId(SecurityUtil.getCurrentUserId());
        favoriteService.save(favorite);
        return Response.success();
    }

    @DeleteMapping("/{id}")
    public Response<Void> delete(@PathVariable Long id) {
        favoriteService.removeById(id);
        return Response.success();
    }
}
