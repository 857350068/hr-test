import request from './request'

/**
 * 预警模型管理API
 */

// 创建预警模型
export function createModel(data) {
  return request({
    url: '/api/warning-models',
    method: 'post',
    data
  })
}

// 调整特征权重
export function adjustWeights(modelId, weights) {
  return request({
    url: `/api/warning-models/${modelId}/weights`,
    method: 'put',
    data: weights
  })
}

// 验证模型准确率
export function validateModel(modelId) {
  return request({
    url: `/api/warning-models/${modelId}/validate`,
    method: 'post'
  })
}

// 查询预警模型
export function getModel(modelId) {
  return request({
    url: `/api/warning-models/${modelId}`,
    method: 'get'
  })
}

// 分页查询预警模型
export function queryModels(params) {
  return request({
    url: '/api/warning-models',
    method: 'get',
    params
  })
}
