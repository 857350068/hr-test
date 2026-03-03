package com.hr.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hr.backend.model.entity.EmployeeProfile;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@org.apache.ibatis.annotations.Mapper
public interface EmployeeProfileMapper extends BaseMapper<EmployeeProfile> {

    List<EmployeeProfile> selectAllForSync();
}
