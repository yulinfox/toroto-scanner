import request from '@/utils/request'

export function scan(data) {
  return request({
    url: '/api/scan',
    method: 'POST',
    data: data
  })
}
