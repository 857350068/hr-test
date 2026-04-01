# 数据表分页功能实现 - 任务规划文档

## 1. 任务概述

### 1.1 任务目标
将技术设计文档中定义的实现方案转化为可执行的具体任务，确保所有需求都能被完整实现。

### 1.2 任务范围
- 后端：5个Controller接口 + 5个Service方法
- 前端：5个API方法 + 5个View组件修改
- 测试：单元测试和集成测试
- 文档：接口文档更新

### 1.3 任务优先级
根据数据量增长和业务重要性，任务优先级排序：
1. **高优先级**：收藏表（随用户增长）
2. **中优先级**：部门表、预警规则表、报表模板表
3. **低优先级**：数据分类表（数据量小）

## 2. 任务分解

### 任务1：部门表分页功能实现

**任务ID：** TASK-DEPT-001
**优先级：** 中
**预估工时：** 2小时
**依赖任务：** 无

#### 子任务1.1：后端DepartmentController添加分页接口
**描述：** 在DepartmentController中添加分页查询接口
**输入：** 分页参数（current, size, name）
**输出：** 分页结果（IPage<Department>）
**验收标准：**
- [ ] 接口路径为 GET /api/department/page
- [ ] 参数校验正确（current>=1, size在1-100之间）
- [ ] 返回格式符合IPage标准
- [ ] 原有/list接口不受影响

**实现步骤：**
1. 在DepartmentController.java中添加page方法
2. 添加参数校验逻辑
3. 调用Service层的分页方法
4. 返回统一的Response格式

**代码提示：**
```java
@GetMapping("/page")
public Response<IPage<Department>> page(
        @RequestParam(defaultValue = "1") long current,
        @RequestParam(defaultValue = "10") long size,
        @RequestParam(required = false) String name) {
    // 参数校验
    if (current < 1) current = 1;
    if (size < 1 || size > 100) size = 10;

    IPage<Department> page = departmentService.page(new Page<>(current, size), name);
    return Response.success(page);
}
```

#### 子任务1.2：后端DepartmentService添加分页方法
**描述：** 在DepartmentService中实现分页查询业务逻辑
**输入：** Page对象和查询条件
**输出：** IPage<Department>
**验收标准：**
- [ ] 支持按名称模糊查询
- [ ] 按sortOrder排序
- [ ] 使用MyBatis-Plus分页

**实现步骤：**
1. 在DepartmentService接口添加方法签名
2. 在DepartmentServiceImpl实现类添加实现
3. 构建LambdaQueryWrapper查询条件
4. 调用MyBatis-Plus的page方法

**代码提示：**
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

#### 子任务1.3：前端API添加分页方法
**描述：** 在api/department.js中添加分页查询方法
**输入：** 分页参数对象
**输出：** Axios Promise
**验收标准：**
- [ ] 方法名为getDepartmentPage
- [ ] 正确传递参数
- [ ] 返回Promise对象

**实现步骤：**
1. 打开frontend/src/api/department.js
2. 添加getDepartmentPage方法
3. 配置正确的URL和参数

**代码提示：**
```javascript
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

#### 子任务1.4：前端View添加分页组件
**描述：** 在DepartmentManagementView.vue中添加分页功能
**输入：** 用户交互事件
**输出：** 页面更新
**验收标准：**
- [ ] 添加el-pagination组件
- [ ] 支持页码切换
- [ ] 支持每页条数调整
- [ ] 树形结构正常显示

**实现步骤：**
1. 添加page响应式数据
2. 修改loadList方法调用分页API
3. 在template中添加el-pagination组件
4. 处理分页事件

**代码提示：**
```vue
<script setup>
const page = reactive({
  current: 1,
  size: 10,
  total: 0
})

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
</script>

<template>
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
</template>
```

---

### 任务2：数据分类表分页功能实现

**任务ID：** TASK-CAT-001
**优先级：** 低
**预估工时：** 1.5小时
**依赖任务：** 无

#### 子任务2.1：后端DataCategoryController添加分页接口
**描述：** 在DataCategoryController中添加分页查询接口
**输入：** 分页参数（current, size, name）
**输出：** 分页结果（IPage<DataCategory>）
**验收标准：**
- [ ] 接口路径为 GET /api/category/page
- [ ] 参数校验正确
- [ ] 返回格式符合IPage标准

**实现步骤：**
1. 在DataCategoryController.java中添加page方法
2. 添加参数校验
3. 调用Service层方法
4. 返回Response格式

**代码提示：**
```java
@GetMapping("/page")
public Response<IPage<DataCategory>> page(
        @RequestParam(defaultValue = "1") long current,
        @RequestParam(defaultValue = "10") long size,
        @RequestParam(required = false) String name) {
    if (current < 1) current = 1;
    if (size < 1 || size > 100) size = 10;

    IPage<DataCategory> page = categoryService.page(new Page<>(current, size), name);
    return Response.success(page);
}
```

#### 子任务2.2：后端DataCategoryService添加分页方法
**描述：** 实现数据分类的分页查询逻辑
**输入：** Page对象和查询条件
**输出：** IPage<DataCategory>
**验收标准：**
- [ ] 支持名称模糊查询
- [ ] 按sortOrder排序

**代码提示：**
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

#### 子任务2.3：前端API添加分页方法
**描述：** 在api/category.js中添加分页查询方法
**验收标准：**
- [ ] 方法名为getCategoryPage
- [ ] 正确传递参数

**代码提示：**
```javascript
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

