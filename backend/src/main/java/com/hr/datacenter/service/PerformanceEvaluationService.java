package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.PerformanceEvaluation;
import com.hr.datacenter.mapper.mysql.PerformanceEvaluationMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

/**
 * 绩效评估Service
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class PerformanceEvaluationService extends ServiceImpl<PerformanceEvaluationMapper, PerformanceEvaluation> {

    /**
     * 分页查询绩效评估
     */
    public IPage<PerformanceEvaluation> getEvaluationPage(int page, int size, Long empId, Integer year, Integer periodType) {
        Page<PerformanceEvaluation> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<PerformanceEvaluation> wrapper = new LambdaQueryWrapper<>();
        
        if (empId != null) {
            wrapper.eq(PerformanceEvaluation::getEmpId, empId);
        }
        if (year != null) {
            wrapper.eq(PerformanceEvaluation::getYear, year);
        }
        if (periodType != null) {
            wrapper.eq(PerformanceEvaluation::getPeriodType, periodType);
        }
        
        wrapper.orderByDesc(PerformanceEvaluation::getYear)
               .orderByAsc(PerformanceEvaluation::getPeriodType);
        return this.page(pageParam, wrapper);
    }

    /**
     * 自评
     */
    public boolean selfEvaluate(PerformanceEvaluation evaluation) {
        evaluation.setEvaluationStatus(1); // 1-已自评
        return this.saveOrUpdate(evaluation);
    }

    /**
     * 上级评价
     */
    public boolean supervisorEvaluate(PerformanceEvaluation evaluation) {
        evaluation.setEvaluationStatus(2); // 2-已评价
        
        // 计算综合评分(自评40% + 上评60%)
        if (evaluation.getSelfScore() != null && evaluation.getSupervisorScore() != null) {
            double finalScore = evaluation.getSelfScore().doubleValue() * 0.4 + evaluation.getSupervisorScore().doubleValue() * 0.6;
            evaluation.setFinalScore(BigDecimal.valueOf(Math.round(finalScore * 100) / 100.0));

            // 确定绩效等级
            String level = determinePerformanceLevel(evaluation.getFinalScore().doubleValue());
            evaluation.setPerformanceLevel(level);
        }
        
        evaluation.setEvaluationStatus(3); // 3-已完成
        return this.updateById(evaluation);
    }

    /**
     * 确定绩效等级
     */
    private String determinePerformanceLevel(double score) {
        if (score >= 90) return "S";
        if (score >= 80) return "A";
        if (score >= 70) return "B";
        if (score >= 60) return "C";
        return "D";
    }

    /**
     * 获取员工绩效评估
     */
    public PerformanceEvaluation getEmployeeEvaluation(Long empId, Integer year, Integer periodType) {
        LambdaQueryWrapper<PerformanceEvaluation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PerformanceEvaluation::getEmpId, empId);
        if (year != null) {
            wrapper.eq(PerformanceEvaluation::getYear, year);
        }
        if (periodType != null) {
            wrapper.eq(PerformanceEvaluation::getPeriodType, periodType);
        }
        wrapper.orderByDesc(PerformanceEvaluation::getCreateTime)
               .last("LIMIT 1");
        return this.getOne(wrapper);
    }

    /**
     * 更新面谈记录
     */
    public boolean updateInterviewRecord(Long evaluationId, String interviewRecord, java.time.LocalDateTime interviewDate) {
        PerformanceEvaluation evaluation = this.getById(evaluationId);
        if (evaluation == null) {
            throw new RuntimeException("评估记录不存在");
        }
        evaluation.setInterviewRecord(interviewRecord);
        evaluation.setInterviewDate(interviewDate);
        return this.updateById(evaluation);
    }
}
