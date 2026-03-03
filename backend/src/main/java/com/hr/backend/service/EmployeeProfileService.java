package com.hr.backend.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hr.backend.model.entity.EmployeeProfile;

public interface EmployeeProfileService extends IService<EmployeeProfile> {

    IPage<EmployeeProfile> page(Page<EmployeeProfile> page, String employeeNo, String deptName, String period, Long categoryId);
}
