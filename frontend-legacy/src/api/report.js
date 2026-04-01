import request from './request'

export function getReportList() {
  return request({ url: '/report/list', method: 'get' })
}

export function getReportById(id) {
  return request({ url: `/report/${id}`, method: 'get' })
}

export function addReport(data) {
  return request({ url: '/report', method: 'post', data })
}

export function updateReport(id, data) {
  return request({ url: `/report/${id}`, method: 'put', data })
}

export function deleteReport(id) {
  return request({ url: `/report/${id}`, method: 'delete' })
}

export function previewReportData(sql) {
  return request({ url: '/report/preview', method: 'post', data: { sql } })
}

/**
 * 分页查询报表模板列表
 * @param {Object} params - 分页参数
 * @param {number} params.current - 当前页码，默认1
 * @param {number} params.size - 每页条数，默认10
 * @param {string} params.category - 报表分类（可选，支持精确查询）
 * @param {string} params.name - 报表名称（可选，支持模糊查询）
 * @returns {Promise} 分页结果
 */
export function getReportPage(params) {
  return request({ url: '/report/page', method: 'get', params })
}
