import api from './api'

export async function downloadFile(url, filename, params = {}) {
  const response = await api.get(url, { params, responseType: 'blob' })
  const blobUrl = URL.createObjectURL(response.data)
  const link = document.createElement('a')
  link.href = blobUrl
  link.download = filename
  document.body.appendChild(link)
  link.click()
  link.remove()
  URL.revokeObjectURL(blobUrl)
}

export async function uploadFile(url, file) {
  const form = new FormData()
  form.append('file', file)
  return api.post(url, form, { headers: { 'Content-Type': 'multipart/form-data' } })
}
