package com.hr.backend.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.util.Date;

@Data
@TableName("employee_profile")
public class EmployeeProfile {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String employeeNo;
    private String name;
    private Long deptId;
    private String deptName;
    private String job;
    private Long categoryId;
    private Float value;
    private String period;
    @TableLogic
    private Integer isDeleted;
    private Date createTime;
}
