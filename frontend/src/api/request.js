import axios from 'axios'
import { ElMessage } from 'element-plus'

// 创建axios实例
const request = axios.create({
    baseURL: '/api',
    timeout: 30000
})

// 请求拦截器
request.interceptors.request.use(
    config => {
        // 从localStorage获取token
        const token = localStorage.getItem('token')
        if (token) {
            config.headers['Authorization'] = 'Bearer ' + token
        }
        return config
    },
    error => {
        console.error('请求错误:', error)
        return Promise.reject(error)
    }
)

// 响应拦截器
request.interceptors.response.use(
    response => {
        const res = response.data

        // 如果返回的状态码不是200,说明接口有问题
        if (res.code !== 200) {
            ElMessage.error(res.message || '请求失败')

            // 401: 未授权,跳转到登录页
            if (res.code === 401) {
                localStorage.removeItem('token')
                localStorage.removeItem('userInfo')
                window.location.href = '/login'
            }

            return Promise.reject(new Error(res.message || '请求失败'))
        }

        return res
    },
    error => {
        console.error('响应错误:', error)
        if (error.code === 'ECONNABORTED' || (error.message && error.message.toLowerCase().includes('timeout'))) {
            ElMessage.error('请求超时(30s)，请稍后重试或减少筛选范围')
        } else if (error.response) {
            const status = error.response.status
            if (status >= 500) {
                ElMessage.error('服务繁忙或分析引擎异常，请稍后重试')
            } else if (status === 404) {
                ElMessage.error('接口不存在，请联系管理员检查部署配置')
            } else if (status === 401) {
                ElMessage.error('登录已过期，请重新登录')
            } else if (status === 403) {
                ElMessage.error('暂无权限访问该数据')
            } else {
                ElMessage.error(error.message || '请求失败')
            }
        } else {
            ElMessage.error('网络连接异常，请检查与服务器连通性')
        }
        return Promise.reject(error)
    }
)

export default request
