package com.hr.datacenter.mapper.mysql;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hr.datacenter.entity.SalaryPayment;
import org.apache.ibatis.annotations.Mapper;

/**
 * 薪资发放Mapper接口
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Mapper
public interface SalaryPaymentMapper extends BaseMapper<SalaryPayment> {
}
