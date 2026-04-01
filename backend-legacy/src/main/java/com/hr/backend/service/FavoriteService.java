package com.hr.backend.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hr.backend.model.entity.Favorite;

import java.util.List;

public interface FavoriteService extends IService<Favorite> {

    List<Favorite> listByUserId(Long userId);

    /**
     * 分页查询当前用户的收藏列表（实现用户数据隔离）
     * @param page 分页参数
     * @param userId 用户ID（必须，用于数据隔离）
     * @param favType 收藏类型（可选，支持精确查询）
     * @return 分页结果
     */
    IPage<Favorite> pageByUser(Page<Favorite> page, Long userId, String favType);
}
