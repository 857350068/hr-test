package com.hr.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hr.backend.model.entity.TrainingFeedback;
import org.apache.ibatis.annotations.Mapper;

/**
 * 培训效果反馈Mapper接口
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Mapper
public interface TrainingFeedbackMapper extends BaseMapper<TrainingFeedback> {

}
