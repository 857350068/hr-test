package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.mapper.EmployeeProfileMapper;
import com.hr.backend.model.entity.EmployeeProfile;
import com.hr.backend.service.EmployeeProfileService;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class EmployeeProfileServiceImpl extends ServiceImpl<EmployeeProfileMapper, EmployeeProfile> implements EmployeeProfileService {

    @Override
    public IPage<EmployeeProfile> page(Page<EmployeeProfile> page, String employeeNo, String name, String deptName, String period, Long categoryId) {
        LambdaQueryWrapper<EmployeeProfile> q = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(employeeNo)) q.like(EmployeeProfile::getEmployeeNo, employeeNo);
        if (StringUtils.hasText(name)) q.like(EmployeeProfile::getName, name);
        if (StringUtils.hasText(deptName)) q.like(EmployeeProfile::getDeptName, deptName);
        if (StringUtils.hasText(period)) q.eq(EmployeeProfile::getPeriod, period);
        if (categoryId != null) q.eq(EmployeeProfile::getCategoryId, categoryId);
        q.orderByDesc(EmployeeProfile::getCreateTime);
        return page(page, q);
    }
}
