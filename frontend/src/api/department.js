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
