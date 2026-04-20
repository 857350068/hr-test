package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.RecruitmentPlan;
import com.hr.datacenter.mapper.mysql.RecruitmentPlanMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class RecruitmentPlanService extends ServiceImpl<RecruitmentPlanMapper, RecruitmentPlan> {

    public IPage<RecruitmentPlan> getPage(int page, int size, String keyword, Integer status) {
        Page<RecruitmentPlan> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<RecruitmentPlan> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(RecruitmentPlan::getRecruitCode, keyword)
                    .or().like(RecruitmentPlan::getDepartment, keyword)
                    .or().like(RecruitmentPlan::getPosition, keyword)
                    .or().like(RecruitmentPlan::getOwner, keyword));
        }
        if (status != null) {
            wrapper.eq(RecruitmentPlan::getStatus, status);
        }
        wrapper.orderByDesc(RecruitmentPlan::getCreateTime);
        return this.page(pageParam, wrapper);
    }
}
