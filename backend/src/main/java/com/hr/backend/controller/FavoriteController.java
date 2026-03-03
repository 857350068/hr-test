package com.hr.backend.controller;

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
