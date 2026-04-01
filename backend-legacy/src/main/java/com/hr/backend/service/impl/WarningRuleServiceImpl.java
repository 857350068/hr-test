package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.mapper.WarningRuleMapper;
import com.hr.backend.model.entity.WarningRule;
import com.hr.backend.service.WarningRuleService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

@Service
public class WarningRuleServiceImpl extends ServiceImpl<WarningRuleMapper, WarningRule> implements WarningRuleService {

    @Override
    public IPage<WarningRule> page(Page<WarningRule> page, String ruleType, Boolean isActive) {
        LambdaQueryWrapper<WarningRule> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.isNotBlank(ruleType)) {
            wrapper.eq(WarningRule::getRuleType, ruleType);
        }
        if (isActive != null) {
            wrapper.eq(WarningRule::getEffective, isActive ? 1 : 0);
        }
        wrapper.orderByDesc(WarningRule::getCreateTime);
        return this.page(page, wrapper);
    }
}
