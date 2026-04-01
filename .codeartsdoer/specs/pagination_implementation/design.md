# 数据表分页功能实现 - 技术设计文档

## 1. 设计概述

### 1.1 设计目标
本设计文档将需求规格说明书中定义的"分页功能需求"转化为具体的技术实现方案，包括后端API设计、前端组件设计、数据流程和接口规范。

### 1.2 设计原则
- **一致性原则**：所有分页接口采用统一的参数命名和响应格式
- **兼容性原则**：保留原有list接口，新增page接口
- **性能原则**：使用数据库分页而非内存分页
- **安全性原则**：参数校验和权限控制

### 1.3 技术架构
```
┌─────────────────────────────────────────────────────────┐
│                    前端层 (Vue 3)                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │  View Layer (DepartmentManagementView.vue等)     │  │
│  │  - el-pagination组件                             │  │
│  │  - 页码切换事件处理                               │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │  API Layer (api/department.js等)                 │  │
│  │  - Axios HTTP请求封装                            │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓ HTTP
┌─────────────────────────────────────────────────────────┐
│                 后端层 (Spring Boot)                     │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Controller Layer (DepartmentController.java)    │  │
│  │  - GET /api/department/page                      │  │
│  │  - 参数接收和响应封装                             │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Service Layer (DepartmentService.java)          │  │
│  │  - 分页查询业务逻辑                               │  │
│  │  - 条件构造和查询执行                             │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Mapper Layer (DepartmentMapper.java)            │  │
│  │  - MyBatis-Plus BaseMapper                       │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓ JDBC
┌─────────────────────────────────────────────────────────┐
│                  数据层 (MySQL 8.0)                      │
│  - hr_department, hr_data_category, warning_rule       │
│  - report_template, sys_favorite                       │
└─────────────────────────────────────────────────────────┘
```

## 2. 后端设计

### 2.1 分页插件配置
MyBatis-Plus分页插件已在项目中配置，无需额外配置。

**配置位置：** `application.yml` 或配置类中
```java
@Configuration
public class MybatisPlusConfig {
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
        return interceptor;
    }
}
```

### 2.2 Controller层设计

#### 2.2.1 DepartmentController设计

**文件路径：** `backend/src/main/java/com/hr/backend/controller/DepartmentController.java`

**新增接口：**
```java
/**
 * 分页查询部门列表
 * @param current 当前页码，默认1
 * @param size 每页大小，默认10
 * @param name 部门名称（可选，模糊查询）
 * @return 分页结果
 */
@GetMapping("/page")
public Response<IPage<Department>> page(
        @RequestParam(defaultValue = "1") long current,
        @RequestParam(defaultValue = "10") long size,
        @RequestParam(required = false) String name) {
    IPage<Department> page = departmentService.page(new Page<>(current, size), name);
    return Response.success(page);
}
```

**设计说明：**
- 保留原有`/list`接口，新增`/page`接口
- 使用`@RequestParam`注解定义默认值
- 返回类型为`Response<IPage<Department>>`
- 支持按部门名称模糊查询

#### 2.2.2 DataCategoryController设计

**文件路径：** `backend/src/main/java/com/hr/backend/controller/DataCategoryController.java`

**新增接口：**
```java
/**
 * 分页查询数据分类列表
 * @param current 当前页码
 * @param size 每页大小
 * @param name 分类名称（可选）
 * @return 分页结果
 */
@GetMapping("/page")
public Response<IPage<DataCategory>> page(
        @RequestParam(defaultValue = "1") long current,
        @RequestParam(defaultValue = "10") long size,
        @RequestParam(required = false) String name) {
    IPage<DataCategory> page = categoryService.page(new Page<>(current, size), name);
    return Response.success(page);
}
```

#### 2.2.3 RuleController设计

**文件路径：** `backend/src/main/java/com/hr/backend/controller/RuleController.java`

**新增接口：**
```java
/**
 * 分页查询预警规则
 * @param current 当前页码
 * @param size 每页大小
 * @param ruleType 规则类型（可选）
 * @param effective 是否生效（可选）
 * @return 分页结果
 */
@GetMapping("/page")
public Response<IPage<WarningRule>> page(
        @RequestParam(defaultValue = "1") long current,
        @RequestParam(defaultValue = "10") long size,
        @RequestParam(required = false) String ruleType,
        @RequestParam(required = false) Integer effective) {
    IPage<WarningRule> page = warningRuleService.page(new Page<>(current, size), ruleType, effective);
    return Response.success(page);
}
```

