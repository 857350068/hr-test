package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.mapper.FavoriteMapper;
import com.hr.backend.model.entity.Favorite;
import com.hr.backend.service.FavoriteService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class FavoriteServiceImpl extends ServiceImpl<FavoriteMapper, Favorite> implements FavoriteService {

    @Override
    public List<Favorite> listByUserId(Long userId) {
        return list(new LambdaQueryWrapper<Favorite>().eq(Favorite::getUserId, userId).orderByDesc(Favorite::getCreateTime));
    }

    @Override
    public IPage<Favorite> pageByUser(Page<Favorite> page, Long userId, String favType) {
        LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Favorite::getUserId, userId); // 必须按用户ID过滤，实现数据隔离
        if (StringUtils.isNotBlank(favType)) {
            wrapper.eq(Favorite::getFavType, favType);
        }
        wrapper.orderByDesc(Favorite::getCreateTime);
        return this.page(page, wrapper);
    }
}
