# 分页功能API接口文档

## 接口概述

本文档详细说明了分页功能的API接口，包括接口地址、请求参数、响应格式和示例代码。

**基础URL：** `http://localhost:8080/api`

**认证方式：** JWT Bearer Token

**权限要求：** 大部分接口需要 `HR_ADMIN` 角色

---

## 1. 部门管理分页接口

### 1.1 分页查询部门列表

**接口地址：** `GET /api/department/page`

**接口描述：** 分页查询部门列表，支持按部门名称模糊查询

**权限要求：** `HR_ADMIN`

**请求参数：**

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| current | Long | 否 | 1 | 当前页码 |
| size | Long | 否 | 10 | 每页条数（最大100） |
| name | String | 否 | - | 部门名称（支持模糊查询） |

**请求示例：**

```bash
curl -X GET "http://localhost:8080/api/department/page?current=1&size=10&name=技术" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**响应格式：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "name": "技术部",
        "parentId": 0,
        "sortOrder": 1,
        "createTime": "2026-03-25T10:00:00",
        "updateTime": "2026-03-25T10:00:00"
      },
      {
        "id": 2,
        "name": "研发中心",
        "parentId": 1,
        "sortOrder": 1,
        "createTime": "2026-03-25T10:00:00",
        "updateTime": "2026-03-25T10:00:00"
      }
    ],
    "total": 25,
    "size": 10,
    "current": 1,
    "pages": 3
  }
}
```

**响应字段说明：**

| 字段名 | 类型 | 说明 |
|--------|------|------|
| code | Integer | 响应状态码，200表示成功 |
| message | String | 响应消息 |
| data | Object | 响应数据 |
| data.records | Array | 当前页数据列表 |
| data.total | Long | 总记录数 |
| data.size | Long | 每页条数 |
| data.current | Long | 当前页码 |
| data.pages | Long | 总页数 |

---

## 2. 数据分类管理分页接口

### 2.1 分页查询数据分类列表

**接口地址：** `GET /api/category/page`

**接口描述：** 分页查询数据分类列表，支持按分类名称模糊查询

**权限要求：** `HR_ADMIN`

**请求参数：**

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| current | Long | 否 | 1 | 当前页码 |
| size | Long | 否 | 10 | 每页条数（最大100） |
| name | String | 否 | - | 分类名称（支持模糊查询） |

**请求示例：**

```bash
curl -X GET "http://localhost:8080/api/category/page?current=1&size=10&name=数据" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**响应格式：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "name": "人力资源",
        "parentId": 0,
        "sortOrder": 1,
        "createTime": "2026-03-25T10:00:00",
        "updateTime": "2026-03-25T10:00:00"
      }
    ],
    "total": 15,
    "size": 10,
    "current": 1,
    "pages": 2
  }
}
```

---

## 3. 预警规则管理分页接口

### 3.1 分页查询预警规则列表

**接口地址：** `GET /api/rule/page`

**接口描述：** 分页查询预警规则列表，支持按规则类型和生效状态精确查询

**权限要求：** `HR_ADMIN`

**请求参数：**

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| current | Long | 否 | 1 | 当前页码 |
| size | Long | 否 | 10 | 每页条数（最大100） |
| ruleType | String | 否 | - | 规则类型（精确查询） |
| isActive | Boolean | 否 | - | 生效状态（精确查询） |

**请求示例：**

```bash
curl -X GET "http://localhost:8080/api/rule/page?current=1&size=10&ruleType=TURNOVER&isActive=true" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**响应格式：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "ruleName": "离职预警",
        "ruleType": "TURNOVER",
        "isActive": true,
        "createdTime": "2026-03-25T10:00:00",
        "updatedTime": "2026-03-25T10:00:00"
      }
    ],
    "total": 8,
    "size": 10,
    "current": 1,
    "pages": 1
  }
}
```

---

## 4. 报表模板管理分页接口

### 4.1 分页查询报表模板列表

**接口地址：** `GET /api/report/page`

**接口描述：** 分页查询报表模板列表，支持按报表分类和名称查询

**权限要求：** `HR_ADMIN`

**请求参数：**

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| current | Long | 否 | 1 | 当前页码 |
| size | Long | 否 | 10 | 每页条数（最大100） |
| category | String | 否 | - | 报表分类（精确查询） |
| name | String | 否 | - | 报表名称（支持模糊查询） |

**请求示例：**

```bash
curl -X GET "http://localhost:8080/api/report/page?current=1&size=10&category=HR&name=员工" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**响应格式：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "name": "员工统计报表",
        "category": "HR",
        "querySql": "SELECT * FROM employee",
        "createdTime": "2026-03-25T10:00:00",
        "updatedTime": "2026-03-25T10:00:00"
      }
    ],
    "total": 12,
    "size": 10,
    "current": 1,
    "pages": 2
  }
}
```

---

## 5. 收藏管理分页接口

### 5.1 分页查询当前用户的收藏列表

