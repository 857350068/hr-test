package com.hr.backend.service;

import java.util.Map;

public interface AnalysisService {

    Map<String, Object> getOrganizationEfficiencyData(String period);

    Map<String, Object> getTalentPipelineData(String period);

    Map<String, Object> getCompensationBenefitData(String period);

    Map<String, Object> getPerformanceManagementData(String period);

    Map<String, Object> getEmployeeTurnoverData(String period);

    Map<String, Object> getTrainingEffectData(String period);

    Map<String, Object> getHumanCostOptimizationData(String period);

    Map<String, Object> getTalentDevelopmentData(String period);
}
