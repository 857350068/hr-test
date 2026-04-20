package com.hr.datacenter.mapper.mysql;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hr.datacenter.entity.PerformanceEvaluation;
import org.apache.ibatis.annotations.Mapper;

/**
 * 绩效评估Mapper接口
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Mapper
public interface PerformanceEvaluationMapper extends BaseMapper<PerformanceEvaluation> {
}
