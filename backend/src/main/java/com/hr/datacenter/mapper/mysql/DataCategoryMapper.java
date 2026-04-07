package com.hr.datacenter.mapper.mysql;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hr.datacenter.entity.DataCategory;
import org.apache.ibatis.annotations.Mapper;

/**
 * 数据分类Mapper
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Mapper
public interface DataCategoryMapper extends BaseMapper<DataCategory> {
}
