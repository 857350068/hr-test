import request from './request'

/**
 * 分析规则管理API
 */

// 创建分析规则
export function createRule(data) {
  return request({
    url: '/api/analysis-rules',
    method: 'post',
    data
  })
}

// 更新分析规则
export function updateRule(ruleId, data) {
  return request({
    url: `/api/analysis-rules/${ruleId}`,
    method: 'put',
    data
  })
}

// 删除分析规则
export function deleteRule(ruleId) {
  return request({
    url: `/api/analysis-rules/${ruleId}`,
    method: 'delete'
  })
}

// 查询分析规则
export function getRule(ruleId) {
  return request({
    url: `/api/analysis-rules/${ruleId}`,
    method: 'get'
  })
}

// 分页查询分析规则
export function queryRules(params) {
  return request({
    url: '/api/analysis-rules',
    method: 'get',
    params
  })
}

// 切换规则生效状态
export function toggleRuleStatus(ruleId, active) {
  return request({
    url: `/api/analysis-rules/${ruleId}/status`,
    method: 'put',
    params: { active }
  })
}
