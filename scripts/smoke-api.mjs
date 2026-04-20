/**
 * HR DataCenter API 冒烟：登录后对 Controller 路由逐条请求，统计 code===200。
 * 用法: node scripts/smoke-api.mjs
 * 环境变量: API_BASE (默认 http://localhost:8080/api)
 */
const BASE = process.env.API_BASE || 'http://localhost:8080/api'
const USER = process.env.SMOKE_USER || 'admin'
const PASS = process.env.SMOKE_PASS || '123456'

let token = ''
let userId = 1

async function rawFetch(method, path, { body, headers = {} } = {}) {
  const url = path.startsWith('http') ? path : `${BASE}${path}`
  const h = { ...headers }
  if (token) h['Authorization'] = `Bearer ${token}`
  if (body !== undefined && body !== null && !h['Content-Type']) {
    h['Content-Type'] = 'application/json'
  }
  const res = await fetch(url, { method, headers: h, body: body === undefined || body === null ? undefined : typeof body === 'string' ? body : JSON.stringify(body) })
  const text = await res.text()
  let json
  try {
    json = text ? JSON.parse(text) : null
  } catch {
    json = { _parseError: true, raw: text.slice(0, 200) }
  }
  return { http: res.status, json }
}

async function login() {
  const { http, json } = await rawFetch('POST', '/auth/login', {
    body: { username: USER, password: PASS },
    headers: {}
  })
  if (http !== 200 || !json || json.code !== 200) {
    console.error('登录失败', http, json)
    process.exit(1)
  }
  token = json.data?.token || ''
  userId = json.data?.userId ?? 1
  if (!token) {
    console.error('无 token', json)
    process.exit(1)
  }
  console.log(`已登录 ${USER} userId=${userId}`)
}

function ok(name, { http, json }, soft = false) {
  const code = json?.code
  const pass = http === 200 && code === 200
  if (pass) {
    console.log(`OK  ${name}`)
    return true
  }
  if (soft) {
    console.log(`~~  ${name} (非严格) http=${http} code=${code} msg=${json?.message}`)
    return true
  }
  console.log(`FAIL ${name} http=${http} code=${code} msg=${json?.message} body=${JSON.stringify(json).slice(0, 240)}`)
  return false
}

