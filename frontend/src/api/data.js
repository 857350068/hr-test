import request from './request'

export function getEmployeePage(params) {
  return request({ url: '/data/employee/page', method: 'get', params })
}

export function getEmployeeById(id) {
  return request({ url: `/data/employee/${id}`, method: 'get' })
}

export function addEmployee(data) {
  return request({ url: '/data/employee', method: 'post', data })
}

export function updateEmployee(id, data) {
  return request({ url: `/data/employee/${id}`, method: 'put', data })
}

export function deleteEmployee(id) {
  return request({ url: `/data/employee/${id}`, method: 'delete' })
}
