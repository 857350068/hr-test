import request from './request'

/**
 * 绩效目标相关API
 */

/**
 * 分页查询绩效目标
 */
export function getGoalList(params) {
    return request({
        url: '/performance/goal/page',
        method: 'get',
        params
    })
}

/**
 * 新增绩效目标
 */
export function addGoal(data) {
    return request({
        url: '/performance/goal/add',
        method: 'post',
        data
    })
}

/**
 * 更新绩效目标
 */
export function updateGoal(data) {
    return request({
        url: '/performance/goal/update',
        method: 'post',
        data
    })
}

/**
 * 删除绩效目标
 */
export function deleteGoal(goalId) {
    return request({
        url: `/performance/goal/delete/${goalId}`,
        method: 'post'
    })
}

/**
 * 获取员工绩效目标
 */
export function getEmployeeGoals(params) {
    return request({
        url: '/performance/goal/employee',
        method: 'get',
        params
    })
}

/**
 * 绩效评估相关API
 */

/**
 * 分页查询绩效评估
 */
export function getEvaluationList(params) {
    return request({
        url: '/performance/evaluation/page',
        method: 'get',
        params
    })
}

/**
 * 自评
 */
export function selfEvaluate(data) {
    return request({
        url: '/performance/evaluation/self',
        method: 'post',
        data
    })
}

/**
 * 上级评价
 */
export function supervisorEvaluate(data) {
    return request({
        url: '/performance/evaluation/supervisor',
        method: 'post',
        data
    })
}

/**
 * 更新面谈记录
 */
export function updateInterviewRecord(params) {
    return request({
        url: '/performance/evaluation/interview',
        method: 'post',
        params
    })
}