#### 2.2.4 ReportController设计

**文件路径：** `backend/src/main/java/com/hr/backend/controller/ReportController.java`

**新增接口：**
```java
/**
 * 分页查询报表模板
 * @param current 当前页码
 * @param size 每页大小
 * @param category 分类（可选）
 * @param name 模板名称（可选）
 * @return 分页结果
 */
@GetMapping("/page")
public Response<IPage<ReportTemplate>> page(
        @RequestParam(defaultValue = "1") long current,
        @RequestParam(defaultValue = "10") long size,
        @RequestParam(required = false) String category,
        @RequestParam(required = false) String name) {
    IPage<ReportTemplate> page = reportTemplateService.page(new Page<>(current, size), category, name);
    return Response.success(page);
}
```

#### 2.2.5 FavoriteController设计

**文件路径：** `backend/src/main/java/com/hr/backend/controller/FavoriteController.java`

**新增接口：**
```java
/**
 * 分页查询我的收藏
 * @param current 当前页码
 * @param size 每页大小
 * @param favType 收藏类型（可选）
 * @return 分页结果
 */
@GetMapping("/page")
public Response<IPage<Favorite>> page(
        @RequestParam(defaultValue = "1") long current,
        @RequestParam(defaultValue = "10") long size,
        @RequestParam(required = false) String favType) {
    Long userId = SecurityUtil.getCurrentUserId();
    IPage<Favorite> page = favoriteService.page(new Page<>(current, size), userId, favType);
    return Response.success(page);
}
```

**安全设计：**
- 使用`SecurityUtil.getCurrentUserId()`获取当前登录用户ID
- 只返回当前用户的收藏数据

### 2.3 Service层设计

#### 2.3.1 DepartmentService设计

**文件路径：** `backend/src/main/java/com/hr/backend/service/DepartmentService.java`

**新增方法签名：**
```java
/**
 * 分页查询部门
 * @param page 分页参数
 * @param name 部门名称（可选）
 * @return 分页结果
 */
IPage<Department> page(Page<Department> page, String name);
```

**实现类：** `DepartmentServiceImpl.java`
```java
@Override
public IPage<Department> page(Page<Department> page, String name) {
    LambdaQueryWrapper<Department> wrapper = new LambdaQueryWrapper<>();
    if (StringUtils.hasText(name)) {
        wrapper.like(Department::getName, name);
    }
    wrapper.orderByAsc(Department::getSortOrder);
    return this.page(page, wrapper);
}
```

#### 2.3.2 DataCategoryService设计

**新增方法签名：**
```java
IPage<DataCategory> page(Page<DataCategory> page, String name);
```

**实现：**
```java
@Override
public IPage<DataCategory> page(Page<DataCategory> page, String name) {
    LambdaQueryWrapper<DataCategory> wrapper = new LambdaQueryWrapper<>();
    if (StringUtils.hasText(name)) {
        wrapper.like(DataCategory::getName, name);
    }
    wrapper.orderByAsc(DataCategory::getSortOrder);
    return this.page(page, wrapper);
}
```

#### 2.3.3 WarningRuleService设计

**新增方法签名：**
```java
IPage<WarningRule> page(Page<WarningRule> page, String ruleType, Integer effective);
```

**实现：**
```java
@Override
public IPage<WarningRule> page(Page<WarningRule> page, String ruleType, Integer effective) {
    LambdaQueryWrapper<WarningRule> wrapper = new LambdaQueryWrapper<>();
    if (StringUtils.hasText(ruleType)) {
        wrapper.eq(WarningRule::getRuleType, ruleType);
    }
    if (effective != null) {
        wrapper.eq(WarningRule::getEffective, effective);
    }
    wrapper.orderByDesc(WarningRule::getUpdateTime);
    return this.page(page, wrapper);
}
```

#### 2.3.4 ReportTemplateService设计

**新增方法签名：**
```java
IPage<ReportTemplate> page(Page<ReportTemplate> page, String category, String name);
```

