import request from './request'

/**
 * 获取员工列表
 */
export function getEmployeeList(params) {
    return request({
        url: '/employee/list',
        method: 'get',
        params
    })
}

/**
 * 获取员工详情
 */
export function getEmployeeById(id) {
    return request({
        url: `/employee/${id}`,
        method: 'get'
    })
}

/**
 * 新增员工
 */
export function addEmployee(data) {
    return request({
        url: '/employee/add',
        method: 'post',
        data
    })
}

/**
 * 更新员工
 */
export function updateEmployee(data) {
    return request({
        url: '/employee/update',
        method: 'put',
        data
    })
}

/**
 * 删除员工
 */
export function deleteEmployee(id) {
    return request({
        url: `/employee/delete/${id}`,
        method: 'delete'
    })
}

/**
 * 获取员工总数
 */
export function getTotalCount() {
    return request({
        url: '/employee/total',
        method: 'get'
    })
}
