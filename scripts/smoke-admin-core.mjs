const BASE = process.env.API_BASE || 'http://192.168.116.131/api'
const USER = process.env.SMOKE_USER || 'admin'
const PASS = process.env.SMOKE_PASS || '123456'

let token = ''
let adminUserId = null
const failures = []

async function request(method, path, { body, parseJson = true } = {}) {
  const headers = {}
  if (token) headers.Authorization = `Bearer ${token}`
  if (body !== undefined && body !== null) headers['Content-Type'] = 'application/json'

  const res = await fetch(`${BASE}${path}`, {
    method,
    headers,
    body: body === undefined || body === null ? undefined : JSON.stringify(body)
  })

  const text = await res.text()
  if (!parseJson) {
    return { http: res.status, text }
  }

  let json = null
  try {
    json = text ? JSON.parse(text) : null
  } catch {
    json = { code: -1, message: `JSON解析失败: ${text.slice(0, 120)}` }
  }
  return { http: res.status, json }
}

function pass(name) {
  console.log(`OK   ${name}`)
}

function fail(name, detail) {
  const msg = `${name} -> ${detail}`
  console.log(`FAIL ${msg}`)
  failures.push(msg)
}

function assertResult(name, result) {
  const code = result?.json?.code
  if (result.http === 200 && code === 200) {
    pass(name)
    return true
  }
  fail(name, `http=${result.http} code=${code} message=${result?.json?.message}`)
  return false
}

async function login() {
  const result = await request('POST', '/auth/login', {
    body: { username: USER, password: PASS }
  })
  if (!assertResult('POST /auth/login', result)) {
    process.exit(1)
  }
  token = result.json.data?.token || ''
  adminUserId = result.json.data?.userId
  if (!token || !adminUserId) {
    fail('POST /auth/login', '缺少token或userId')
    process.exit(1)
  }
}

async function smokeSystemUser() {
  const username = `smoke_user_${Date.now()}`
  const addPayload = {
    username,
    password: '123456',
    realName: '冒烟用户',
    phone: '13900001234',
    email: `${username}@example.com`,
    roleCode: 'ROLE_HR_ADMIN',
    status: 1
  }

  assertResult('GET /system/user/list', await request('GET', '/system/user/list?page=1&size=10'))
  assertResult('POST /system/user/add', await request('POST', '/system/user/add', { body: addPayload }))

  const listResult = await request('GET', `/system/user/list?page=1&size=50&keyword=${username}`)
  assertResult('GET /system/user/list (after add)', listResult)
  const user = (listResult.json?.data?.records || []).find((x) => x.username === username)
  if (!user?.userId) {
    fail('GET /system/user/list (lookup)', '未找到新建用户')
    return
  }

  assertResult('PUT /system/user/update', await request('PUT', '/system/user/update', {
    body: { userId: user.userId, realName: '冒烟用户-更新', status: 1 }
  }))
  assertResult('PUT /system/user/reset-password/{id}', await request('PUT', `/system/user/reset-password/${user.userId}`))
  assertResult('DELETE /system/user/delete/{id}', await request('DELETE', `/system/user/delete/${user.userId}`))
}

async function smokeRule() {
  const ruleName = `smoke-rule-${Date.now()}`
  assertResult('GET /system/rule/list', await request('GET', '/system/rule/list'))
  assertResult('POST /system/rule/add', await request('POST', '/system/rule/add', {
    body: {
      ruleName,
      ruleType: 'turnover',
      ruleKey: `smoke.key.${Date.now()}`,
      ruleValue: '0.5',
      effectStatus: 0
    }
  }))

  const listResult = await request('GET', '/system/rule/list')
  assertResult('GET /system/rule/list (after add)', listResult)
  const row = (listResult.json?.data || []).find((x) => x.ruleName === ruleName)
  if (!row?.ruleId) {
    fail('GET /system/rule/list (lookup)', '未找到新建规则')
    return
  }

  assertResult('PUT /system/rule/update', await request('PUT', '/system/rule/update', {
    body: {
      ruleId: row.ruleId,
      ruleName: `${ruleName}-u`,
      ruleType: 'turnover',
      ruleKey: row.ruleKey,
      ruleValue: '0.6',
      effectStatus: 0
    }
  }))
  assertResult('DELETE /system/rule/delete/{id}', await request('DELETE', `/system/rule/delete/${row.ruleId}`))
}