**实现：**
```java
@Override
public IPage<ReportTemplate> page(Page<ReportTemplate> page, String category, String name) {
    LambdaQueryWrapper<ReportTemplate> wrapper = new LambdaQueryWrapper<>();
    if (StringUtils.hasText(category)) {
        wrapper.eq(ReportTemplate::getCategory, category);
    }
    if (StringUtils.hasText(name)) {
        wrapper.like(ReportTemplate::getName, name);
    }
    wrapper.orderByDesc(ReportTemplate::getUpdateTime);
    return this.page(page, wrapper);
}
```

#### 2.3.5 FavoriteService设计

**新增方法签名：**
```java
IPage<Favorite> page(Page<Favorite> page, Long userId, String favType);
```

**实现：**
```java
@Override
public IPage<Favorite> page(Page<Favorite> page, Long userId, String favType) {
    LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
    wrapper.eq(Favorite::getUserId, userId);
    if (StringUtils.hasText(favType)) {
        wrapper.eq(Favorite::getFavType, favType);
    }
    wrapper.orderByDesc(Favorite::getCreateTime);
    return this.page(page, wrapper);
}
```

### 2.4 参数校验设计

**边界校验：**
- `current` 必须 >= 1（通过defaultValue保证）
- `size` 必须 >= 1 且 <= 100（需要添加校验）

**校验实现：**
```java
@GetMapping("/page")
public Response<IPage<Department>> page(
        @RequestParam(defaultValue = "1") long current,
        @RequestParam(defaultValue = "10") long size,
        @RequestParam(required = false) String name) {
    // 参数校验
    if (current < 1) {
        return Response.error(400, "页码必须大于0");
    }
    if (size < 1 || size > 100) {
        return Response.error(400, "每页大小必须在1-100之间");
    }

    IPage<Department> page = departmentService.page(new Page<>(current, size), name);
    return Response.success(page);
}
```

## 3. 前端设计

### 3.1 API层设计

#### 3.1.1 部门API设计

**文件路径：** `frontend/src/api/department.js`

**新增方法：**
```javascript
import request from '@/utils/request'

// 分页查询部门
export function getDepartmentPage(params) {
  return request({
    url: '/api/department/page',
    method: 'get',
    params: {
      current: params.current,
      size: params.size,
      name: params.name
    }
  })
}
```

#### 3.1.2 数据分类API设计

**文件路径：** `frontend/src/api/category.js`

**新增方法：**
```javascript
// 分页查询数据分类
export function getCategoryPage(params) {
  return request({
    url: '/api/category/page',
    method: 'get',
    params: {
      current: params.current,
      size: params.size,
      name: params.name
    }
  })
}
```

#### 3.1.3 预警规则API设计

**文件路径：** `frontend/src/api/rule.js`

**新增方法：**
```javascript
// 分页查询预警规则
export function getRulePage(params) {
  return request({
    url: '/api/rule/page',
    method: 'get',
    params: {
      current: params.current,
      size: params.size,
      ruleType: params.ruleType,
      effective: params.effective
    }
  })
}
```

#### 3.1.4 报表模板API设计

**文件路径：** `frontend/src/api/report.js`

**新增方法：**
```javascript
// 分页查询报表模板
export function getReportPage(params) {
  return request({
    url: '/api/report/page',
    method: 'get',
    params: {
      current: params.current,
      size: params.size,
      category: params.category,
      name: params.name
    }
  })
}
```

#### 3.1.5 收藏API设计

**文件路径：** `frontend/src/api/favorite.js`

**新增方法：**
```javascript
// 分页查询我的收藏
export function getFavoritePage(params) {
  return request({
    url: '/api/favorite/page',
    method: 'get',
    params: {
      current: params.current,
      size: params.size,
      favType: params.favType
    }
  })
}
```

### 3.2 View层设计

#### 3.2.1 DepartmentManagementView设计

**文件路径：** `frontend/src/views/admin/DepartmentManagementView.vue`

**修改内容：**

1. **数据模型添加分页状态：**
```javascript
const page = reactive({
  current: 1,
  size: 10,
  total: 0
})
```

2. **修改loadList方法：**
```javascript
const loadList = async () => {
  loading.value = true
  try {
    const res = await getDepartmentPage({
      current: page.current,
      size: page.size
    })
    const pageData = res.data
    tableData.value = buildTree(pageData.records || [], 0)
    page.total = pageData.total || 0
  } catch (e) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}
```

