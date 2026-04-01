import request from './request'

export function getCategoryList() {
  return request({ url: '/category/list', method: 'get' })
}

export function getCategoryTree() {
  return request({ url: '/category/tree', method: 'get' })
}

export function addCategory(data) {
  return request({ url: '/category', method: 'post', data })
}

export function updateCategory(id, data) {
  return request({ url: `/category/${id}`, method: 'put', data })
}

export function deleteCategory(id) {
  return request({ url: `/category/${id}`, method: 'delete' })
}

/**
 * 分页查询数据分类列表
 * @param {Object} params - 分页参数
 * @param {number} params.current - 当前页码，默认1
 * @param {number} params.size - 每页条数，默认10
 * @param {string} params.name - 分类名称（可选，支持模糊查询）
 * @returns {Promise} 分页结果
 */
export function getCategoryPage(params) {
  return request({ url: '/category/page', method: 'get', params })
}
