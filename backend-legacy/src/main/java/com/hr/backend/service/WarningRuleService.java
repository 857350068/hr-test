package com.hr.backend.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hr.backend.model.entity.WarningRule;

public interface WarningRuleService extends IService<WarningRule> {

    /**
     * 分页查询预警规则列表
     * @param page 分页参数
     * @param ruleType 规则类型（可选，支持精确查询）
     * @param isActive 生效状态（可选，支持精确查询）
     * @return 分页结果
     */
    IPage<WarningRule> page(Page<WarningRule> page, String ruleType, Boolean isActive);
}
