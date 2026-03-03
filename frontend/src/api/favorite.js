import request from './request'

export function getFavoriteList() {
  return request({ url: '/favorite/list', method: 'get' })
}

export function addFavorite(data) {
  return request({ url: '/favorite', method: 'post', data })
}

export function deleteFavorite(id) {
  return request({ url: `/favorite/${id}`, method: 'delete' })
}
