package com.hr.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hr.backend.model.entity.WarningModel;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.math.BigDecimal;

/**
 * 预警模型Mapper接口
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Mapper
public interface WarningModelMapper extends BaseMapper<WarningModel> {

    /**
     * 更新模型准确率
     *
     * @param modelId 模型ID
     * @param accuracyRate 准确率
     * @return 影响行数
     */
    int updateAccuracyRate(@Param("modelId") String modelId, @Param("accuracyRate") BigDecimal accuracyRate);
}
