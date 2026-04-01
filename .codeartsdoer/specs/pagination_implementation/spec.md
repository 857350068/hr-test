# 数据表分页功能实现 - 需求规格说明

## 1. 项目概述

### 1.1 项目背景
人力资源数据中心系统（HrDataCenter）当前部分数据表未实现分页功能，随着数据量增长，可能导致性能问题和用户体验下降。本需求旨在为所有数据表实现统一的分页功能。

### 1.2 项目目标
- 为所有未实现分页的数据表添加分页功能
- 统一前后端分页实现方式
- 提升系统性能和用户体验
- 确保分页功能的一致性和可维护性

### 1.3 技术栈
**后端：**
- Spring Boot 2.7.18
- MyBatis-Plus 3.5.5（已集成分页插件）
- MySQL 8.0.33

**前端：**
- Vue 3.4.0
- Element Plus 2.5.0（提供el-pagination组件）
- Axios 1.6.5

## 2. 系统范围

### 2.1 系统范围定义
本需求涵盖以下数据表的分页功能实现：

**需要实现分页的表（当前未实现）：**
1. 部门表（hr_department）- 后端无分页，前端无分页
2. 数据分类表（hr_data_category）- 后端无分页，前端无分页
3. 预警规则表（warning_rule）- 后端无分页，前端无分页
4. 报表模板表（report_template）- 后端无分页，前端无分页
5. 收藏表（sys_favorite）- 后端无分页，前端无分页

**已实现分页的表（作为参考）：**
1. 用户表（sys_user）- 后端已分页，前端已分页
2. 员工档案表（employee_profile）- 后端已分页，前端已分页
3. 操作日志表（sys_log）- 后端已分页，前端已分页
4. 分析规则表（analysis_rules）- 后端已分页，前端已分页

### 2.2 排除范围
- 数据同步日志表（data_sync_log）- 仅管理员查看，数据量小
- 预警模型表（warning_model）- 已通过分析规则表实现
- 报表定时任务表（report_schedule_task）- 已实现分页

## 3. 功能需求

### 3.1 部门表分页功能

**需求ID：** REQ-DEPT-001
**需求描述：** 为部门表实现分页查询功能

**验收标准（EARS格式）：**
- **When** 用户访问部门管理页面
- **The system shall** 默认显示第1页，每页10条记录
- **So that** 用户可以分页浏览部门数据

- **When** 用户点击分页组件的下一页按钮
- **The system shall** 加载并显示下一页的部门数据
- **So that** 用户可以查看更多部门信息

- **When** 用户修改每页显示条数
- **The system shall** 重新加载数据并按新的每页条数显示
- **So that** 用户可以自定义每页显示的数据量

**功能点：**
- 后端：DepartmentController添加分页查询接口
- 后端：DepartmentService添加分页查询方法
- 前端：DepartmentManagementView添加el-pagination组件
- 前端：支持页码切换和每页条数调整

### 3.2 数据分类表分页功能

**需求ID：** REQ-CAT-001
**需求描述：** 为数据分类表实现分页查询功能

**验收标准（EARS格式）：**
- **When** 用户访问数据分类管理页面
- **The system shall** 默认显示第1页，每页10条记录
- **So that** 用户可以分页浏览分类数据

- **When** 分类数据超过10条
- **The system shall** 显示分页组件并支持翻页
- **So that** 用户可以查看所有分类数据

**功能点：**
- 后端：DataCategoryController添加分页查询接口
- 后端：DataCategoryService添加分页查询方法
- 前端：CategoryManagementView添加el-pagination组件

### 3.3 预警规则表分页功能

**需求ID：** REQ-RULE-001
**需求描述：** 为预警规则表实现分页查询功能

**验收标准（EARS格式）：**
- **When** 用户访问预警规则管理页面
- **The system shall** 默认显示第1页，每页10条记录
- **So that** 用户可以分页浏览规则数据

- **When** 用户按规则类型筛选
- **The system shall** 在筛选结果中支持分页
- **So that** 用户可以分页查看特定类型的规则

