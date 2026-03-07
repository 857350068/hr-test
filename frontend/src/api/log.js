import request from './request'

export function getLogPage(params) {
  return request({ url: '/admin/logs', method: 'get', params })
}

export function getLogById(id) {
  return request({ url: `/admin/logs/${id}`, method: 'get' })
}

export function deleteLog(id) {
  return request({ url: `/admin/logs/${id}`, method: 'delete' })
}
