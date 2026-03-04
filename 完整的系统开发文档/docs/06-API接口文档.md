# 人力资源数据中心系统 - API接口文档

## 文档信息

| 项目 | 内容 |
|------|------|
| 文档名称 | API接口文档 |
| 文档版本 | v1.0 |
| 创建日期 | 2026-03-03 |
| 文档状态 | 正式版 |

---

## 一、接口概述

### 1.1 接口说明

本文档描述了人力资源数据中心系统的所有API接口，包括认证、用户、数据、分析、预警、培训、绩效、收藏、报表等模块的接口。

### 1.2 接口规范

- **协议**: HTTP/HTTPS
- **数据格式**: JSON
- **字符编码**: UTF-8
- **认证方式**: JWT Token
- **请求头**: `Authorization: Bearer {token}`

### 1.3 响应格式

所有接口统一返回以下格式：

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {},
  "timestamp": 1234567890123
}
```

**字段说明**：

| 字段 | 类型 | 说明 |
|------|------|------|
| code | Integer | 响应码，200表示成功 |
| message | String | 响应消息 |
| data | Object | 响应数据 |
| timestamp | Long | 时间戳 |

### 1.4 响应码

| 响应码 | 说明 |
|--------|------|
| 200 | 操作成功 |
| 400 | 参数错误 |
| 401 | 未授权 |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 500 | 操作失败 |
| 1001 | 用户名或密码错误 |
| 1002 | Token已过期 |
| 1003 | Token无效 |
| 1004 | 用户不存在 |
| 1005 | 用户已存在 |
| 1006 | 用户已被禁用 |
| 1007 | 权限不足 |
| 2001 | 数据不存在 |
| 2002 | 数据已存在 |

---

## 二、认证接口

### 2.1 用户登录

**接口地址**: `POST /api/auth/login`

**请求参数**:

```json
{
  "username": "admin",
  "password": "123456"
}
```

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| username | String | 是 | 用户名 |
| password | String | 是 | 密码 |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "token": "eyJhbGciOiJIUzUxMiJ9...",
    "userInfo": {
      "userId": 1,
      "username": "admin",
      "realName": "系统管理员",
      "email": "admin@example.com",
      "phone": "13800138000",
      "avatar": "https://example.com/avatar.jpg",
      "roleId": 1,
      "roleName": "后台管理员",
      "roleCode": "ADMIN"
    }
  },
  "timestamp": 1234567890123
}
```

### 2.2 用户注册

**接口地址**: `POST /api/auth/register`

**请求参数**:

```json
{
  "username": "testuser",
  "password": "123456",
  "realName": "测试用户",
  "email": "test@example.com",
  "phone": "13800138001",
  "roleId": 2,
  "departmentId": 1
}
```

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| username | String | 是 | 用户名（6-20位字母数字） |
| password | String | 是 | 密码（8-16位，包含字母和数字） |
| realName | String | 是 | 真实姓名 |
| email | String | 是 | 邮箱地址 |
| phone | String | 否 | 手机号码 |
| roleId | Long | 是 | 角色ID |
| departmentId | Long | 否 | 部门ID |

**响应示例**:

```json
{
  "code": 200,
  "message": "注册成功",
  "data": null,
  "timestamp": 1234567890123
}
```

### 2.3 用户登出

**接口地址**: `POST /api/auth/logout`

**请求头**:

```
Authorization: Bearer {token}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "登出成功",
  "data": null,
  "timestamp": 1234567890123
}
```

### 2.4 获取用户信息

**接口地址**: `GET /api/auth/userinfo`

**请求头**:

```
Authorization: Bearer {token}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "userId": 1,
    "username": "admin",
    "realName": "系统管理员",
    "email": "admin@example.com",
    "phone": "13800138000",
    "avatar": "https://example.com/avatar.jpg",
    "roleId": 1,
    "roleName": "后台管理员",
    "roleCode": "ADMIN",
    "departmentId": null,
    "departmentName": null,
    "permissions": [
      "user:manage",
      "data:manage",
      "report:manage"
    ]
  },
  "timestamp": 1234567890123
}
```