3. **添加分页组件：**
```vue
<el-pagination
  v-model:current-page="page.current"
  v-model:page-size="page.size"
  :total="page.total"
  :page-sizes="[10, 20, 50, 100]"
  layout="total, sizes, prev, pager, next, jumper"
  @size-change="loadList"
  @current-change="loadList"
  style="margin-top: 16px"
/>
```

**设计说明：**
- 部门表需要支持树形结构展示
- 分页后仍需调用`buildTree`方法构建树形结构
- 支持每页条数选择（10, 20, 50, 100）

#### 3.2.2 CategoryManagementView设计

**文件路径：** `frontend/src/views/admin/CategoryManagementView.vue`

**修改内容：**

1. **数据模型：**
```javascript
const page = reactive({
  current: 1,
  size: 10,
  total: 0
})
```

2. **修改loadList方法：**
```javascript
const loadList = async () => {
  loading.value = true
  try {
    const res = await getCategoryPage({
      current: page.current,
      size: page.size
    })
    list.value = res.data.records || []
    page.total = res.data.total || 0
  } catch (e) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}
```

3. **添加分页组件：**
```vue
<el-pagination
  v-model:current-page="page.current"
  v-model:page-size="page.size"
  :total="page.total"
  layout="total, prev, pager, next"
  @current-change="loadList"
  style="margin-top: 16px"
/>
```

#### 3.2.3 RuleManagementView设计

**文件路径：** `frontend/src/views/admin/RuleManagementView.vue`

**修改内容：**
- 前端已有分页组件，需修改API调用
- 将`queryRules`方法改为调用后端分页接口

```javascript
const handleQuery = async () => {
  loading.value = true
  try {
    const res = await getRulePage({
      current: queryParams.pageNum,
      size: queryParams.pageSize,
      ruleType: queryParams.ruleType,
      effective: queryParams.isActive
    })
    tableData.value = res.data.records || []
    total.value = res.data.total || 0
  } catch (error) {
    ElMessage.error('查询失败：' + error.message)
  } finally {
    loading.value = false
  }
}
```

#### 3.2.4 ReportManagementView设计

**文件路径：** `frontend/src/views/admin/ReportManagementView.vue`

**修改内容：**

1. **数据模型：**
```javascript
const page = reactive({
  current: 1,
  size: 10,
  total: 0
})
```

2. **修改loadList方法：**
```javascript
const loadList = async () => {
  loading.value = true
  try {
    const res = await getReportPage({
      current: page.current,
      size: page.size
    })
    list.value = res.data.records || []
    page.total = res.data.total || 0
  } catch (e) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}
```

3. **添加分页组件：**
```vue
<el-pagination
  v-model:current-page="page.current"
  v-model:page-size="page.size"
  :total="page.total"
  :page-sizes="[10, 20, 50]"
  layout="total, sizes, prev, pager, next"
  @size-change="loadList"
  @current-change="loadList"
  style="margin-top: 16px"
/>
```

#### 3.2.5 MyFavoritesView设计

**文件路径：** `frontend/src/views/MyFavoritesView.vue`

**修改内容：**

1. **数据模型：**
```javascript
const page = reactive({
  current: 1,
  size: 10,
  total: 0
})
const loading = ref(false)
```

2. **修改load方法：**
```javascript
const load = async () => {
  loading.value = true
  try {
    const res = await getFavoritePage({
      current: page.current,
      size: page.size
    })
    list.value = res.data.records || []
    page.total = res.data.total || 0
  } catch (e) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}
```

3. **添加分页组件：**
```vue
<el-pagination
  v-model:current-page="page.current"
  v-model:page-size="page.size"
  :total="page.total"
  layout="total, prev, pager, next"
  @current-change="load"
  style="margin-top: 16px"
/>
```

## 4. 数据流程设计

### 4.1 分页查询流程

```
用户操作 → 前端组件 → API调用 → 后端Controller → Service → Mapper → 数据库
    ↓
点击翻页
    ↓
触发@current-change事件
    ↓
调用load方法
    ↓
getDepartmentPage({
  current: page.current,
  size: page.size
})
    ↓
HTTP GET /api/department/page?current=2&size=10
    ↓
DepartmentController.page()
    ↓
DepartmentService.page()
    ↓
MyBatis-Plus分页查询
    ↓
SELECT * FROM hr_department LIMIT 10 OFFSET 10
    ↓
返回IPage<Department>
    ↓
前端接收响应
    ↓
更新tableData和page.total
    ↓
页面重新渲染
```

