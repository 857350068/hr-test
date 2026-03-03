package com.hr.backend.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hr.backend.model.entity.DataCategory;

import java.util.List;

public interface DataCategoryService extends IService<DataCategory> {

    List<DataCategory> tree();
}
