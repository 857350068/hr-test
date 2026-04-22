import request from './request'

export function getRuntimeProfile() {
  return request({
    url: '/system/runtime/profile',
    method: 'get'
  })
}
