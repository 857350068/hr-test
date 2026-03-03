package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.mapper.ReportTemplateMapper;
import com.hr.backend.model.entity.ReportTemplate;
import com.hr.backend.service.ReportTemplateService;
import org.springframework.stereotype.Service;

@Service
public class ReportTemplateServiceImpl extends ServiceImpl<ReportTemplateMapper, ReportTemplate> implements ReportTemplateService {
}
