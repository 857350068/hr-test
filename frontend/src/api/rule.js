import request from './request'

export function getRuleList() {
  return request({ url: '/rule/list', method: 'get' })
}

export function getRuleById(id) {
  return request({ url: `/rule/${id}`, method: 'get' })
}

export function addRule(data) {
  return request({ url: '/rule', method: 'post', data })
}

export function updateRule(id, data) {
  return request({ url: `/rule/${id}`, method: 'put', data })
}

export function deleteRule(id) {
  return request({ url: `/rule/${id}`, method: 'delete' })
}
