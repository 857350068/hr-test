package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.PerformanceGoal;
import com.hr.datacenter.mapper.PerformanceGoalMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * 绩效目标Service
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class PerformanceGoalService extends ServiceImpl<PerformanceGoalMapper, PerformanceGoal> {

    /**
     * 分页查询绩效目标
     */
    public IPage<PerformanceGoal> getGoalPage(int page, int size, Long empId, Integer year, Integer periodType) {
        Page<PerformanceGoal> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<PerformanceGoal> wrapper = new LambdaQueryWrapper<>();
        
        if (empId != null) {
            wrapper.eq(PerformanceGoal::getEmpId, empId);
        }
        if (year != null) {
            wrapper.eq(PerformanceGoal::getYear, year);
        }
        if (periodType != null) {
            wrapper.eq(PerformanceGoal::getPeriodType, periodType);
        }
        
        wrapper.orderByDesc(PerformanceGoal::getYear)
               .orderByAsc(PerformanceGoal::getPeriodType);
        return this.page(pageParam, wrapper);
    }

    /**
     * 新增绩效目标
     */
    public boolean addGoal(PerformanceGoal goal) {
        return this.save(goal);
    }

    /**
     * 更新绩效目标
     */
    public boolean updateGoal(PerformanceGoal goal) {
        return this.updateById(goal);
    }

    /**
     * 删除绩效目标
     */
    public boolean deleteGoal(Long goalId) {
        return this.removeById(goalId);
    }

    /**
     * 获取员工绩效目标(用于自评)
     */
    public java.util.List<PerformanceGoal> getEmployeeGoals(Long empId, Integer year, Integer periodType) {
        LambdaQueryWrapper<PerformanceGoal> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PerformanceGoal::getEmpId, empId);
        if (year != null) {
            wrapper.eq(PerformanceGoal::getYear, year);
        }
        if (periodType != null) {
            wrapper.eq(PerformanceGoal::getPeriodType, periodType);
        }
        wrapper.eq(PerformanceGoal::getGoalStatus, 2); // 2-已完成
        return this.list(wrapper);
    }
}