### 4.2 数据转换流程

**后端响应格式：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {"id": 1, "name": "销售部", "parentId": 0, "sortOrder": 1},
      {"id": 2, "name": "研发部", "parentId": 0, "sortOrder": 2}
    ],
    "total": 17,
    "size": 10,
    "current": 1,
    "pages": 2
  }
}
```

**前端处理：**
```javascript
const res = await getDepartmentPage(params)
tableData.value = res.data.records  // 当前页数据
page.total = res.data.total         // 总记录数
```

## 5. 接口规范

### 5.1 统一请求格式

**请求参数：**
| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| current | long | 否 | 1 | 当前页码，从1开始 |
| size | long | 否 | 10 | 每页大小，范围1-100 |

**可选筛选参数：**
| 参数名 | 类型 | 适用接口 | 说明 |
|--------|------|----------|------|
| name | String | department, category, report | 名称模糊查询 |
| ruleType | String | rule | 规则类型精确查询 |
| effective | Integer | rule | 是否生效 |
| category | String | report | 分类精确查询 |
| favType | String | favorite | 收藏类型 |

### 5.2 统一响应格式

**成功响应：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [],      // 当前页数据数组
    "total": 0,         // 总记录数
    "size": 10,         // 每页大小
    "current": 1,       // 当前页
    "pages": 0          // 总页数
  }
}
```

**错误响应：**
```json
{
  "code": 400,
  "message": "每页大小必须在1-100之间",
  "data": null
}
```

### 5.3 HTTP状态码

| 状态码 | 说明 | 场景 |
|--------|------|------|
| 200 | 成功 | 查询成功 |
| 400 | 参数错误 | 参数校验失败 |
| 401 | 未授权 | 未登录或token失效 |
| 403 | 无权限 | 无访问权限 |
| 500 | 服务器错误 | 系统异常 |

## 6. 性能优化设计

### 6.1 数据库优化

**索引建议：**
```sql
-- 部门表
ALTER TABLE hr_department ADD INDEX idx_sort_order (sort_order);

-- 预警规则表
ALTER TABLE warning_rule ADD INDEX idx_rule_type (rule_type);
ALTER TABLE warning_rule ADD INDEX idx_effective (effective);

-- 报表模板表
ALTER TABLE report_template ADD INDEX idx_category (category);

-- 收藏表
ALTER TABLE sys_favorite ADD INDEX idx_user_id (user_id);
ALTER TABLE sys_favorite ADD INDEX idx_fav_type (fav_type);
```

### 6.2 查询优化

**使用MyBatis-Plus分页：**
- 自动添加`LIMIT`和`OFFSET`子句
- 自动执行`COUNT`查询获取总数
- 避免全表查询

**SQL示例：**
```sql
-- 分页查询
SELECT * FROM hr_department
WHERE name LIKE '%销售%'
ORDER BY sort_order ASC
LIMIT 10 OFFSET 0;

-- 总数查询
SELECT COUNT(*) FROM hr_department
WHERE name LIKE '%销售%';
```

### 6.3 前端优化

**防抖处理：**
```javascript
import { debounce } from 'lodash-es'

const loadList = debounce(async () => {
  // 查询逻辑
}, 300)
```

**缓存策略：**
- 对于数据量小的表（如部门、分类），可考虑前端缓存
- 使用Pinia存储常用数据

## 7. 安全设计

### 7.1 参数校验

**后端校验：**
```java
// 页码校验
if (current < 1) {
    return Response.error(400, "页码必须大于0");
}

// 每页大小校验
if (size < 1 || size > 100) {
    return Response.error(400, "每页大小必须在1-100之间");
}

// 字符串参数校验（防止SQL注入）
if (name != null && name.length() > 50) {
    return Response.error(400, "参数长度超限");
}
```

### 7.2 权限控制

**Controller权限注解：**
```java
@PreAuthorize("hasRole('HR_ADMIN')")
@GetMapping("/page")
public Response<IPage<Department>> page(...) {
    // 只有HR管理员可以访问
}
```

**数据权限控制：**
- 收藏表：只返回当前用户的数据
- 使用`SecurityUtil.getCurrentUserId()`获取用户ID

### 7.3 SQL注入防护

