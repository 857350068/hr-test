package com.hr.backend.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hr.backend.model.dto.AnalysisRuleDTO;
import com.hr.backend.model.dto.AnalysisRuleQueryDTO;
import com.hr.backend.model.dto.AnalysisRuleVO;
import com.hr.backend.model.entity.AnalysisRule;

/**
 * 分析规则服务接口
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
public interface AnalysisRuleService {

    /**
     * 创建分析规则
     *
     * @param dto 规则DTO
     * @return 规则ID
     */
    String createRule(AnalysisRuleDTO dto);

    /**
     * 更新分析规则
     *
     * @param ruleId 规则ID
     * @param dto 规则DTO
     */
    void updateRule(String ruleId, AnalysisRuleDTO dto);

    /**
     * 删除分析规则
     *
     * @param ruleId 规则ID
     */
    void deleteRule(String ruleId);

    /**
     * 查询分析规则
     *
     * @param ruleId 规则ID
     * @return 规则VO
     */
    AnalysisRuleVO getRule(String ruleId);

    /**
     * 分页查询分析规则
     *
     * @param query 查询条件
     * @return 分页结果
     */
    Page<AnalysisRuleVO> queryRules(AnalysisRuleQueryDTO query);

    /**
     * 切换规则生效状态
     *
     * @param ruleId 规则ID
     * @param active 是否生效
     */
    void toggleRuleStatus(String ruleId, Boolean active);
}