#### 子任务2.4：前端View添加分页组件
**描述：** 在CategoryManagementView.vue中添加分页功能
**验收标准：**
- [ ] 添加el-pagination组件
- [ ] 支持页码切换

**代码提示：**
```vue
<script setup>
const page = reactive({
  current: 1,
  size: 10,
  total: 0
})

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
</script>

<template>
  <el-pagination
    v-model:current-page="page.current"
    v-model:page-size="page.size"
    :total="page.total"
    layout="total, prev, pager, next"
    @current-change="loadList"
    style="margin-top: 16px"
  />
</template>
```

---

### 任务3：预警规则表分页功能实现

**任务ID：** TASK-RULE-001
**优先级：** 中
**预估工时：** 2小时
**依赖任务：** 无

#### 子任务3.1：后端RuleController添加分页接口
**描述：** 在RuleController中添加分页查询接口
**输入：** 分页参数和筛选条件（current, size, ruleType, effective）
**输出：** 分页结果（IPage<WarningRule>）
**验收标准：**
- [ ] 接口路径为 GET /api/rule/page
- [ ] 支持按规则类型筛选
- [ ] 支持按生效状态筛选

**代码提示：**
```java
@GetMapping("/page")
public Response<IPage<WarningRule>> page(
        @RequestParam(defaultValue = "1") long current,
        @RequestParam(defaultValue = "10") long size,
        @RequestParam(required = false) String ruleType,
        @RequestParam(required = false) Integer effective) {
    if (current < 1) current = 1;
    if (size < 1 || size > 100) size = 10;

    IPage<WarningRule> page = warningRuleService.page(new Page<>(current, size), ruleType, effective);
    return Response.success(page);
}
```

#### 子任务3.2：后端WarningRuleService添加分页方法
**描述：** 实现预警规则的分页查询逻辑
**验收标准：**
- [ ] 支持规则类型精确查询
- [ ] 支持生效状态筛选
- [ ] 按更新时间倒序

**代码提示：**
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

#### 子任务3.3：前端API添加分页方法
**描述：** 在api/rule.js中添加分页查询方法
**验收标准：**
- [ ] 方法名为getRulePage
- [ ] 支持传递筛选参数

**代码提示：**
```javascript
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

#### 子任务3.4：前端View修改API调用
**描述：** 修改RuleManagementView.vue使用后端分页接口
**验收标准：**
- [ ] 调用getRulePage方法
- [ ] 正确处理分页数据
- [ ] 筛选功能正常

**代码提示：**
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

---

### 任务4：报表模板表分页功能实现

**任务ID：** TASK-REPORT-001
**优先级：** 中
**预估工时：** 2小时
**依赖任务：** 无

#### 子任务4.1：后端ReportController添加分页接口
**描述：** 在ReportController中添加分页查询接口
**输入：** 分页参数和筛选条件（current, size, category, name）
**输出：** 分页结果（IPage<ReportTemplate>）
**验收标准：**
- [ ] 接口路径为 GET /api/report/page
- [ ] 支持按分类筛选
- [ ] 支持按名称模糊查询

**代码提示：**
```java
@GetMapping("/page")
public Response<IPage<ReportTemplate>> page(
        @RequestParam(defaultValue = "1") long current,
        @RequestParam(defaultValue = "10") long size,
        @RequestParam(required = false) String category,
        @RequestParam(required = false) String name) {
    if (current < 1) current = 1;
    if (size < 1 || size > 100) size = 10;

    IPage<ReportTemplate> page = reportTemplateService.page(new Page<>(current, size), category, name);
    return Response.success(page);
}
```

#### 子任务4.2：后端ReportTemplateService添加分页方法
**描述：** 实现报表模板的分页查询逻辑
**验收标准：**
- [ ] 支持分类精确查询
- [ ] 支持名称模糊查询
- [ ] 按更新时间倒序

**代码提示：**
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

#### 子任务4.3：前端API添加分页方法
**描述：** 在api/report.js中添加分页查询方法
**验收标准：**
- [ ] 方法名为getReportPage
- [ ] 支持传递筛选参数

**代码提示：**
```javascript
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

