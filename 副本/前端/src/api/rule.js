import request from './request'

export function getRuleList(ruleType) {
  return request({
    url: '/system/rule/list',
    method: 'get',
    params: { ruleType }
  })
}

export function addRule(data) {
  return request({
    url: '/system/rule/add',
    method: 'post',
    data
  })
}

export function updateRule(data) {
  return request({
    url: '/system/rule/update',
    method: 'put',
    data
  })
}

export function deleteRule(id) {
  return request({
    url: `/system/rule/delete/${id}`,
    method: 'delete'
  })
}

export function effectRule(id) {
  return request({
    url: `/system/rule/effect/${id}`,
    method: 'put'
  })
}
