package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.UserFavorite;
import com.hr.datacenter.mapper.mysql.UserFavoriteMapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserFavoriteService extends ServiceImpl<UserFavoriteMapper, UserFavorite> {
    public List<UserFavorite> listByUserId(Long userId) {
        return this.list(new LambdaQueryWrapper<UserFavorite>()
                .eq(UserFavorite::getUserId, userId)
                .orderByDesc(UserFavorite::getCreateTime));
    }
}
