import request from './request'

/**
 * 申请请假
 */
export function applyLeave(data) {
  return request({
    url: '/leave/apply',
    method: 'post',
    data
  })
}

/**
 * 审批请假
 */
export function approveLeave(data) {
  return request({
    url: '/leave/approve',
    method: 'post',
    params: data
  })
}

/**
 * 撤回请假
 */
export function withdrawLeave(data) {
  return request({
    url: '/leave/withdraw',
    method: 'post',
    params: data
  })
}

/**
 * 获取请假列表
 */
export function getLeaveList(params) {
  return request({
    url: '/leave/list',
    method: 'get',
    params
  })
}

/**
 * 获取待审批列表
 */
export function getPendingApprovalList(params) {
  return request({
    url: '/leave/pending',
    method: 'get',
    params
  })
}