**使用MyBatis-Plus的LambdaQueryWrapper：**
```java
LambdaQueryWrapper<Department> wrapper = new LambdaQueryWrapper<>();
if (StringUtils.hasText(name)) {
    wrapper.like(Department::getName, name);  // 自动转义
}
```

## 8. 异常处理设计

### 8.1 异常类型

| 异常类型 | 处理方式 | 响应码 |
|----------|----------|--------|
| 参数校验失败 | 返回错误提示 | 400 |
| 数据库异常 | 记录日志，返回通用错误 | 500 |
| 权限不足 | 返回权限错误 | 403 |
| 网络超时 | 提示用户重试 | 504 |

### 8.2 异常处理流程

```
异常发生 → GlobalExceptionHandler → 统一错误响应 → 前端提示
```

**前端异常处理：**
```javascript
try {
  const res = await getDepartmentPage(params)
  // 处理数据
} catch (e) {
  if (e.response && e.response.status === 403) {
    ElMessage.error('无权限访问')
  } else {
    ElMessage.error('加载数据失败')
  }
}
```

## 9. 测试设计

### 9.1 后端单元测试

**测试用例：**
```java
@SpringBootTest
class DepartmentControllerTest {

    @Test
    void testPage() {
        // 正常分页查询
        Response<IPage<Department>> response = controller.page(1, 10, null);
        assertEquals(200, response.getCode());
        assertNotNull(response.getData());
    }

    @Test
    void testPageWithInvalidParams() {
        // 参数校验测试
        Response<IPage<Department>> response = controller.page(0, 10, null);
        assertEquals(400, response.getCode());
    }

    @Test
    void testPageWithNameFilter() {
        // 带筛选条件的分页查询
        Response<IPage<Department>> response = controller.page(1, 10, "销售");
        assertEquals(200, response.getCode());
    }
}
```

### 9.2 前端集成测试

**测试场景：**
1. 页面加载时自动查询第一页数据
2. 点击下一页按钮加载第二页数据
3. 修改每页条数后重新查询
4. 带筛选条件的分页查询
5. 数据为空时的显示

## 10. 部署设计

### 10.1 后端部署

**无需特殊配置：**
- MyBatis-Plus分页插件已配置
- 新增接口自动生效

### 10.2 前端部署

**构建命令：**
```bash
npm run build
```

**部署文件：**
- `dist/` 目录下的静态文件
- 无需额外配置

## 11. 监控与日志

### 11.1 日志记录

**后端日志：**
```java
@Slf4j
@RestController
public class DepartmentController {

    @GetMapping("/page")
    public Response<IPage<Department>> page(...) {
        log.info("分页查询部门，参数：current={}, size={}, name={}", current, size, name);
        // 查询逻辑
        log.info("查询完成，共{}条记录", page.getTotal());
        return Response.success(page);
    }
}
```

### 11.2 性能监控

**监控指标：**
- 接口响应时间
- 数据库查询时间
- 分页查询QPS

## 12. 扩展性设计

### 12.1 通用分页方法

**可抽取为通用工具类：**
```java
public class PageUtils {

    public static <T> IPage<T> page(Page<T> page, LambdaQueryWrapper<T> wrapper) {
        // 通用分页逻辑
    }

    public static <T> void validatePageParams(long current, long size) {
        // 通用参数校验
    }
}
```

### 12.2 前端通用组件

**可封装分页混入：**
```javascript
// mixins/pagination.js
export default {
  data() {
    return {
      page: {
        current: 1,
        size: 10,
        total: 0
      }
    }
  },
  methods: {
    handlePageChange() {
      this.loadData()
    }
  }
}
```

## 13. 设计总结

### 13.1 设计亮点

1. **统一规范**：所有分页接口采用相同的参数和响应格式
2. **向后兼容**：保留原有list接口，不影响现有功能
3. **性能优化**：使用数据库分页，避免内存分页
4. **安全可靠**：参数校验、权限控制、SQL注入防护
5. **易于维护**：清晰的分层架构，便于扩展和测试

### 13.2 技术选型合理性

- **MyBatis-Plus分页插件**：成熟稳定，自动优化SQL
- **Element Plus分页组件**：功能完善，用户体验好
- **统一的接口规范**：降低前后端沟通成本

### 13.3 风险控制

- 充分的参数校验防止异常数据
- 完善的异常处理机制
- 详细的日志记录便于问题排查
- 单元测试和集成测试保证质量
