package com.hr.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hr.backend.model.entity.ReportScheduleTask;
import org.apache.ibatis.annotations.Mapper;

/**
 * 报表定时任务Mapper接口
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Mapper
public interface ReportScheduleTaskMapper extends BaseMapper<ReportScheduleTask> {

}
