import request from './request'

// ==================== 员工流失预警 ====================

/**
 * 获取员工流失风险分析
 */
export function getTurnoverRiskAnalysis() {
  return request({
    url: '/warning/turnover/risk-analysis',
    method: 'get'
  })
}

/**
 * 获取部门流失率统计
 */
export function getDepartmentTurnoverRate() {
  return request({
    url: '/warning/turnover/department-rate',
    method: 'get'
  })
}

/**
 * 获取流失预警概览
 */
export function getTurnoverWarningOverview(params = {}) {
  return request({
    url: '/warning/turnover/overview',
    method: 'get',
    params
  })
}

// ==================== 人才缺口预警 ====================

/**
 * 获取人才缺口分析
 */
export function getTalentGapAnalysis() {
  return request({
    url: '/warning/talent-gap/analysis',
    method: 'get'
  })
}

/**
 * 获取部门人才结构分析
 */
export function getDepartmentStructureAnalysis() {
  return request({
    url: '/warning/talent-gap/structure',
    method: 'get'
  })
}

/**
 * 获取人才缺口预警概览
 */
export function getTalentGapWarningOverview(params = {}) {
  return request({
    url: '/warning/talent-gap/overview',
    method: 'get',
    params
  })
}

/**
 * 获取人力成本超支分析
 */
export function getCostOverrunAnalysis() {
  return request({
    url: '/warning/cost/overrun-analysis',
    method: 'get'
  })
}

/**
 * 获取人力成本超支概览
 */
export function getCostOverview() {
  return request({
    url: '/warning/cost/overview',
    method: 'get'
  })
}
