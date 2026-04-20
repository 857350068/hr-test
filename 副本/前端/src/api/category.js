import request from './request'

/**
 * 获取数据分类列表
 */
export function getCategoryList(page, size, keyword) {
  return request({
    url: '/data-category/list',
    method: 'get',
    params: { page, size, keyword }
  })
}

/**
 * 获取所有启用的分类
 */
export function getActiveCategories() {
  return request({
    url: '/data-category/active',
    method: 'get'
  })
}

/**
 * 根据父ID获取子分类
 */
export function getCategoriesByParentId(parentId) {
  return request({
    url: `/data-category/children/${parentId}`,
    method: 'get'
  })
}

/**
 * 根据ID查询分类
 */
export function getCategoryById(id) {
  return request({
    url: `/data-category/${id}`,
    method: 'get'
  })
}

/**
 * 新增分类
 */
export function addCategory(data) {
  return request({
    url: '/data-category/add',
    method: 'post',
    data
  })
}

/**
 * 更新分类
 */
export function updateCategory(data) {
  return request({
    url: '/data-category/update',
    method: 'put',
    data
  })
}

/**
 * 删除分类
 */
export function deleteCategory(id) {
  return request({
    url: `/data-category/delete/${id}`,
    method: 'delete'
  })
}
