package com.hr.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hr.backend.model.entity.ReportShareRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 报表分享记录Mapper接口
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Mapper
public interface ReportShareRecordMapper extends BaseMapper<ReportShareRecord> {

    /**
     * 根据分享链接token查询分享记录
     *
     * @param shareLink 分享链接
     * @return 分享记录
     */
    ReportShareRecord selectByShareLink(@Param("shareLink") String shareLink);
}
