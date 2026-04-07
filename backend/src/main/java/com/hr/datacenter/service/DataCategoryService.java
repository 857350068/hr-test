package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.DataCategory;
import com.hr.datacenter.mapper.mysql.DataCategoryMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 数据分类Service
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class DataCategoryService extends ServiceImpl<DataCategoryMapper, DataCategory> {

    /**
     * 分页查询数据分类
     */
    public IPage<DataCategory> getCategoryPage(int page, int size, String keyword) {
        Page<DataCategory> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<DataCategory> wrapper = new LambdaQueryWrapper<>();

        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(DataCategory::getCategoryName, keyword)
                    .or().like(DataCategory::getCategoryCode, keyword));
        }

        wrapper.orderByAsc(DataCategory::getSortOrder);
        return this.page(pageParam, wrapper);
    }

    /**
     * 获取所有启用的分类
     */
    public List<DataCategory> getActiveCategories() {
        LambdaQueryWrapper<DataCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DataCategory::getStatus, 1)
                .orderByAsc(DataCategory::getSortOrder);
        return this.list(wrapper);
    }

    /**
     * 根据父ID获取子分类
     */
    public List<DataCategory> getCategoriesByParentId(Long parentId) {
        LambdaQueryWrapper<DataCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DataCategory::getParentId, parentId)
                .eq(DataCategory::getStatus, 1)
                .orderByAsc(DataCategory::getSortOrder);
        return this.list(wrapper);
    }

    /**
     * 新增分类
     */
    public boolean addCategory(DataCategory category) {
        return this.save(category);
    }

    /**
     * 更新分类
     */
    public boolean updateCategory(DataCategory category) {
        return this.updateById(category);
    }

    /**
     * 删除分类
     */
    public boolean deleteCategory(Long categoryId) {
        return this.removeById(categoryId);
    }
}
