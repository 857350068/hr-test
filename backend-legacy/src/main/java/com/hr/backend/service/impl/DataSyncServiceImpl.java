package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hr.backend.mapper.DataSyncLogMapper;
import com.hr.backend.mapper.EmployeeProfileMapper;
import com.hr.backend.model.entity.DataSyncLog;
import com.hr.backend.model.entity.EmployeeProfile;
import com.hr.backend.service.DataSyncService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
public class DataSyncServiceImpl implements DataSyncService {

    @Resource
    private EmployeeProfileMapper employeeProfileMapper;

    @Resource
    private DataSyncLogMapper dataSyncLogMapper;

    @Override
    public Map<String, Object> triggerSync() {
        Date start = new Date();
        long count = 0;
        String status = "SUCCESS";
        String details = "";

        try {
            List<EmployeeProfile> list = employeeProfileMapper.selectAllForSync();
            count = list.size();
            // 实际同步到 Hive 需在虚拟机环境配置 Hive 数据源后实现，此处仅记录日志
            log.info("数据同步: 从 MySQL 读取 {} 条记录，可在此处写入 Hive", count);
            details = "已从MySQL读取 " + count + " 条，Hive写入需配置Hive数据源后启用";
        } catch (Exception e) {
            log.error("同步失败", e);
            status = "FAILED";
            details = e.getMessage();
        }

        DataSyncLog logEntity = new DataSyncLog();
        logEntity.setStartTime(start);
        logEntity.setEndTime(new Date());
        logEntity.setStatus(status);
        logEntity.setRecordsProcessed(count);
        logEntity.setDetails(details);
        dataSyncLogMapper.insert(logEntity);

        Map<String, Object> result = new HashMap<>();
        result.put("status", status);
        result.put("recordsProcessed", count);
        result.put("details", details);
        return result;
    }

    @Override
    public List<DataSyncLog> listRecent(int limit) {
        return dataSyncLogMapper.selectList(
                new LambdaQueryWrapper<DataSyncLog>().orderByDesc(DataSyncLog::getCreateTime).last("LIMIT " + limit));
    }
}
