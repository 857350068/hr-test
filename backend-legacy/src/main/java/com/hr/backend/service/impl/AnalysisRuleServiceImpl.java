package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hr.backend.exception.BusinessException;
import com.hr.backend.mapper.AnalysisRuleMapper;
import com.hr.backend.mapper.RuleAdjustmentLogMapper;
import com.hr.backend.model.dto.AnalysisRuleDTO;
import com.hr.backend.model.dto.AnalysisRuleQueryDTO;
import com.hr.backend.model.dto.AnalysisRuleVO;
import com.hr.backend.model.entity.AnalysisRule;
import com.hr.backend.model.entity.RuleAdjustmentLog;
import com.hr.backend.security.SecurityUtil;
import com.hr.backend.service.AnalysisRuleService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 分析规则服务实现类
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Slf4j
@Service
public class AnalysisRuleServiceImpl extends ServiceImpl<AnalysisRuleMapper, AnalysisRule> implements AnalysisRuleService {

    private final AnalysisRuleMapper ruleMapper;
    private final RuleAdjustmentLogMapper logMapper;
    private final ObjectMapper objectMapper;

    public AnalysisRuleServiceImpl(AnalysisRuleMapper ruleMapper, 
                                   RuleAdjustmentLogMapper logMapper,
                                   ObjectMapper objectMapper) {
        this.ruleMapper = ruleMapper;
        this.logMapper = logMapper;
        this.objectMapper = objectMapper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public String createRule(AnalysisRuleDTO dto) {
        log.info("创建分析规则，规则类型：{}，规则名称：{}", dto.getRuleType(), dto.getRuleName());

        // 1. 验证规则参数合法性
        validateRuleParams(dto);

        // 2. 检查规则名称是否重复
        checkDuplicateName(dto.getRuleName());

        // 3. 生成规则ID
        String ruleId = generateRuleId();

        // 4. 保存规则记录
        AnalysisRule rule = new AnalysisRule();
        BeanUtils.copyProperties(dto, rule);
        rule.setRuleId(ruleId);
        String currentUser = SecurityUtil.getCurrentUsername();
        rule.setCreatedBy(currentUser);
        rule.setUpdatedBy(currentUser);
        ruleMapper.insert(rule);

        // 5. 记录操作日志
        saveAdjustmentLog(ruleId, "CREATE", null, toJsonString(rule), "创建规则");

        log.info("分析规则创建成功，规则ID：{}", ruleId);
        return ruleId;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateRule(String ruleId, AnalysisRuleDTO dto) {
        log.info("更新分析规则，规则ID：{}", ruleId);

        // 1. 查询现有规则
        AnalysisRule existingRule = ruleMapper.selectOne(
            new LambdaQueryWrapper<AnalysisRule>().eq(AnalysisRule::getRuleId, ruleId)
        );
        if (existingRule == null) {
            throw new BusinessException("RULE_NOT_FOUND", "规则不存在");
        }

        // 2. 验证规则参数合法性
        validateRuleParams(dto);

        // 3. 记录调整前的值
        String oldValue = toJsonString(existingRule);

        // 4. 更新规则参数
        existingRule.setRuleName(dto.getRuleName());
        existingRule.setRuleParams(dto.getRuleParams());
        existingRule.setRuleType(dto.getRuleType());
        existingRule.setIsActive(dto.getIsActive());
        existingRule.setUpdatedBy(SecurityUtil.getCurrentUsername());
        existingRule.setUpdatedTime(LocalDateTime.now());
        ruleMapper.updateById(existingRule);

        // 5. 记录调整日志
        String newValue = toJsonString(existingRule);
        saveAdjustmentLog(ruleId, "UPDATE", oldValue, newValue, "更新规则");

        log.info("分析规则更新成功，规则ID：{}", ruleId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteRule(String ruleId) {
        log.info("删除分析规则，规则ID：{}", ruleId);

        // 1. 查询规则状态
        AnalysisRule rule = ruleMapper.selectOne(
            new LambdaQueryWrapper<AnalysisRule>().eq(AnalysisRule::getRuleId, ruleId)
        );
        if (rule == null) {
            throw new BusinessException("RULE_NOT_FOUND", "规则不存在");
        }

        // 2. 检查是否为已生效规则
        if (rule.getIsActive()) {
            throw new BusinessException("CANNOT_DELETE_ACTIVE_RULE", "已生效规则不能删除，请先设置为失效状态");
        }

        // 3. 删除规则记录
        ruleMapper.deleteById(rule.getId());

        // 4. 记录操作日志
        saveAdjustmentLog(ruleId, "DELETE", toJsonString(rule), null, "删除规则");

        log.info("分析规则删除成功，规则ID：{}", ruleId);
    }

    @Override
    public AnalysisRuleVO getRule(String ruleId) {
        AnalysisRule rule = ruleMapper.selectOne(
            new LambdaQueryWrapper<AnalysisRule>().eq(AnalysisRule::getRuleId, ruleId)
        );
        if (rule == null) {
            throw new BusinessException("RULE_NOT_FOUND", "规则不存在");
        }
        return convertToVO(rule);
    }

    @Override
    public Page<AnalysisRuleVO> queryRules(AnalysisRuleQueryDTO query) {
        LambdaQueryWrapper<AnalysisRule> wrapper = new LambdaQueryWrapper<>();

        // 规则类型
        if (query.getRuleType() != null && !query.getRuleType().isEmpty()) {
            wrapper.eq(AnalysisRule::getRuleType, query.getRuleType());
        }

        // 规则名称模糊查询
        if (query.getRuleName() != null && !query.getRuleName().isEmpty()) {
            wrapper.like(AnalysisRule::getRuleName, query.getRuleName());
        }

        // 生效状态
        if (query.getIsActive() != null) {
            wrapper.eq(AnalysisRule::getIsActive, query.getIsActive());
        }

        // 按创建时间倒序
        wrapper.orderByDesc(AnalysisRule::getCreatedTime);

        Page<AnalysisRule> page = new Page<>(query.getPageNum(), query.getPageSize());
        Page<AnalysisRule> result = ruleMapper.selectPage(page, wrapper);

        // 转换为VO
        Page<AnalysisRuleVO> voPage = new Page<>();
        BeanUtils.copyProperties(result, voPage, "records");
        List<AnalysisRuleVO> voList = result.getRecords().stream()
            .map(this::convertToVO)
            .collect(Collectors.toList());
        voPage.setRecords(voList);

        return voPage;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void toggleRuleStatus(String ruleId, Boolean active) {
        log.info("切换规则状态，规则ID：{}，新状态：{}", ruleId, active);

        AnalysisRule rule = ruleMapper.selectOne(
            new LambdaQueryWrapper<AnalysisRule>().eq(AnalysisRule::getRuleId, ruleId)
        );
        if (rule == null) {
            throw new BusinessException("RULE_NOT_FOUND", "规则不存在");
        }

        String oldValue = toJsonString(rule);
        rule.setIsActive(active);
        rule.setUpdatedBy(SecurityUtil.getCurrentUsername());
        rule.setUpdatedTime(LocalDateTime.now());
        ruleMapper.updateById(rule);

        String adjustmentType = active ? "ACTIVATE" : "DEACTIVATE";
        String remark = active ? "激活规则" : "失效规则";
        saveAdjustmentLog(ruleId, adjustmentType, oldValue, toJsonString(rule), remark);

        log.info("规则状态切换成功");
    }

    /**
     * 验证规则参数合法性
     */
    private void validateRuleParams(AnalysisRuleDTO dto) {
        // 验证规则类型
        String ruleType = dto.getRuleType();
        if (!ruleType.matches("TURNOVER_WARNING|COMPENSATION_BENCHMARK|TRAINING_ROI|PERFORMANCE_EVAL|TALENT_GAP")) {
            throw new BusinessException("INVALID_RULE_TYPE", "不支持的规则类型");
        }

        // 验证规则参数是否为合法JSON
        try {
            objectMapper.readTree(dto.getRuleParams());
        } catch (JsonProcessingException e) {
            throw new BusinessException("INVALID_RULE_PARAMS", "规则参数不是合法的JSON格式");
        }
    }

    /**
     * 检查规则名称是否重复
     */
    private void checkDuplicateName(String ruleName) {
        Long count = ruleMapper.selectCount(
            new LambdaQueryWrapper<AnalysisRule>().eq(AnalysisRule::getRuleName, ruleName)
        );
        if (count > 0) {
            throw new BusinessException("DUPLICATE_RULE_NAME", "规则名称已存在，请使用其他名称");
        }
    }

    /**
     * 生成规则ID
     */
    private String generateRuleId() {
        String dateStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        Long count = ruleMapper.selectCount(null);
        return String.format("RULE_%s_%04d", dateStr, count + 1);
    }

    /**
     * 保存调整日志
     */
    private void saveAdjustmentLog(String ruleId, String adjustmentType, String oldValue, String newValue, String remark) {
        RuleAdjustmentLog log = new RuleAdjustmentLog();
        log.setLogId(generateLogId());
        log.setRuleId(ruleId);
        log.setAdjustmentType(adjustmentType);
        log.setOldValue(oldValue);
        log.setNewValue(newValue);
        log.setAdjustedBy(SecurityUtil.getCurrentUsername());
        log.setAdjustedTime(LocalDateTime.now());
        log.setRemark(remark);
        logMapper.insert(log);
    }

    /**
     * 生成日志ID
     */
    private String generateLogId() {
        return "LOG_" + System.currentTimeMillis();
    }

    /**
     * 转换为JSON字符串
     */
    private String toJsonString(Object obj) {
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            return "{}";
        }
    }

    /**
     * 转换为VO
     */
    private AnalysisRuleVO convertToVO(AnalysisRule rule) {
        AnalysisRuleVO vo = new AnalysisRuleVO();
        BeanUtils.copyProperties(rule, vo);
        return vo;
    }
}
