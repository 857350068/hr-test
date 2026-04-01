import request from './request'

export function getDepartmentList() {
  return request({ url: '/department/list', method: 'get' })
}

export function getDepartmentTree() {
  return request({ url: '/department/tree', method: 'get' })
}

export function getDepartmentById(id) {
  return request({ url: `/department/${id}`, method: 'get' })
}

export function addDepartment(data) {
  return request({ url: '/department', method: 'post', data })
}

export function updateDepartment(id, data) {
  return request({ url: `/department/${id}`, method: 'put', data })
}

export function deleteDepartment(id) {
  return request({ url: `/department/${id}`, method: 'delete' })
}

/**
 * 分页查询部门列表
 * @param {Object} params - 分页参数
 * @param {number} params.current - 当前页码，默认1
 * @param {number} params.size - 每页条数，默认10
 * @param {string} params.name - 部门名称（可选，支持模糊查询）
 * @returns {Promise} 分页结果
 */
export function getDepartmentPage(params) {
  return request({ url: '/department/page', method: 'get', params })
}
