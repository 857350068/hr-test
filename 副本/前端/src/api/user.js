import request from './request'

export function getUserList(params) {
  return request({
    url: '/system/user/list',
    method: 'get',
    params
  })
}

export function addUser(data) {
  return request({
    url: '/system/user/add',
    method: 'post',
    data
  })
}

export function updateUser(data) {
  return request({
    url: '/system/user/update',
    method: 'put',
    data
  })
}

export function deleteUser(id) {
  return request({
    url: `/system/user/delete/${id}`,
    method: 'delete'
  })
}

export function resetUserPassword(id, password = '123456') {
  return request({
    url: `/system/user/reset-password/${id}`,
    method: 'put',
    params: { password }
  })
}