**功能点：**
- 后端：RuleController添加分页查询接口
- 后端：WarningRuleService添加分页查询方法
- 前端：RuleManagementView已存在分页，需对接后端分页接口

### 3.4 报表模板表分页功能

**需求ID：** REQ-REPORT-001
**需求描述：** 为报表模板表实现分页查询功能

**验收标准（EARS格式）：**
- **When** 用户访问报表管理页面
- **The system shall** 默认显示第1页，每页10条记录
- **So that** 用户可以分页浏览报表模板

- **When** 报表模板数量超过当前页容量
- **The system shall** 显示总记录数和总页数
- **So that** 用户了解数据总量

**功能点：**
- 后端：ReportController添加分页查询接口
- 后端：ReportTemplateService添加分页查询方法
- 前端：ReportManagementView添加el-pagination组件

### 3.5 收藏表分页功能

**需求ID：** REQ-FAV-001
**需求描述：** 为收藏表实现分页查询功能

**验收标准（EARS格式）：**
- **When** 用户访问我的收藏页面
- **The system shall** 默认显示第1页，每页10条记录
- **So that** 用户可以分页浏览收藏内容

- **When** 用户收藏数量超过10条
- **The system shall** 显示分页组件
- **So that** 用户可以查看所有收藏

**功能点：**
- 后端：FavoriteController添加分页查询接口
- 后端：FavoriteService添加分页查询方法
- 前端：MyFavoritesView添加el-pagination组件

## 4. 非功能需求

### 4.1 性能需求

**需求ID：** NFR-PERF-001
**需求描述：** 分页查询性能要求

**验收标准（EARS格式）：**
- **When** 执行分页查询
- **The system shall** 在1秒内返回结果（数据量<10000条）
- **So that** 用户获得流畅的操作体验

- **When** 数据量超过10000条
- **The system shall** 使用数据库分页而非内存分页
- **So that** 系统性能不受影响

### 4.2 一致性需求

**需求ID：** NFR-CONSIST-001
**需求描述：** 分页实现一致性要求

**验收标准（EARS格式）：**
- **When** 实现分页功能
- **The system shall** 使用统一的分页参数命名（current, size）
- **So that** API接口保持一致性

- **When** 返回分页结果
- **The system shall** 使用MyBatis-Plus的IPage标准格式
- **So that** 前端可以统一处理分页数据

### 4.3 兼容性需求

**需求ID：** NFR-COMPAT-001
**需求描述：** 向后兼容性要求

**验收标准（EARS格式）：**
- **When** 添加分页功能
- **The system shall** 保留原有的list接口
- **So that** 不影响现有功能

- **When** 前端调用分页接口
- **The system shall** 支持可选的分页参数
- **So that** 保持向后兼容

## 5. 数据需求

### 5.1 分页参数规范

**请求参数：**
- `current`：当前页码，从1开始，默认值1
- `size`：每页大小，默认值10，最大值100