**接口地址：** `GET /api/favorite/page`

**接口描述：** 分页查询当前用户的收藏列表，实现用户数据隔离

**权限要求：** 所有登录用户

**请求参数：**

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| current | Long | 否 | 1 | 当前页码 |
| size | Long | 否 | 10 | 每页条数（最大100） |
| favType | String | 否 | - | 收藏类型（精确查询） |

**请求示例：**

```bash
curl -X GET "http://localhost:8080/api/favorite/page?current=1&size=10&favType=REPORT" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**响应格式：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "userId": 1,
        "favType": "REPORT",
        "targetId": 1,
        "createTime": "2026-03-25T10:00:00"
      }
    ],
    "total": 5,
    "size": 10,
    "current": 1,
    "pages": 1
  }
}
```

---

## 6. 错误码说明

### 6.1 通用错误码

| 错误码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 400 | 请求参数错误 |
| 401 | 未授权（未登录或Token无效） |
| 403 | 禁止访问（权限不足） |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

### 6.2 错误响应格式

```json
{
  "code": 401,
  "message": "未授权，请先登录",
  "data": null
}
```

---

## 7. 认证说明

### 7.1 获取Token

**接口地址：** `POST /api/auth/login`

**请求参数：**

```json
{
  "username": "admin",
  "password": "password"
}
```

**响应格式：**

```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "username": "admin",
      "role": "HR_ADMIN"
    }
  }
}
```

### 7.2 使用Token

**请求头格式：**

```
Authorization: Bearer YOUR_TOKEN
```

**请求示例：**

```bash
curl -X GET "http://localhost:8080/api/department/page?current=1&size=10" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

---

## 8. 使用示例

### 8.1 JavaScript示例

```javascript
// 使用fetch API
async function getDepartmentPage(current, size, name) {
  const response = await fetch(
    `http://localhost:8080/api/department/page?current=${current}&size=${size}&name=${name}`,
    {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    }
  );
  const data = await response.json();
  return data;
}

// 使用axios
import axios from 'axios';

async function getDepartmentPage(current, size, name) {
  const response = await axios.get('http://localhost:8080/api/department/page', {
    params: { current, size, name },
    headers: {
      'Authorization': `Bearer ${localStorage.getItem('token')}`
    }
  });
  return response.data;
}

// 调用示例
getDepartmentPage(1, 10, '技术').then(data => {
  console.log('部门列表：', data.data.records);
  console.log('总记录数：', data.data.total);
});
```

### 8.2 Vue示例

```javascript
import { ref, reactive, onMounted } from 'vue';
import { getDepartmentPage } from '@/api/department';

export default {
  setup() {
    const tableData = ref([]);
    const loading = ref(false);
    const page = reactive({
      current: 1,
      size: 10,
      total: 0
    });
    const query = reactive({
      name: ''
    });

    const load = async () => {
      loading.value = true;
      try {
        const res = await getDepartmentPage({
          current: page.current,
          size: page.size,
          name: query.name || undefined
        });
        tableData.value = res.data.records;
        page.total = res.data.total;
      } catch (e) {
        console.error('加载数据失败', e);
      } finally {
        loading.value = false;
      }
    };

    onMounted(() => {
      load();
    });

    return {
      tableData,
      loading,
      page,
      query,
      load
    };
  }
};
```

### 8.3 Java示例

```java
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;

public class DepartmentClient {
    private static final String BASE_URL = "http://localhost:8080/api";
    private String token;

    public DepartmentClient(String token) {
        this.token = token;
    }

    public PageResponse<Department> getDepartmentPage(int current, int size, String name) {
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + token);

        String url = String.format("%s/department/page?current=%d&size=%d&name=%s",
                BASE_URL, current, size, name);

        HttpEntity<String> entity = new HttpEntity<>(headers);

        return restTemplate.exchange(
                url,
                HttpMethod.GET,
                entity,
                PageResponse.class
        ).getBody();
    }
}
```

---

## 9. 注意事项

### 9.1 分页限制

- 最大每页条数限制为100
- 页码从1开始
- 超过总页数的页码将返回空数据

### 9.2 性能优化

- 建议使用索引字段进行筛选
- 避免使用 `LIKE '%xxx%'` 查询（无法使用索引）
- 合理设置每页条数，避免一次性加载过多数据

### 9.3 安全注意事项

- 所有接口都需要JWT认证
- 管理员接口需要 `HR_ADMIN` 角色
- 收藏接口自动实现用户数据隔离
- 所有输入参数都会进行SQL注入防护

---

## 10. 更新日志

### v1.0 (2026-03-25)
- 新增部门管理分页接口
- 新增数据分类管理分页接口
- 新增预警规则管理分页接口
- 新增报表模板管理分页接口
- 新增收藏管理分页接口

---

**文档版本：** v1.0
**创建日期：** 2026-03-25
**作者：** SDD Agent
**最后更新：** 2026-03-25
