package com.hr.datacenter.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("recruitment_plan")
public class RecruitmentPlan implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(value = "recruit_id", type = IdType.AUTO)
    private Long recruitId;

    private String recruitCode;

    private String department;

    private String position;

    private Integer planCount;

    private Integer hiredCount;

    private BigDecimal budget;

    private Integer status;

    private LocalDate startDate;

    private LocalDate endDate;

    private String owner;

    private String remark;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    @TableLogic
    private Integer deleted;
}
