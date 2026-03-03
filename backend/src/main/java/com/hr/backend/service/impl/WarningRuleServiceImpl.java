package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.mapper.WarningRuleMapper;
import com.hr.backend.model.entity.WarningRule;
import com.hr.backend.service.WarningRuleService;
import org.springframework.stereotype.Service;

@Service
public class WarningRuleServiceImpl extends ServiceImpl<WarningRuleMapper, WarningRule> implements WarningRuleService {
}
