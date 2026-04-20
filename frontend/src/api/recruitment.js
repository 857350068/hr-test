import request from './request'

export function getRecruitmentList(params) {
  return request({
    url: '/recruitment/list',
    method: 'get',
    params
  })
}

export function addRecruitment(data) {
  return request({
    url: '/recruitment/add',
    method: 'post',
    data
  })
}

export function updateRecruitment(data) {
  return request({
    url: '/recruitment/update',
    method: 'put',
    data
  })
}

export function deleteRecruitment(id) {
  return request({
    url: `/recruitment/delete/${id}`,
    method: 'delete'
  })
}