### 2.5 刷新Token

**接口地址**: `POST /api/auth/refresh`

**请求头**:

```
Authorization: Bearer {token}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "token": "eyJhbGciOiJIUzUxMiJ9..."
  },
  "timestamp": 1234567890123
}
```

---

## 三、用户管理接口

### 3.1 查询用户列表

**接口地址**: `GET /api/user/list`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| pageNum | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页条数，默认10 |
| username | String | 否 | 用户名（模糊查询） |
| realName | String | 否 | 真实姓名（模糊查询） |
| roleId | Long | 否 | 角色ID |
| departmentId | Long | 否 | 部门ID |
| status | Integer | 否 | 状态（1-正常，0-禁用） |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 100,
    "list": [
      {
        "id": 1,
        "username": "admin",
        "realName": "系统管理员",
        "email": "admin@example.com",
        "phone": "13800138000",
        "roleId": 1,
        "roleName": "后台管理员",
        "roleCode": "ADMIN",
        "departmentId": null,
        "departmentName": null,
        "status": 1,
        "avatar": "https://example.com/avatar.jpg",
        "createTime": "2024-01-01 00:00:00",
        "lastLoginTime": "2024-03-03 10:00:00"
      }
    ]
  },
  "timestamp": 1234567890123
}
```

### 3.2 查询用户详情

**接口地址**: `GET /api/user/{id}`

**请求头**:

```
Authorization: Bearer {token}
```

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 用户ID |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "username": "admin",
    "realName": "系统管理员",
    "email": "admin@example.com",
    "phone": "13800138000",
    "roleId": 1,
    "roleName": "后台管理员",
    "roleCode": "ADMIN",
    "departmentId": null,
    "departmentName": null,
    "status": 1,
    "avatar": "https://example.com/avatar.jpg",
    "createTime": "2024-01-01 00:00:00",
    "updateTime": "2024-03-03 10:00:00",
    "createBy": "system",
    "updateBy": "admin",
    "lastLoginTime": "2024-03-03 10:00:00",
    "lastLoginIp": "192.168.1.100",
    "remark": "系统管理员账号"
  },
  "timestamp": 1234567890123
}
```

### 3.3 添加用户

**接口地址**: `POST /api/user`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

```json
{
  "username": "testuser",
  "password": "123456",
  "realName": "测试用户",
  "email": "test@example.com",
  "phone": "13800138001",
  "roleId": 2,
  "departmentId": 1,
  "avatar": "https://example.com/avatar.jpg",
  "remark": "测试用户"
}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "添加成功",
  "data": {
    "id": 11
  },
  "timestamp": 1234567890123
}
```

### 3.4 修改用户

**接口地址**: `PUT /api/user/{id}`

**请求头**:

```
Authorization: Bearer {token}
```

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 用户ID |

**请求参数**:

```json
{
  "realName": "测试用户修改",
  "email": "test_new@example.com",
  "phone": "13800138002",
  "roleId": 3,
  "departmentId": 2,
  "status": 1,
  "remark": "测试用户修改"
}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "修改成功",
  "data": null,
  "timestamp": 1234567890123
}
```

### 3.5 删除用户

**接口地址**: `DELETE /api/user/{id}`

**请求头**:

```
Authorization: Bearer {token}
```

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 用户ID |

**响应示例**:

```json
{
  "code": 200,
  "message": "删除成功",
  "data": null,
  "timestamp": 1234567890123
}
```

### 3.6 修改密码

**接口地址**: `PUT /api/user/password`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

```json
{
  "oldPassword": "123456",
  "newPassword": "654321"
}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "密码修改成功",
  "data": null,
  "timestamp": 1234567890123
}
```

---

## 四、数据管理接口

### 4.1 查询数据分类

**接口地址**: `GET /api/data/categories`

**请求头**:

