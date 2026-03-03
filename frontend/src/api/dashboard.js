import request from './request'

export function getStatistics() {
  return request({ url: '/dashboard/statistics', method: 'get' })
}

export function getWarnings() {
  return request({ url: '/dashboard/warnings', method: 'get' })
}
