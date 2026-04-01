package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.mapper.ReportTemplateMapper;
import com.hr.backend.model.entity.ReportTemplate;
import com.hr.backend.service.ReportTemplateService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

@Service
public class ReportTemplateServiceImpl extends ServiceImpl<ReportTemplateMapper, ReportTemplate> implements ReportTemplateService {

    @Override
    public IPage<ReportTemplate> page(Page<ReportTemplate> page, String category, String name) {
        LambdaQueryWrapper<ReportTemplate> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.isNotBlank(category)) {
            wrapper.eq(ReportTemplate::getCategory, category);
        }
        if (StringUtils.isNotBlank(name)) {
            wrapper.like(ReportTemplate::getName, name);
        }
        wrapper.orderByDesc(ReportTemplate::getCreateTime);
        return this.page(page, wrapper);
    }
}
