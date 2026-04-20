import request from './request'

export function getFavoriteList() {
  return request({
    url: '/favorite/list',
    method: 'get'
  })
}

export function addFavorite(data) {
  return request({
    url: '/favorite/add',
    method: 'post',
    data
  })
}

export function deleteFavorite(id) {
  return request({
    url: `/favorite/delete/${id}`,
    method: 'delete'
  })
}