#### 子任务4.4：前端View添加分页组件
**描述：** 在ReportManagementView.vue中添加分页功能
**验收标准：**
- [ ] 添加el-pagination组件
- [ ] 支持页码切换
- [ ] 支持每页条数调整

**代码提示：**
```vue
<script setup>
const page = reactive({
  current: 1,
  size: 10,
  total: 0
})

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
</script>

<template>
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
</template>
```

---

### 任务5：收藏表分页功能实现

**任务ID：** TASK-FAV-001
**优先级：** 高
**预估工时：** 2小时
**依赖任务：** 无

#### 子任务5.1：后端FavoriteController添加分页接口
**描述：** 在FavoriteController中添加分页查询接口
**输入：** 分页参数和筛选条件（current, size, favType）
**输出：** 分页结果（IPage<Favorite>）
**验收标准：**
- [ ] 接口路径为 GET /api/favorite/page
- [ ] 只返回当前用户的收藏
- [ ] 支持按收藏类型筛选

**代码提示：**
```java
@GetMapping("/page")
public Response<IPage<Favorite>> page(
        @RequestParam(defaultValue = "1") long current,
        @RequestParam(defaultValue = "10") long size,
        @RequestParam(required = false) String favType) {
    if (current < 1) current = 1;
    if (size < 1 || size > 100) size = 10;

    Long userId = SecurityUtil.getCurrentUserId();
    IPage<Favorite> page = favoriteService.page(new Page<>(current, size), userId, favType);
    return Response.success(page);
}
```

#### 子任务5.2：后端FavoriteService添加分页方法
**描述：** 实现收藏的分页查询逻辑
**验收标准：**
- [ ] 按用户ID过滤
- [ ] 支持收藏类型筛选
- [ ] 按创建时间倒序

**代码提示：**
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

#### 子任务5.3：前端API添加分页方法
**描述：** 在api/favorite.js中添加分页查询方法
**验收标准：**
- [ ] 方法名为getFavoritePage
- [ ] 支持传递筛选参数

**代码提示：**
```javascript
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

#### 子任务5.4：前端View添加分页组件
**描述：** 在MyFavoritesView.vue中添加分页功能
**验收标准：**
- [ ] 添加el-pagination组件
- [ ] 支持页码切换
- [ ] 添加loading状态

**代码提示：**
```vue
<script setup>
const page = reactive({
  current: 1,
  size: 10,
  total: 0
})
const loading = ref(false)

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
</script>

<template>
  <el-pagination
    v-model:current-page="page.current"
    v-model:page-size="page.size"
    :total="page.total"
    layout="total, prev, pager, next"
    @current-change="load"
    style="margin-top: 16px"
  />
</template>
```

---

### 任务6：测试与验证

**任务ID：** TASK-TEST-001
**优先级：** 高
**预估工时：** 3小时
**依赖任务：** TASK-DEPT-001, TASK-CAT-001, TASK-RULE-001, TASK-REPORT-001, TASK-FAV-001

#### 子任务6.1：后端单元测试
**描述：** 编写Controller和Service的单元测试
**验收标准：**
- [ ] 所有Controller方法有测试覆盖
- [ ] 参数校验测试通过
- [ ] 边界条件测试通过

**测试用例：**
1. 正常分页查询
2. 参数校验测试（current<1, size>100）
3. 带筛选条件的查询
4. 空数据查询

#### 子任务6.2：前端功能测试
**描述：** 测试前端分页功能
**验收标准：**
- [ ] 页面加载显示第一页数据
- [ ] 翻页功能正常
- [ ] 每页条数调整正常
- [ ] 筛选功能正常

**测试场景：**
1. 页面初始加载
2. 点击下一页
3. 修改每页条数
4. 带筛选条件查询
5. 数据为空时的显示

#### 子任务6.3：集成测试
**描述：** 测试前后端集成
**验收标准：**
- [ ] 前后端接口对接正确
- [ ] 数据格式一致
- [ ] 错误处理正确

#### 子任务6.4：性能测试
**描述：** 测试分页查询性能
**验收标准：**
- [ ] 响应时间<1秒（数据量<10000）
- [ ] SQL执行计划合理
- [ ] 无N+1查询问题

---

### 任务7：文档更新

**任务ID：** TASK-DOC-001
**优先级：** 中
**预估工时：** 1小时
**依赖任务：** TASK-TEST-001

#### 子任务7.1：更新API文档
**描述：** 更新Swagger接口文档
**验收标准：**
- [ ] 所有新接口有文档说明
- [ ] 参数说明完整
- [ ] 响应示例正确

#### 子任务7.2：更新用户手册
**描述：** 更新系统使用说明
**验收标准：**
- [ ] 分页功能使用说明
- [ ] 操作步骤清晰

---

## 3. 任务依赖关系

```
任务依赖图：