```
Authorization: Bearer {token}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "id": 1,
      "categoryName": "组织效能类",
      "categoryCode": "ORG_EFFICIENCY",
      "icon": "chart",
      "description": "组织效能相关数据分析",
      "dataCount": 25,
      "sortOrder": 1,
      "status": 1
    },
    {
      "id": 2,
      "categoryName": "人才梯队类",
      "categoryCode": "TALENT_PIPELINE",
      "icon": "user",
      "description": "人才梯队相关数据分析",
      "dataCount": 18,
      "sortOrder": 2,
      "status": 1
    }
  ],
  "timestamp": 1234567890123
}
```

### 4.2 查询数据列表

**接口地址**: `GET /api/data/list`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| pageNum | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页条数，默认20 |
| categoryId | Long | 否 | 分类ID |
| keyword | String | 否 | 关键词（模糊查询） |
| departmentId | Long | 否 | 部门ID |
| positionId | Long | 否 | 岗位ID |
| startDate | String | 否 | 开始日期 |
| endDate | String | 否 | 结束日期 |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 100,
    "list": [
      {
        "id": 1,
        "categoryId": 1,
        "categoryName": "组织效能类",
        "dataDimension": "人均产值",
        "statPeriod": "2024-Q1",
        "indicatorValue": 100000.00,
        "trendRate": 5.2,
        "chartData": {
          "xAxis": ["2023-Q4", "2024-Q1"],
          "series": [
            {
              "name": "人均产值",
              "data": [95000, 100000]
            }
          ]
        },
        "createTime": "2024-03-31 10:00:00"
      }
    ]
  },
  "timestamp": 1234567890123
}
```

### 4.3 查询数据详情

**接口地址**: `GET /api/data/{id}`

**请求头**:

```
Authorization: Bearer {token}
```

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 数据ID |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "categoryId": 1,
    "categoryName": "组织效能类",
    "dataDimension": "人均产值",
    "statPeriod": "2024-Q1",
    "indicatorValue": 100000.00,
    "trendRate": 5.2,
    "chartData": {
      "xAxis": ["2023-Q4", "2024-Q1"],
      "series": [
        {
          "name": "人均产值",
          "data": [95000, 100000]
        }
      ]
    },
    "description": "人均产值计算公式：总产值 / 员工人数",
    "createTime": "2024-03-31 10:00:00",
    "updateTime": "2024-03-31 10:00:00",
    "remark": "季度数据"
  },
  "timestamp": 1234567890123
}
```

### 4.4 导出数据

**接口地址**: `GET /api/data/export`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| categoryId | Long | 否 | 分类ID |
| keyword | String | 否 | 关键词 |
| departmentId | Long | 否 | 部门ID |
| positionId | Long | 否 | 岗位ID |
| startDate | String | 否 | 开始日期 |
| endDate | String | 否 | 结束日期 |

**响应**: Excel文件流

---

## 五、数据分析接口

### 5.1 组织效能分析

**接口地址**: `GET /api/analysis/org-efficiency`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| departmentId | Long | 否 | 部门ID |
| startDate | String | 否 | 开始日期 |
| endDate | String | 否 | 结束日期 |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "perCapitaOutput": 100000.00,
    "utilizationRate": 85.50,
    "orgEfficiencyIndex": 88.5,
    "trendData": {
      "xAxis": ["2024-01", "2024-02", "2024-03"],
      "series": [
        {
          "name": "人均产值",
          "data": [95000, 98000, 100000]
        },
        {
          "name": "人员利用率",
          "data": [84.0, 85.0, 85.5]
        }
      ]
    },
    "compareData": {
      "currentPeriod": 88.5,
      "lastPeriod": 85.0,
      "samePeriodLastYear": 82.0,
      "growthRate": 4.12
    }
  },
  "timestamp": 1234567890123
}
```

### 5.2 人才梯队分析

**接口地址**: `GET /api/analysis/talent-pipeline`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| departmentId | Long | 否 | 部门ID |
| startDate | String | 否 | 开始日期 |
| endDate | String | 否 | 结束日期 |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "levelDistribution": {
      "P7": 5,
      "P6": 15,
      "P5": 25,
      "P4": 35
    },
    "keyPositionReserveRate": 66.67,
    "successionCoverage": 100.00,
    "talentHealthScore": 85.0,
    "talentGap": [
      {
        "positionName": "高级前端工程师",
        "currentCount": 2,
        "requiredCount": 3,
        "gap": 1
      }
    ]
  },
  "timestamp": 1234567890123
}
```

