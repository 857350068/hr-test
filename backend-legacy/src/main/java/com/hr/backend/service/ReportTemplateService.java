package com.hr.backend.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hr.backend.model.entity.ReportTemplate;

public interface ReportTemplateService extends IService<ReportTemplate> {

    /**
     * 分页查询报表模板列表
     * @param page 分页参数
     * @param category 报表分类（可选，支持精确查询）
     * @param name 报表名称（可选，支持模糊查询）
     * @return 分页结果
     */
    IPage<ReportTemplate> page(Page<ReportTemplate> page, String category, String name);
}
