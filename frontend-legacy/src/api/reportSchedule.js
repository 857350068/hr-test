import request from './request'

/**
 * 报表定时任务管理API
 */

// 创建报表定时任务
export function createTask(data) {
  return request({
    url: '/api/report-schedules',
    method: 'post',
    data
  })
}

// 更新报表定时任务
export function updateTask(taskId, data) {
  return request({
    url: `/api/report-schedules/${taskId}`,
    method: 'put',
    data
  })
}

// 删除报表定时任务
export function deleteTask(taskId) {
  return request({
    url: `/api/report-schedules/${taskId}`,
    method: 'delete'
  })
}

// 查询报表定时任务
export function getTask(taskId) {
  return request({
    url: `/api/report-schedules/${taskId}`,
    method: 'get'
  })
}

// 分页查询报表定时任务
export function queryTasks(params) {
  return request({
    url: '/api/report-schedules',
    method: 'get',
    params
  })
}

// 访问分享报表
export function accessSharedReport(token) {
  return request({
    url: `/api/report-schedules/share/${token}`,
    method: 'get'
  })
}
