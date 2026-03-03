package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.mapper.FavoriteMapper;
import com.hr.backend.model.entity.Favorite;
import com.hr.backend.service.FavoriteService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class FavoriteServiceImpl extends ServiceImpl<FavoriteMapper, Favorite> implements FavoriteService {

    @Override
    public List<Favorite> listByUserId(Long userId) {
        return list(new LambdaQueryWrapper<Favorite>().eq(Favorite::getUserId, userId).orderByDesc(Favorite::getCreateTime));
    }
}