### 5.3 薪酬福利分析

**接口地址**: `GET /api/analysis/compensation`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| departmentId | Long | 否 | 部门ID |
| startDate | String | 否 | 开始日期 |
| endDate | String | 否 | 结束日期 |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "avgSalary": 28000.00,
    "medianSalary": 26000.00,
    "minSalary": 15000.00,
    "maxSalary": 40000.00,
    "salaryDistribution": {
      "0-15000": 5,
      "15000-20000": 15,
      "20000-30000": 20,
      "30000-40000": 8,
      "40000+": 2
    },
    "fixedRatio": 70.00,
    "variableRatio": 30.00,
    "socialCoverage": 100.00,
    "benchmark": {
      "industryAvg": 25000.00,
      "competitorAvg": 27000.00,
      "competitiveness": 103.70
    }
  },
  "timestamp": 1234567890123
}
```

### 5.4 绩效管理分析

**接口地址**: `GET /api/analysis/performance`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| departmentId | Long | 否 | 部门ID |
| startDate | String | 否 | 开始日期 |
| endDate | String | 否 | 结束日期 |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "avgScore": 85.5,
    "achievementRate": 85.50,
    "levelDistribution": {
      "S": 2,
      "A": 8,
      "B": 15,
      "C": 4,
      "D": 1
    },
    "improvementPlanCount": 5,
    "improvementCompletionRate": 80.00,
    "trendData": {
      "xAxis": ["2024-Q1", "2024-Q2", "2024-Q3", "2024-Q4"],
      "series": [
        {
          "name": "绩效达成率",
          "data": [82.0, 85.0, 88.0, 87.0]
        }
      ]
    }
  },
  "timestamp": 1234567890123
}
```

### 5.5 培训效果分析

**接口地址**: `GET /api/analysis/training`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| departmentId | Long | 否 | 部门ID |
| startDate | String | 否 | 开始日期 |
| endDate | String | 否 | 结束日期 |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "trainingCount": 10,
    "participantCount": 150,
    "participationRate": 75.00,
    "avgSatisfactionScore": 8.5,
    "avgKnowledgeScore": 8.2,
    "avgBehaviorScore": 7.8,
    "totalCost": 50000.00,
    "totalBenefit": 200000.00,
    "roi": 300.00,
    "trainingTypeDistribution": {
      "入职培训": 3,
      "技术培训": 4,
      "管理培训": 2,
      "技能培训": 1
    }
  },
  "timestamp": 1234567890123
}
```

---

## 六、预警管理接口

### 6.1 查询预警列表

**接口地址**: `GET /api/warning/list`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| pageNum | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页条数，默认10 |
| warningType | String | 否 | 预警类型 |
| warningLevel | Integer | 否 | 预警级别（1-高，2-中，3-低） |
| status | Integer | 否 | 处理状态（0-未处理，1-已处理） |
| startDate | String | 否 | 开始日期 |
| endDate | String | 否 | 结束日期 |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 50,
    "list": [
      {
        "id": 1,
        "warningRuleId": 1,
        "warningType": "员工流失",
        "warningLevel": 1,
        "warningContent": "员工张伟连续3个月绩效低于60分，存在流失风险",
        "warningObject": "员工",
        "objectId": 1,
        "objectName": "张伟",
        "status": 0,
        "handleTime": null,
        "handleBy": null,
        "handleRemark": null,
        "createTime": "2024-03-03 10:00:00"
      }
    ]
  },
  "timestamp": 1234567890123
}
```

### 6.2 查询预警详情

**接口地址**: `GET /api/warning/{id}`

**请求头**:

