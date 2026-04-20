package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.AnalysisRule;
import com.hr.datacenter.mapper.mysql.AnalysisRuleMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class AnalysisRuleService extends ServiceImpl<AnalysisRuleMapper, AnalysisRule> {

    public Map<String, String> getActiveRuleMap(String ruleType) {
        LambdaQueryWrapper<AnalysisRule> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AnalysisRule::getEffectStatus, 1);
        if (StringUtils.hasText(ruleType)) {
            wrapper.eq(AnalysisRule::getRuleType, ruleType);
        }
        List<AnalysisRule> rules = this.list(wrapper);
        Map<String, String> result = new HashMap<>();
        for (AnalysisRule rule : rules) {
            result.put(rule.getRuleKey(), rule.getRuleValue());
        }
        return result;
    }

    public double getDoubleRule(String ruleType, String ruleKey, double defaultValue) {
        String value = getActiveRuleMap(ruleType).get(ruleKey);
        if (!StringUtils.hasText(value)) {
            return defaultValue;
        }
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    public int getIntRule(String ruleType, String ruleKey, int defaultValue) {
        String value = getActiveRuleMap(ruleType).get(ruleKey);
        if (!StringUtils.hasText(value)) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }
}
