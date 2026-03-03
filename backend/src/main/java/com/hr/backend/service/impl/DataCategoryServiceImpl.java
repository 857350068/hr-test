package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.mapper.DataCategoryMapper;
import com.hr.backend.model.entity.DataCategory;
import com.hr.backend.service.DataCategoryService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class DataCategoryServiceImpl extends ServiceImpl<DataCategoryMapper, DataCategory> implements DataCategoryService {

    @Override
    public List<DataCategory> tree() {
        List<DataCategory> all = list();
        return all.stream().filter(c -> c.getParentId() == null || c.getParentId() == 0).collect(Collectors.toList());
    }
}
