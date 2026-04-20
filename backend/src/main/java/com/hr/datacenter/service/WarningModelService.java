package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hr.datacenter.entity.WarningModel;
import com.hr.datacenter.mapper.mysql.WarningModelMapper;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.Map;

@Service
public class WarningModelService extends ServiceImpl<WarningModelMapper, WarningModel> {
    private final ObjectMapper objectMapper = new ObjectMapper();

    public WarningModel getActiveModel(String modelType) {
        return this.getOne(new LambdaQueryWrapper<WarningModel>()
                .eq(WarningModel::getModelType, modelType)
                .eq(WarningModel::getStatus, 1)
                .orderByDesc(WarningModel::getUpdateTime)
                .last("LIMIT 1"));
    }

    public Map<String, Double> getFeatureWeights(String modelType) {
        WarningModel model = getActiveModel(modelType);
        if (model == null || model.getFeatureWeights() == null || model.getFeatureWeights().trim().isEmpty()) {
            return Collections.emptyMap();
        }
        try {
            return objectMapper.readValue(model.getFeatureWeights(), new TypeReference<Map<String, Double>>() {});
        } catch (Exception ex) {
            return Collections.emptyMap();
        }
    }
}
