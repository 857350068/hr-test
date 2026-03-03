package com.hr.backend.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hr.backend.model.entity.Favorite;

import java.util.List;

public interface FavoriteService extends IService<Favorite> {

    List<Favorite> listByUserId(Long userId);
}
