import request from './request'
import axios from 'axios'

export function getReportTaskList() {
  return request({
    url: '/system/report/task/list',
    method: 'get'
  })
}

export function addReportTask(data) {
  return request({
    url: '/system/report/task/add',
    method: 'post',
    data
  })
}

export function updateReportTask(data) {
  return request({
    url: '/system/report/task/update',
    method: 'put',
    data
  })
}

export function deleteReportTask(id) {
  return request({
    url: `/system/report/task/delete/${id}`,
    method: 'delete'
  })
}

export function exportReport(reportType) {
  return request({
    url: '/system/report/export',
    method: 'get',
    params: { reportType }
  })
}

export function shareReport(reportType, target) {
  return request({
    url: '/system/report/share',
    method: 'post',
    params: { reportType, target }
  })
}

export async function downloadReportFile(reportType) {
  const token = localStorage.getItem('token')
  const response = await axios({
    url: `/api/system/report/export-file`,
    method: 'get',
    params: { reportType },
    responseType: 'blob',
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  })
  return response.data
}

export async function downloadGeneratedReportFile(fileName, disposition = 'attachment') {
  const token = localStorage.getItem('token')
  const response = await axios({
    url: `/api/system/report/file/${encodeURIComponent(fileName)}`,
    method: 'get',
    params: { disposition },
    responseType: 'blob',
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  })
  return response.data
}

export function getReportExecutionLogs() {
  return request({
    url: '/system/report/execution-log/list',
    method: 'get'
  })
}

export function rebuildExecutionLogFile(logId) {
  return request({
    url: `/system/report/execution-log/rebuild/${logId}`,
    method: 'post'
  })
}

export function getReportShareLogs() {
  return request({
    url: '/system/report/share-log/list',
    method: 'get'
  })
}
