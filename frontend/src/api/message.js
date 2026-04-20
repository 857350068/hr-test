import request from './request'

export function broadcastMessage(data) {
  return request({
    url: '/message/broadcast',
    method: 'post',
    data
  })
}

export function sendMessage(data) {
  return request({
    url: '/message/send',
    method: 'post',
    data
  })
}

export function getMessageList(params) {
  return request({
    url: '/message/list',
    method: 'get',
    params
  })
}

export function getUnreadCount(userId) {
  return request({
    url: '/message/unread-count',
    method: 'get',
    params: { userId }
  })
}

export function markMessageRead(messageId) {
  return request({
    url: `/message/read/${messageId}`,
    method: 'put'
  })
}

export function markAllMessagesRead(userId) {
  return request({
    url: '/message/read-all',
    method: 'put',
    params: { userId }
  })
}

export function deleteMessage(messageId) {
  return request({
    url: `/message/delete/${messageId}`,
    method: 'delete'
  })
}
