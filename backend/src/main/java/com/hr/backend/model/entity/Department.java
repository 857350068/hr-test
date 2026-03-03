package com.hr.backend.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("hr_department")
public class Department {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private Long parentId;
    private Integer sortOrder;
}
