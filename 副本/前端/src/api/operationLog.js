import request from './request'

export function getOperationLogList(params) {
  return request({
    url: '/operation-log/list',
    method: 'get',
    params
  })
}

export function getOperationLogDetail(logId) {
  return request({
    url: `/operation-log/${logId}`,
    method: 'get'
  })
}

export function deleteOperationLog(logId) {
  return request({
    url: `/operation-log/delete/${logId}`,
    method: 'delete'
  })
}

export function batchDeleteOperationLogs(logIds) {
  return request({
    url: '/operation-log/batch-delete',
    method: 'delete',
    data: logIds
  })
}

export function clearOperationLogs(days) {
  return request({
    url: '/operation-log/clear',
    method: 'delete',
    params: { days }
  })
}
