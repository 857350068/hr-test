import request from './request'

export function getFavoriteList() {
  return request({ url: '/favorite/list', method: 'get' })
}

export function addFavorite(data) {
  return request({ url: '/favorite', method: 'post', data })
}

export function deleteFavorite(id) {
  return request({ url: `/favorite/${id}`, method: 'delete' })
}

/**
 * 分页查询当前用户的收藏列表（实现用户数据隔离）
 * @param {Object} params - 分页参数
 * @param {number} params.current - 当前页码，默认1
 * @param {number} params.size - 每页条数，默认10
 * @param {string} params.favType - 收藏类型（可选，支持精确查询）
 * @returns {Promise} 分页结果
 */
export function getFavoritePage(params) {
  return request({ url: '/favorite/page', method: 'get', params })
}
