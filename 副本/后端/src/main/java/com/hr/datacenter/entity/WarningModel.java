package com.hr.datacenter.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("warning_model")
public class WarningModel {
    @TableId(value = "model_id", type = IdType.AUTO)
    private Long modelId;
    private String modelName;
    private String modelType;
    private String featureWeights;
    private Double accuracyRate;
    private String modelVersion;
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