```
Authorization: Bearer {token}
```

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 预警ID |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "warningRuleId": 1,
    "warningRuleName": "员工流失预警规则",
    "warningType": "员工流失",
    "warningLevel": 1,
    "warningContent": "员工张伟连续3个月绩效低于60分，存在流失风险",
    "warningObject": "员工",
    "objectId": 1,
    "objectName": "张伟",
    "objectDetail": {
      "employeeNo": "EMP001",
      "name": "张伟",
      "department": "技术部",
      "position": "高级前端工程师",
      "performanceScore": 55.0,
      "performanceLevel": "C"
    },
    "status": 0,
    "handleTime": null,
    "handleBy": null,
    "handleRemark": null,
    "createTime": "2024-03-03 10:00:00",
    "updateTime": "2024-03-03 10:00:00"
  },
  "timestamp": 1234567890123
}
```

### 6.3 处理预警

**接口地址**: `POST /api/warning/{id}/handle`

**请求头**:

```
Authorization: Bearer {token}
```

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 预警ID |

**请求参数**:

```json
{
  "handleRemark": "已与员工沟通，制定改进计划"
}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "处理成功",
  "data": null,
  "timestamp": 1234567890123
}
```

### 6.4 获取预警统计

**接口地址**: `GET /api/warning/statistics`

**请求头**:

```
Authorization: Bearer {token}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 50,
    "unhandled": 12,
    "handled": 38,
    "byLevel": {
      "高": 5,
      "中": 15,
      "低": 30
    },
    "byType": {
      "员工流失": 10,
      "人才缺口": 15,
      "人力成本": 12,
      "培训效果": 8,
      "绩效管理": 5
    },
    "trendData": {
      "xAxis": ["2024-01", "2024-02", "2024-03"],
      "series": [
        {
          "name": "预警数量",
          "data": [15, 18, 17]
        }
      ]
    }
  },
  "timestamp": 1234567890123
}
```

---

## 七、培训管理接口

### 7.1 查询培训记录列表

**接口地址**: `GET /api/training/list`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| pageNum | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页条数，默认10 |
| trainingName | String | 否 | 培训名称（模糊查询） |
| trainingType | String | 否 | 培训类型 |
| departmentId | Long | 否 | 部门ID |
| startDate | String | 否 | 开始日期 |
| endDate | String | 否 | 结束日期 |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 20,
    "list": [
      {
        "id": 1,
        "trainingName": "新员工入职培训",
        "trainingType": "入职培训",
        "departmentId": 1,
        "departmentName": "人力资源部",
        "startDate": "2024-01-10",
        "endDate": "2024-01-12",
        "participantCount": 10,
        "satisfactionScore": 8.5,
        "trainingCost": 5000.00,
        "trainer": "张经理",
        "description": "新员工入职培训",
        "createTime": "2024-01-10 00:00:00"
      }
    ]
  },
  "timestamp": 1234567890123
}
```

### 7.2 添加培训记录

**接口地址**: `POST /api/training`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

```json
{
  "trainingName": "Vue3技术培训",
  "trainingType": "技术培训",
  "departmentId": 2,
  "startDate": "2024-04-01",
  "endDate": "2024-04-03",
  "trainer": "李架构师",
  "description": "Vue3技术培训",
  "trainingCost": 8000.00
}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "添加成功",
  "data": {
    "id": 21
  },
  "timestamp": 1234567890123
}
```

### 7.3 修改培训记录

**接口地址**: `PUT /api/training/{id}`

**请求头**:

```
Authorization: Bearer {token}
```

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 培训ID |

**请求参数**:

```json
{
  "trainingName": "Vue3技术培训（修改）",
  "satisfactionScore": 9.0,
  "participantCount": 15
}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "修改成功",
  "data": null,
  "timestamp": 1234567890123
}
```

### 7.4 删除培训记录

**接口地址**: `DELETE /api/training/{id}`

**请求头**:

```
Authorization: Bearer {token}
```

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 培训ID |

**响应示例**:

```json
{
  "code": 200,
  "message": "删除成功",
  "data": null,
  "timestamp": 1234567890123
}
```

---

## 八、绩效管理接口

### 8.1 查询绩效记录列表