**响应格式：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [],      // 当前页数据
    "total": 0,         // 总记录数
    "size": 10,         // 每页大小
    "current": 1,       // 当前页
    "pages": 0          // 总页数
  }
}
```

### 5.2 数据量评估

| 表名 | 当前数据量 | 预估增长 | 优先级 |
|------|-----------|---------|--------|
| hr_department | 17条 | 低（年增长<10条） | 中 |
| hr_data_category | 8条 | 低（年增长<5条） | 低 |
| warning_rule | 10条 | 中（年增长~20条） | 中 |
| report_template | 10条 | 中（年增长~30条） | 中 |
| sys_favorite | 12条 | 高（随用户增长） | 高 |

## 6. 接口需求

### 6.1 后端API接口

**部门分页查询：**
- 接口路径：`GET /api/department/page`
- 请求参数：`current`, `size`, `name`(可选)
- 响应格式：IPage<Department>

**数据分类分页查询：**
- 接口路径：`GET /api/category/page`
- 请求参数：`current`, `size`, `name`(可选)
- 响应格式：IPage<DataCategory>

**预警规则分页查询：**
- 接口路径：`GET /api/rule/page`
- 请求参数：`current`, `size`, `ruleType`(可选)
- 响应格式：IPage<WarningRule>

**报表模板分页查询：**
- 接口路径：`GET /api/report/page`
- 请求参数：`current`, `size`, `category`(可选), `name`(可选)
- 响应格式：IPage<ReportTemplate>

**收藏分页查询：**
- 接口路径：`GET /api/favorite/page`
- 请求参数：`current`, `size`, `favType`(可选)
- 响应格式：IPage<Favorite>

### 6.2 前端组件需求

**分页组件配置：**
- 使用Element Plus的el-pagination组件
- 显示：总条数、页码、每页条数选择器
- 支持页码快速跳转
- 布局：`total, sizes, prev, pager, next, jumper`

## 7. 约束条件

### 7.1 技术约束
- 必须使用MyBatis-Plus的分页插件（已集成）
- 必须使用Element Plus的分页组件
- 不得修改现有已实现分页的接口

### 7.2 业务约束
- 部门表支持树形结构展示，分页需考虑层级关系
- 收藏表需按用户ID过滤
- 预警规则需支持按生效状态筛选

### 7.3 安全约束
- 分页参数需进行边界校验（防止SQL注入）
- 每页最大条数限制为100
- 用户只能查看自己的收藏数据

## 8. 验收标准

### 8.1 功能验收
- [ ] 所有目标表都实现了分页功能
- [ ] 分页参数和响应格式符合规范
- [ ] 前端分页组件正常工作
- [ ] 翻页、跳页、修改每页条数功能正常

### 8.2 性能验收
- [ ] 分页查询响应时间<1秒（数据量<10000）
- [ ] 使用数据库分页而非内存分页
- [ ] 分页查询SQL执行计划合理

### 8.3 兼容性验收
- [ ] 原有list接口仍然可用
- [ ] 现有功能未受影响
- [ ] 前后端接口对接正确

## 9. 依赖关系

### 9.1 前置依赖
- MyBatis-Plus分页插件已配置（已完成）
- Element Plus组件库已集成（已完成）

### 9.2 后续影响
- 数据量增长后的性能优化
- 可能需要添加索引优化查询性能

## 10. 风险评估

| 风险项 | 风险等级 | 影响范围 | 缓解措施 |
|--------|---------|---------|---------|
| 现有功能受影响 | 低 | 已有页面 | 保留原接口，充分测试 |
| 性能下降 | 低 | 所有分页查询 | 使用数据库分页，添加索引 |
| 前后端对接错误 | 中 | 新增接口 | 统一接口规范，编写接口文档 |
| 数据不一致 | 低 | 分页数据 | 使用事务，添加数据校验 |

## 11. 术语表

- **IPage**：MyBatis-Plus的分页结果封装类
- **el-pagination**：Element Plus的分页组件
- **EARS**：Easy Approach to Requirements Syntax，需求规格语法
- **分页**：将大量数据分成多个页面显示的技术
- **每页大小**：单个页面显示的数据条数

## 12. 附录

### 12.1 参考文档
- MyBatis-Plus分页插件文档：https://baomidou.com/pages/97710a/
- Element Plus分页组件文档：https://element-plus.org/zh-CN/component/pagination.html

### 12.2 相关代码文件
**后端：**
- DepartmentController.java
- DataCategoryController.java
- RuleController.java
- ReportController.java
- FavoriteController.java

**前端：**
- DepartmentManagementView.vue
- CategoryManagementView.vue
- RuleManagementView.vue
- ReportManagementView.vue
- MyFavoritesView.vue

### 12.3 已实现分页的参考示例
**用户管理（UserAdminController.java）：**
```java
@GetMapping
public Response<IPage<User>> page(
    @RequestParam(defaultValue = "1") long current,
    @RequestParam(defaultValue = "10") long size,
    @RequestParam(required = false) String username,
    @RequestParam(required = false) String name,
    @RequestParam(required = false) String role) {
    IPage<User> page = userService.page(new Page<>(current, size), username, name, role);
    page.getRecords().forEach(u -> u.setPassword(null));
    return Response.success(page);
}
```

**前端分页组件示例（UserManagementView.vue）：**
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
