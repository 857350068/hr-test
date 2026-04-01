import request from './request'

export function getRuleList() {
  return request({ url: '/rule/list', method: 'get' })
}

export function getRuleById(id) {
  return request({ url: `/rule/${id}`, method: 'get' })
}

export function addRule(data) {
  return request({ url: '/rule', method: 'post', data })
}

export function updateRule(id, data) {
  return request({ url: `/rule/${id}`, method: 'put', data })
}

export function deleteRule(id) {
  return request({ url: `/rule/${id}`, method: 'delete' })
}

/**
 * 分页查询预警规则列表
 * @param {Object} params - 分页参数
 * @param {number} params.current - 当前页码，默认1
 * @param {number} params.size - 每页条数，默认10
 * @param {string} params.ruleType - 规则类型（可选，支持精确查询）
 * @param {boolean} params.isActive - 生效状态（可选，支持精确查询）
 * @returns {Promise} 分页结果
 */
export function getRulePage(params) {
  return request({ url: '/rule/page', method: 'get', params })
}