**接口地址**: `GET /api/performance/list`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| pageNum | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页条数，默认10 |
| employeeId | Long | 否 | 员工ID |
| performanceCycle | String | 否 | 绩效周期 |
| performanceLevel | String | 否 | 绩效等级 |
| startDate | String | 否 | 开始日期 |
| endDate | String | 否 | 结束日期 |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 30,
    "list": [
      {
        "id": 1,
        "employeeId": 1,
        "employeeName": "张伟",
        "employeeNo": "EMP001",
        "departmentName": "技术部",
        "positionName": "高级前端工程师",
        "performanceCycle": "2024-Q1",
        "performanceScore": 88.5,
        "performanceLevel": "A",
        "achievementRate": 88.50,
        "evaluator": "李经理",
        "evaluationDate": "2024-03-31",
        "comments": "工作表现优秀，达成目标",
        "createTime": "2024-03-31 00:00:00"
      }
    ]
  },
  "timestamp": 1234567890123
}
```

### 8.2 添加绩效记录

**接口地址**: `POST /api/performance`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

```json
{
  "employeeId": 1,
  "performanceCycle": "2024-Q2",
  "performanceScore": 90.0,
  "performanceLevel": "A",
  "achievementRate": 90.00,
  "evaluator": "李经理",
  "evaluationDate": "2024-06-30",
  "comments": "工作表现优秀"
}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "添加成功",
  "data": {
    "id": 31
  },
  "timestamp": 1234567890123
}
```

### 8.3 修改绩效记录

**接口地址**: `PUT /api/performance/{id}`

**请求头**:

```
Authorization: Bearer {token}
```

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 绩效ID |

**请求参数**:

```json
{
  "performanceScore": 92.0,
  "performanceLevel": "A",
  "achievementRate": 92.00,
  "comments": "工作表现优秀，超额完成目标"
}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "修改成功",
  "data": null,
  "timestamp": 1234567890123
}
```

### 8.4 删除绩效记录

**接口地址**: `DELETE /api/performance/{id}`

**请求头**:

```
Authorization: Bearer {token}
```

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 绩效ID |

**响应示例**:

```json
{
  "code": 200,
  "message": "删除成功",
  "data": null,
  "timestamp": 1234567890123
}
```

---

## 九、收藏管理接口

### 9.1 查询收藏列表

**接口地址**: `GET /api/favorite/list`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| pageNum | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页条数，默认10 |
| contentType | String | 否 | 内容类型（报表/预警/档案） |
| keyword | String | 否 | 关键词 |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "total": 15,
    "list": [
      {
        "id": 1,
        "userId": 2,
        "contentType": "报表",
        "contentId": 1,
        "contentName": "组织效能趋势报表",
        "favoriteTime": "2024-03-01 10:00:00",
        "createTime": "2024-03-01 10:00:00"
      }
    ]
  },
  "timestamp": 1234567890123
}
```

### 9.2 添加收藏

**接口地址**: `POST /api/favorite`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

```json
{
  "contentType": "报表",
  "contentId": 1,
  "contentName": "组织效能趋势报表"
}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "收藏成功",
  "data": {
    "id": 16
  },
  "timestamp": 1234567890123
}
```

### 9.3 删除收藏

**接口地址**: `DELETE /api/favorite/{id}`

**请求头**:

```
Authorization: Bearer {token}
```

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 收藏ID |

**响应示例**:

```json
{
  "code": 200,
  "message": "删除成功",
  "data": null,
  "timestamp": 1234567890123
}
```

---

## 十、报表管理接口

### 10.1 查询报表模板列表

