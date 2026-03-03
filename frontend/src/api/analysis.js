import request from './request'

export function getOrganizationEfficiency(params) {
  return request({ url: '/analysis/organization-efficiency', method: 'get', params })
}

export function getTalentPipeline(params) {
  return request({ url: '/analysis/talent-pipeline', method: 'get', params })
}

export function getCompensationBenefit(params) {
  return request({ url: '/analysis/compensation-benefit', method: 'get', params })
}

export function getPerformanceManagement(params) {
  return request({ url: '/analysis/performance-management', method: 'get', params })
}

export function getEmployeeTurnover(params) {
  return request({ url: '/analysis/employee-turnover', method: 'get', params })
}

export function getTrainingEffect(params) {
  return request({ url: '/analysis/training-effect', method: 'get', params })
}

export function getHumanCostOptimization(params) {
  return request({ url: '/analysis/human-cost-optimization', method: 'get', params })
}

export function getTalentDevelopment(params) {
  return request({ url: '/analysis/talent-development', method: 'get', params })
}
