import request from './request'

/**
 * 培训课程相关API
 */
export function getCourseList(params) {
    return request({
        url: '/training/course/page',
        method: 'get',
        params
    })
}

export function addCourse(data) {
    return request({
        url: '/training/course/add',
        method: 'post',
        data
    })
}

export function updateCourse(data) {
    return request({
        url: '/training/course/update',
        method: 'post',
        data
    })
}

export function deleteCourse(courseId) {
    return request({
        url: `/training/course/delete/${courseId}`,
        method: 'post'
    })
}

/**
 * 培训报名相关API
 */
export function getEnrollmentList(params) {
    return request({
        url: '/training/enrollment/page',
        method: 'get',
        params
    })
}

export function enrollTraining(data) {
    return request({
        url: '/training/enrollment/enroll',
        method: 'post',
        data
    })
}

export function approveEnrollment(params) {
    return request({
        url: '/training/enrollment/approve',
        method: 'post',
        params
    })
}

export function checkIn(enrollmentId) {
    return request({
        url: `/training/enrollment/checkIn/${enrollmentId}`,
        method: 'post'
    })
}

export function submitScore(params) {
    return request({
        url: '/training/enrollment/submitScore',
        method: 'post',
        params
    })
}
