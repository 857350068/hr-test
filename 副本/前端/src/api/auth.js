import request from './request'

/**
 * 用户登录
 */
export function login(data) {
    return request({
        url: '/auth/login',
        method: 'post',
        data
    })
}

/**
 * 用户登出
 */
export function logout() {
    return request({
        url: '/auth/logout',
        method: 'post'
    })
}

/**
 * 用户注册
 */
export function register(data) {
    return request({
        url: '/auth/register',
        method: 'post',
        data
    })
}

export function getProfile() {
    return request({
        url: '/auth/profile',
        method: 'get'
    })
}

export function updateProfile(data) {
    return request({
        url: '/auth/profile',
        method: 'put',
        data
    })
}

export function changePassword(data) {
    return request({
        url: '/auth/change-password',
        method: 'put',
        data
    })
}