TASK-DEPT-001 (部门表) ──┐
TASK-CAT-001 (分类表) ───┤
TASK-RULE-001 (规则表) ──┼──> TASK-TEST-001 (测试) ──> TASK-DOC-001 (文档)
TASK-REPORT-001 (报表表) ┤
TASK-FAV-001 (收藏表) ───┘

说明：
- 任务1-5可以并行执行
- 任务6依赖任务1-5完成
- 任务7依赖任务6完成
```

## 4. 任务执行计划

### 4.1 执行顺序（按优先级）

**第一阶段（并行执行）：**
1. TASK-FAV-001（收藏表 - 高优先级）
2. TASK-DEPT-001（部门表 - 中优先级）
3. TASK-RULE-001（规则表 - 中优先级）
4. TASK-REPORT-001（报表表 - 中优先级）
5. TASK-CAT-001（分类表 - 低优先级）

**第二阶段：**
6. TASK-TEST-001（测试与验证）

**第三阶段：**
7. TASK-DOC-001（文档更新）

### 4.2 时间估算

| 阶段 | 任务数 | 预估工时 | 说明 |
|------|--------|----------|------|
| 第一阶段 | 5个 | 9.5小时 | 可并行执行 |
| 第二阶段 | 1个 | 3小时 | 需等待第一阶段完成 |
| 第三阶段 | 1个 | 1小时 | 需等待第二阶段完成 |
| **总计** | **7个** | **13.5小时** | - |

### 4.3 里程碑

- **里程碑1**：完成所有后端接口开发（第1阶段完成）
- **里程碑2**：完成所有前端功能开发（第1阶段完成）
- **里程碑3**：通过所有测试（第2阶段完成）
- **里程碑4**：文档更新完成，项目交付（第3阶段完成）

## 5. 风险控制

### 5.1 技术风险

| 风险项 | 影响 | 缓解措施 |
|--------|------|----------|
| 接口对接错误 | 中 | 统一接口规范，充分测试 |
| 性能不达标 | 低 | 使用数据库分页，添加索引 |
| 现有功能受影响 | 低 | 保留原接口，回归测试 |

### 5.2 进度风险

| 风险项 | 影响 | 缓解措施 |
|--------|------|----------|
| 任务延期 | 中 | 合理估算工时，预留缓冲 |
| 依赖阻塞 | 低 | 明确依赖关系，并行开发 |

## 6. 验收标准

### 6.1 功能验收
- [ ] 所有5个表都实现了分页功能
- [ ] 分页参数和响应格式符合规范
- [ ] 前端分页组件正常工作
- [ ] 翻页、跳页、修改每页条数功能正常
- [ ] 筛选功能正常

### 6.2 性能验收
- [ ] 分页查询响应时间<1秒（数据量<10000）
- [ ] 使用数据库分页而非内存分页
- [ ] SQL执行计划合理

### 6.3 兼容性验收
- [ ] 原有list接口仍然可用
- [ ] 现有功能未受影响
- [ ] 前后端接口对接正确

### 6.4 代码质量
- [ ] 代码符合规范
- [ ] 有适当的注释
- [ ] 单元测试覆盖
- [ ] 无明显性能问题

## 7. 任务执行建议

### 7.1 开发环境准备
- 确保后端项目可正常启动
- 确保前端项目可正常启动
- 确保数据库连接正常
- 准备测试数据

### 7.2 开发规范
- 遵循现有代码风格
- 添加必要的注释
- 及时提交代码
- 编写单元测试

### 7.3 测试建议
- 每完成一个子任务立即测试
- 使用Postman测试后端接口
- 使用浏览器测试前端功能
- 记录测试结果

### 7.4 注意事项
- 保留原有list接口，不要删除
- 参数校验要严格
- 错误处理要完善
- 性能要关注

## 8. 任务总结

### 8.1 任务统计
- **总任务数**：7个主任务，28个子任务
- **预估总工时**：13.5小时
- **涉及文件数**：20个文件（10个后端 + 10个前端）

### 8.2 关键成果
- 5个数据表实现分页功能
- 统一的分页接口规范
- 完整的测试覆盖
- 更新的技术文档

### 8.3 后续优化
- 监控分页接口性能
- 根据使用情况调整默认每页条数
- 考虑添加缓存优化
- 收集用户反馈持续改进
