import request from './request'

/**
 * 上班打卡
 */
export function clockIn(empId) {
  return request({
    url: '/attendance/clockIn',
    method: 'post',
    params: { empId }
  })
}

/**
 * 下班打卡
 */
export function clockOut(empId) {
  return request({
    url: '/attendance/clockOut',
    method: 'post',
    params: { empId }
  })
}

/**
 * 获取今日考勤记录
 */
export function getTodayAttendance(empId) {
  return request({
    url: '/attendance/today',
    method: 'get',
    params: { empId }
  })
}

/**
 * 获取考勤列表
 */
export function getAttendanceList(params) {
  return request({
    url: '/attendance/list',
    method: 'get',
    params
  })
}

/**
 * 获取考勤统计
 */
export function getAttendanceStats(params) {
  return request({
    url: '/attendance/stats',
    method: 'get',
    params
  })
}
