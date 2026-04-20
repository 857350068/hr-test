package com.hr.datacenter.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.ReportExecutionLog;
import com.hr.datacenter.mapper.mysql.ReportExecutionLogMapper;
import org.springframework.stereotype.Service;

@Service
public class ReportExecutionLogService extends ServiceImpl<ReportExecutionLogMapper, ReportExecutionLog> {
}