**接口地址**: `GET /api/report/templates`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| reportType | String | 否 | 报表类型 |
| isPublic | Integer | 否 | 是否公开（1-公开，0-私有） |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "id": 1,
      "templateName": "组织效能趋势报表",
      "templateCode": "ORG_EFFICIENCY_TREND",
      "reportType": "组织效能",
      "description": "展示组织效能趋势变化",
      "isPublic": 1,
      "createBy": "admin",
      "createTime": "2024-01-01 00:00:00"
    }
  ],
  "timestamp": 1234567890123
}
```

### 10.2 生成报表

**接口地址**: `POST /api/report/generate`

**请求头**:

```
Authorization: Bearer {token}
```

**请求参数**:

```json
{
  "templateId": 1,
  "startDate": "2024-01-01",
  "endDate": "2024-03-31",
  "departmentId": null
}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "报表生成成功",
  "data": {
    "reportId": 1,
    "reportName": "组织效能趋势报表_20240101-20240331",
    "downloadUrl": "/api/report/download/1",
    "previewUrl": "/api/report/preview/1"
  },
  "timestamp": 1234567890123
}
```

### 10.3 下载报表

**接口地址**: `GET /api/report/download/{id}`

**请求头**:

```
Authorization: Bearer {token}
```

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 报表ID |

**响应**: PDF/Excel文件流

---

## 十一、系统管理接口

### 11.1 获取系统配置

**接口地址**: `GET /api/system/config`

**请求头**:

```
Authorization: Bearer {token}
```

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "systemName": "人力资源数据中心系统",
    "systemVersion": "1.0.0",
    "logo": "/static/logo.png",
    "theme": "default",
    "language": "zh-cn"
  },
  "timestamp": 1234567890123
}
```

### 11.2 获取字典数据

**接口地址**: `GET /api/system/dict/{dictType}`

**请求头**:

```
Authorization: Bearer {token}
```

**路径参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| dictType | String | 是 | 字典类型 |

**响应示例**:

```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "dictCode": "ADMIN",
      "dictLabel": "后台管理员",
      "dictValue": "1",
      "sortOrder": 1
    },
    {
      "dictCode": "HR_MANAGER",
      "dictLabel": "HR管理员",
      "dictValue": "2",
      "sortOrder": 2
    }
  ],
  "timestamp": 1234567890123
}
```

### 11.3 上传文件

**接口地址**: `POST /api/system/upload`

**请求头**:

```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| file | File | 是 | 文件 |

**响应示例**:

```json
{
  "code": 200,
  "message": "上传成功",
  "data": {
    "fileName": "test.jpg",
    "filePath": "/upload/2024/03/03/test.jpg",
    "fileUrl": "http://192.168.168.100/upload/2024/03/03/test.jpg",
    "fileSize": 102400
  },
  "timestamp": 1234567890123
}
```

---

## 十二、接口测试

### 12.1 使用Postman测试

1. 导入接口文档（Swagger/OpenAPI格式）
2. 配置环境变量（baseUrl、token）
3. 先调用登录接口获取token
4. 在请求头中添加`Authorization: Bearer {token}`
5. 调用其他接口

### 12.2 使用Swagger测试

访问地址：`http://192.168.168.100/api/doc.html`

---

## 十三、错误码说明

| 错误码 | 说明 | 解决方案 |
|--------|------|----------|
| 200 | 操作成功 | - |
| 400 | 参数错误 | 检查请求参数格式和必填项 |
| 401 | 未授权 | 检查Token是否有效 |
| 403 | 禁止访问 | 检查用户权限 |
| 404 | 资源不存在 | 检查请求路径和参数 |
| 500 | 操作失败 | 联系管理员查看日志 |
| 1001 | 用户名或密码错误 | 检查用户名和密码 |
| 1002 | Token已过期 | 重新登录或刷新Token |
| 1003 | Token无效 | 检查Token格式 |
| 1004 | 用户不存在 | 确认用户是否已注册 |
| 1005 | 用户已存在 | 更换用户名 |
| 1006 | 用户已被禁用 | 联系管理员 |
| 1007 | 权限不足 | 联系管理员分配权限 |
| 2001 | 数据不存在 | 确认数据ID是否正确 |
| 2002 | 数据已存在 | 检查数据是否重复 |

---

## 十四、总结

本文档详细描述了人力资源数据中心系统的所有API接口，包括认证、用户、数据、分析、预警、培训、绩效、收藏、报表、系统等模块的接口。

所有接口采用RESTful风格，使用JSON格式进行数据交换，使用JWT Token进行身份认证。

接口文档可作为前后端联调的依据，也可以用于接口测试和第三方集成。

如有任何问题，请联系技术支持团队。
