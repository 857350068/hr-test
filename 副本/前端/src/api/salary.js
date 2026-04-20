import request from './request'

/**
 * 薪资发放相关API
 */

/**
 * 分页查询薪资发放
 */
export function getPaymentList(params) {
    return request({
        url: '/salary/payment/page',
        method: 'get',
        params
    })
}

/**
 * 新增薪资发放
 */
export function addPayment(data) {
    return request({
        url: '/salary/payment/add',
        method: 'post',
        data
    })
}

/**
 * 更新薪资发放
 */
export function updatePayment(data) {
    return request({
        url: '/salary/payment/update',
        method: 'post',
        data
    })
}

/**
 * 发放薪资
 */
export function releasePayment(paymentId) {
    return request({
        url: `/salary/payment/release/${paymentId}`,
        method: 'post'
    })
}

/**
 * 获取员工薪资统计
 */
export function getSalaryStatistics(params) {
    return request({
        url: '/salary/payment/statistics',
        method: 'get',
        params
    })
}

/**
 * 薪资调整相关API
 */

/**
 * 分页查询薪资调整
 */
export function getAdjustmentList(params) {
    return request({
        url: '/salary/adjustment/page',
        method: 'get',
        params
    })
}

/**
 * 申请薪资调整
 */
export function applyAdjustment(data) {
    return request({
        url: '/salary/adjustment/apply',
        method: 'post',
        data
    })
}

/**
 * 审批薪资调整
 */
export function approveAdjustment(params) {
    return request({
        url: '/salary/adjustment/approve',
        method: 'post',
        params
    })
}

/**
 * 获取待审批列表
 */
export function getPendingApprovalList(params) {
    return request({
        url: '/salary/adjustment/pending',
        method: 'get',
        params
    })
}
