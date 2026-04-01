package com.hr.backend.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hr.backend.model.entity.DataCategory;

import java.util.List;

public interface DataCategoryService extends IService<DataCategory> {

    List<DataCategory> tree();

    /**
     * 分页查询数据分类列表
     * @param page 分页参数
     * @param name 分类名称（可选，支持模糊查询）
     * @return 分页结果
     */
    IPage<DataCategory> page(Page<DataCategory> page, String name);
}