async function smokeModel() {
  const modelName = `smoke-model-${Date.now()}`
  assertResult('GET /system/model/list', await request('GET', '/system/model/list'))
  assertResult('POST /system/model/add', await request('POST', '/system/model/add', {
    body: {
      modelName,
      modelType: 'turnover',
      featureWeights: '{}',
      accuracyRate: 0.88,
      modelVersion: 'v-smoke',
      status: 1
    }
  }))

  const listResult = await request('GET', '/system/model/list')
  assertResult('GET /system/model/list (after add)', listResult)
  const row = (listResult.json?.data || []).find((x) => x.modelName === modelName)
  if (!row?.modelId) {
    fail('GET /system/model/list (lookup)', '未找到新建模型')
    return
  }

  assertResult('PUT /system/model/update', await request('PUT', '/system/model/update', {
    body: {
      modelId: row.modelId,
      modelName: `${modelName}-u`,
      modelType: 'turnover',
      featureWeights: '{"a":1}',
      accuracyRate: 0.9,
      modelVersion: 'v-smoke-u',
      status: 1
    }
  }))
  assertResult('DELETE /system/model/delete/{id}', await request('DELETE', `/system/model/delete/${row.modelId}`))
}

async function smokeReport() {
  const taskName = `smoke-task-${Date.now()}`
  assertResult('GET /system/report/task/list', await request('GET', '/system/report/task/list'))
  assertResult('POST /system/report/task/add', await request('POST', '/system/report/task/add', {
    body: {
      taskName,
      reportType: 'warning',
      cronExpr: '0 0 9 * * ?',
      shareTarget: '',
      status: 1
    }
  }))

  const listResult = await request('GET', '/system/report/task/list')
  assertResult('GET /system/report/task/list (after add)', listResult)
  const row = (listResult.json?.data || []).find((x) => x.taskName === taskName)
  if (!row?.taskId) {
    fail('GET /system/report/task/list (lookup)', '未找到新建任务')
    return
  }

  assertResult('PUT /system/report/task/update', await request('PUT', '/system/report/task/update', {
    body: {
      taskId: row.taskId,
      taskName: `${taskName}-u`,
      reportType: 'warning',
      cronExpr: '0 30 9 * * ?',
      shareTarget: '',
      status: 1
    }
  }))
  assertResult('GET /system/report/export', await request('GET', '/system/report/export?reportType=warning'))
  assertResult('POST /system/report/share', await request('POST', '/system/report/share?reportType=warning&target=admin'))
  assertResult('GET /system/report/execution-log/list', await request('GET', '/system/report/execution-log/list'))
  assertResult('GET /system/report/share-log/list', await request('GET', '/system/report/share-log/list'))
  assertResult('DELETE /system/report/task/delete/{id}', await request('DELETE', `/system/report/task/delete/${row.taskId}`))
}

async function smokeFavorite() {
  const title = `smoke-fav-${Date.now()}`
  assertResult('POST /favorite/add', await request('POST', '/favorite/add', {
    body: {
      favoriteType: 'PAGE',
      targetKey: '/system/user',
      title,
      content: 'smoke'
    }
  }))

  const listResult = await request('GET', '/favorite/list')
  assertResult('GET /favorite/list', listResult)
  const row = (listResult.json?.data || []).find((x) => x.title === title)
  if (!row?.favoriteId) {
    fail('GET /favorite/list (lookup)', '未找到新建收藏')
    return
  }
  assertResult('DELETE /favorite/delete/{id}', await request('DELETE', `/favorite/delete/${row.favoriteId}`))
}

async function smokeMessage() {
  const title = `smoke-msg-${Date.now()}`
  assertResult('POST /message/send', await request('POST', '/message/send', {
    body: {
      senderId: adminUserId,
      receiverId: adminUserId,
      title,
      content: 'smoke',
      messageType: 3
    }
  }))

  const listResult = await request('GET', `/message/list?userId=${adminUserId}&page=1&size=50`)
  assertResult('GET /message/list', listResult)
  const row = (listResult.json?.data || []).find((x) => x.title === title)
  if (!row?.messageId) {
    fail('GET /message/list (lookup)', '未找到新建消息')
    return
  }

  assertResult('GET /message/unread-count', await request('GET', `/message/unread-count?userId=${adminUserId}`))
  assertResult('PUT /message/read/{id}', await request('PUT', `/message/read/${row.messageId}`))
  assertResult('DELETE /message/delete/{id}', await request('DELETE', `/message/delete/${row.messageId}`))
}

async function main() {
  await login()
  await smokeSystemUser()
  await smokeRule()
  await smokeModel()
  await smokeReport()
  await smokeFavorite()
  await smokeMessage()

  console.log('\n==== 冒烟汇总 ====')
  if (failures.length > 0) {
    console.log(`失败 ${failures.length} 项`)
    for (const item of failures) {
      console.log(`- ${item}`)
    }
    process.exit(1)
  }
  console.log('管理员核心接口全部通过（严格模式，无500）')
}

main().catch((err) => {
  console.error('执行异常:', err)
  process.exit(1)
})
