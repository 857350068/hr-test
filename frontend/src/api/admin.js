import request from './request'

export function getUserPage(params) {
  return request({ url: '/admin/users', method: 'get', params })
}

export function getUserById(id) {
  return request({ url: `/admin/users/${id}`, method: 'get' })
}

export function addUser(data) {
  return request({ url: '/admin/users', method: 'post', data })
}

export function updateUser(id, data) {
  return request({ url: `/admin/users/${id}`, method: 'put', data })
}

export function deleteUser(id) {
  return request({ url: `/admin/users/${id}`, method: 'delete' })
}

export function triggerSync() {
  return request({ url: '/admin/sync/trigger', method: 'post' })
}

export function getSyncLogs(limit = 20) {
  return request({ url: '/admin/sync/logs', method: 'get', params: { limit } })
}
