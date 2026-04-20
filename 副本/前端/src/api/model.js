import request from './request'

export function getModelList(modelType) {
  return request({
    url: '/system/model/list',
    method: 'get',
    params: { modelType }
  })
}

export function addModel(data) {
  return request({
    url: '/system/model/add',
    method: 'post',
    data
  })
}

export function updateModel(data) {
  return request({
    url: '/system/model/update',
    method: 'put',
    data
  })
}

export function deleteModel(id) {
  return request({
    url: `/system/model/delete/${id}`,
    method: 'delete'
  })
}