async function main() {
  await login()
  const fails = []
  const check = (name, p, soft) => {
    if (!ok(name, p, soft)) fails.push(name)
  }

  // —— 个人中心 / 认证 ——
  let profile = {}
  {
    const r = await rawFetch('GET', '/auth/profile')
    check('GET /auth/profile', r)
    profile = r.json?.data || {}
  }
  {
    const r = await rawFetch('PUT', '/auth/profile', {
      body: {
        realName: profile.realName || '管理员',
        phone: profile.phone || '13800138000',
        email: profile.email || 'admin@example.com'
      }
    })
    check('PUT /auth/profile', r)
  }
  check('POST /auth/logout', await rawFetch('POST', '/auth/logout', { body: {} }))
  await login()

  // —— 员工 / 看板 ——
  check('GET /employee/list', await rawFetch('GET', '/employee/list?page=1&size=5'))
  check('GET /employee/1', await rawFetch('GET', '/employee/1'))
  check('GET /employee/total', await rawFetch('GET', '/employee/total'))
  check('GET /employee/dashboard-stats', await rawFetch('GET', '/employee/dashboard-stats'))

  // —— 收藏 ——
  const favTitle = `smoke-fav-${Date.now()}`
  check('POST /favorite/add', await rawFetch('POST', '/favorite/add', {
    body: {
      favoriteType: 'PAGE',
      targetKey: '/dashboard',
      title: favTitle,
      content: '{}'
    }
  }))
  let favId = null
  {
    const r = await rawFetch('GET', '/favorite/list')
    check('GET /favorite/list', r)
    const list = r.json?.data || []
    const row = list.find((x) => x.title === favTitle)
    favId = row?.favoriteId
  }
  if (favId) {
    check('DELETE /favorite/delete/:id', await rawFetch('DELETE', `/favorite/delete/${favId}`))
  } else {
    console.log('FAIL DELETE /favorite/delete (未找到新建收藏)')
    fails.push('DELETE /favorite/delete')
  }

  // —— 规则 / 模型 / 报表任务 ——
  check('GET /system/rule/list', await rawFetch('GET', '/system/rule/list'))
  const ruleName = `smoke-rule-${Date.now()}`
  check('POST /system/rule/add', await rawFetch('POST', '/system/rule/add', {
    body: {
      ruleName: ruleName,
      ruleType: 'THRESHOLD',
      ruleKey: 'turnover_rate',
      ruleValue: '0.15',
      effectStatus: 0
    }
  }))
  let ruleId = null
  {
    const r = await rawFetch('GET', '/system/rule/list')
    const list = r.json?.data || []
    const row = list.find((x) => x.ruleName === ruleName)
    ruleId = row?.ruleId
  }
  if (ruleId) {
    check('PUT /system/rule/update', await rawFetch('PUT', '/system/rule/update', {
      body: {
        ruleId,
        ruleName: ruleName + '-u',
        ruleType: 'THRESHOLD',
        ruleKey: 'turnover_rate',
        ruleValue: '0.2',
        effectStatus: 0
      }
    }))
    check('PUT /system/rule/effect/:id', await rawFetch('PUT', `/system/rule/effect/${ruleId}`))
    check('DELETE /system/rule/delete/:id (after effect may fail)', await rawFetch('DELETE', `/system/rule/delete/${ruleId}`), true)
  }

  check('GET /system/model/list', await rawFetch('GET', '/system/model/list'))
  const modelName = `smoke-model-${Date.now()}`
  check('POST /system/model/add', await rawFetch('POST', '/system/model/add', {
    body: {
      modelName,
      modelType: 'TURNOVER',
      featureWeights: '{}',
      accuracyRate: 0.9,
      modelVersion: 'v0-smoke',
      status: 1
    }
  }))
  let modelId = null
  {
    const r = await rawFetch('GET', '/system/model/list')
    const row = (r.json?.data || []).find((x) => x.modelName === modelName)
    modelId = row?.modelId
  }
  if (modelId) {
    check('PUT /system/model/update', await rawFetch('PUT', '/system/model/update', {
      body: {
        modelId,
        modelName: modelName + '-u',
        modelType: 'TURNOVER',
        featureWeights: '{}',
        accuracyRate: 0.91,
        modelVersion: 'v0-smoke-u',
        status: 1
      }
    }))
    check('DELETE /system/model/delete/:id', await rawFetch('DELETE', `/system/model/delete/${modelId}`))
  }

  check('GET /system/report/task/list', await rawFetch('GET', '/system/report/task/list'))
  const taskName = `smoke-task-${Date.now()}`
  check('POST /system/report/task/add', await rawFetch('POST', '/system/report/task/add', {
    body: {
      taskName,
      reportType: 'MONTHLY',
      cronExpr: '0 0 1 * * ?',
      shareTarget: '',
      status: 1
    }
  }))
  let taskId = null
  {
    const r = await rawFetch('GET', '/system/report/task/list')
    const row = (r.json?.data || []).find((x) => x.taskName === taskName)
    taskId = row?.taskId
  }
  if (taskId) {
    check('PUT /system/report/task/update', await rawFetch('PUT', '/system/report/task/update', {
      body: {
        taskId,
        taskName: taskName + '-u',
        reportType: 'MONTHLY',
        cronExpr: '0 0 2 * * ?',
        status: 1
      }
    }))
    check('GET /system/report/export', await rawFetch('GET', '/system/report/export?reportType=MONTHLY'))
    check('POST /system/report/share', await rawFetch('POST', '/system/report/share?reportType=MONTHLY&target=admin', { body: null }))
    check('DELETE /system/report/task/delete/:id', await rawFetch('DELETE', `/system/report/task/delete/${taskId}`))
  }

  // —— 数据分类 ——
  check('GET /data-category/list', await rawFetch('GET', '/data-category/list'))
  check('GET /data-category/active', await rawFetch('GET', '/data-category/active'))
  check('GET /data-category/children/0', await rawFetch('GET', '/data-category/children/0'))
  check('GET /data-category/1', await rawFetch('GET', '/data-category/1'), true)

  // —— 操作日志 ——
  check('GET /operation-log/list', await rawFetch('GET', '/operation-log/list?page=1&size=10'))
  check('GET /operation-log/1', await rawFetch('GET', '/operation-log/1'), true)

  // —— 消息 ——
  check('GET /message/list', await rawFetch('GET', `/message/list?userId=${userId}&page=1&size=10`))
  check('GET /message/unread-count', await rawFetch('GET', `/message/unread-count?userId=${userId}`))
  check('POST /message/broadcast', await rawFetch('POST', '/message/broadcast', {
    body: {
      senderId: userId,
      receiverId: null,
      title: `公告${Date.now()}`,
      content: 'smoke',
      messageType: 1,
      isRead: 0
    }
  }), true)

  // —— 考勤 / 请假 ——
  check('GET /attendance/list', await rawFetch('GET', '/attendance/list?page=1&size=5'))
  check('GET /attendance/stats', await rawFetch('GET', '/attendance/stats'))
  check('GET /attendance/today', await rawFetch('GET', '/attendance/today?empId=1'), true)
  check('POST /attendance/clockIn', await rawFetch('POST', '/attendance/clockIn?empId=1'), true)
  check('POST /attendance/clockOut', await rawFetch('POST', '/attendance/clockOut?empId=1'), true)

  check('GET /leave/list', await rawFetch('GET', '/leave/list?page=1&size=5'))
  check('GET /leave/pending', await rawFetch('GET', '/leave/pending?page=1&size=5'))

  // —— 培训 ——
  check('GET /training/course/page', await rawFetch('GET', '/training/course/page?page=1&size=5'))
  check('GET /training/enrollment/page', await rawFetch('GET', '/training/enrollment/page?page=1&size=5'))

  // —— 薪酬 ——
  check('GET /salary/payment/page', await rawFetch('GET', '/salary/payment/page?page=1&size=5'))
  check('GET /salary/payment/statistics', await rawFetch('GET', '/salary/payment/statistics'), true)
  check('GET /salary/adjustment/page', await rawFetch('GET', '/salary/adjustment/page?page=1&size=5'))
  check('GET /salary/adjustment/pending', await rawFetch('GET', '/salary/adjustment/pending?page=1&size=5'))

  // —— 绩效 ——
  check('GET /performance/goal/page', await rawFetch('GET', '/performance/goal/page?page=1&size=5'))
  check('GET /performance/goal/employee', await rawFetch('GET', '/performance/goal/employee?empId=1'), true)
  check('GET /performance/evaluation/page', await rawFetch('GET', '/performance/evaluation/page?page=1&size=5'))

  // —— 预警 / 分析（可能依赖 Hive）——
  const warnPaths = [
    '/warning/turnover/risk-analysis',
    '/warning/turnover/department-rate',
    '/warning/turnover/overview',
    '/warning/talent-gap/analysis',
    '/warning/talent-gap/structure',
    '/warning/talent-gap/overview'
  ]
  for (const p of warnPaths) {
    check(`GET ${p}`, await rawFetch('GET', p), true)
  }
  const analysisPaths = [
    '/analysis/org-efficiency/department',
    '/analysis/org-efficiency/structure',
    '/analysis/org-efficiency/staffing',
    '/analysis/org-efficiency/health',
    '/analysis/talent-pipeline/reserve',
    '/analysis/talent-pipeline/succession',
    '/analysis/talent-pipeline/capability',
    '/analysis/talent-pipeline/health',
    '/analysis/salary/structure',
    '/analysis/salary/competitiveness',
    '/analysis/salary/cost',
    '/analysis/salary/optimization'
  ]
  for (const p of analysisPaths) {
    check(`GET ${p}`, await rawFetch('GET', p), true)
  }

  console.log('\n--- 汇总 ---')
  if (fails.length) {
    console.log(`未通过(严格): ${fails.length}`, fails.join('; '))
    process.exitCode = 1
  } else {
    console.log('严格项全部 code=200')
  }
}

main().catch((e) => {
  console.error(e)
  process.exit(1)
})
