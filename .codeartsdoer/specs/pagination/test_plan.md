# 分页功能测试验证文档

## 测试概述

本文档详细说明了分页功能的测试计划、测试用例和验证步骤，确保分页功能满足需求规格和设计文档的要求。

**测试范围：**
- 后端API接口测试
- 前端页面功能测试
- 性能测试
- 安全测试

**测试环境：**
- 后端：Spring Boot 2.7.18 + MyBatis-Plus 3.5.5
- 前端：Vue 3 + Element Plus
- 数据库：MySQL 8.0.33

---

## 1. 后端API接口测试

### 1.1 部门管理分页接口测试

**接口地址：** `GET /api/department/page`

**测试用例：**

| 用例编号 | 测试场景 | 请求参数 | 预期结果 |
|---------|---------|---------|---------|
| TC-001 | 正常分页查询 | current=1, size=10 | 返回第1页数据，每页10条 |
| TC-002 | 带筛选条件的分页查询 | current=1, size=10, name=技术 | 返回名称包含"技术"的部门 |
| TC-003 | 翻页功能 | current=2, size=10 | 返回第2页数据 |
| TC-004 | 修改每页条数 | current=1, size=20 | 返回第1页数据，每页20条 |
| TC-005 | 空数据查询 | current=1, size=10, name=不存在的部门 | 返回空数据，total=0 |
| TC-006 | 参数默认值 | 不传任何参数 | 使用默认值current=1, size=10 |
| TC-007 | 最大每页条数限制 | current=1, size=200 | 每页最大100条，不会抛出异常 |

**测试命令（使用curl）：**

```bash
# TC-001: 正常分页查询
curl -X GET "http://localhost:8080/api/department/page?current=1&size=10" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-002: 带筛选条件的分页查询
curl -X GET "http://localhost:8080/api/department/page?current=1&size=10&name=技术" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-003: 翻页功能
curl -X GET "http://localhost:8080/api/department/page?current=2&size=10" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-004: 修改每页条数
curl -X GET "http://localhost:8080/api/department/page?current=1&size=20" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-005: 空数据查询
curl -X GET "http://localhost:8080/api/department/page?current=1&size=10&name=不存在的部门" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-006: 参数默认值
curl -X GET "http://localhost:8080/api/department/page" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-007: 最大每页条数限制
curl -X GET "http://localhost:8080/api/department/page?current=1&size=200" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**验证要点：**
- 响应状态码为200
- 响应数据包含 `records`、`total`、`size`、`current`、`pages` 字段
- `records` 数组长度不超过 `size`
- 筛选条件正确生效
- 分页参数正确生效

---

### 1.2 数据分类管理分页接口测试

**接口地址：** `GET /api/category/page`

**测试用例：**

| 用例编号 | 测试场景 | 请求参数 | 预期结果 |
|---------|---------|---------|---------|
| TC-008 | 正常分页查询 | current=1, size=10 | 返回第1页数据，每页10条 |
| TC-009 | 带筛选条件的分页查询 | current=1, size=10, name=数据 | 返回名称包含"数据"的分类 |

**测试命令：**

```bash
# TC-008: 正常分页查询
curl -X GET "http://localhost:8080/api/category/page?current=1&size=10" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-009: 带筛选条件的分页查询
curl -X GET "http://localhost:8080/api/category/page?current=1&size=10&name=数据" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### 1.3 预警规则管理分页接口测试

**接口地址：** `GET /api/rule/page`

**测试用例：**

| 用例编号 | 测试场景 | 请求参数 | 预期结果 |
|---------|---------|---------|---------|
| TC-010 | 正常分页查询 | current=1, size=10 | 返回第1页数据，每页10条 |
| TC-011 | 按规则类型筛选 | current=1, size=10, ruleType=TURNOVER | 返回类型为TURNOVER的规则 |
| TC-012 | 按生效状态筛选 | current=1, size=10, isActive=true | 返回生效的规则 |
| TC-013 | 组合筛选 | current=1, size=10, ruleType=TURNOVER, isActive=true | 返回生效的TURNOVER类型规则 |

**测试命令：**

```bash
# TC-010: 正常分页查询
curl -X GET "http://localhost:8080/api/rule/page?current=1&size=10" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-011: 按规则类型筛选
curl -X GET "http://localhost:8080/api/rule/page?current=1&size=10&ruleType=TURNOVER" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-012: 按生效状态筛选
curl -X GET "http://localhost:8080/api/rule/page?current=1&size=10&isActive=true" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-013: 组合筛选
curl -X GET "http://localhost:8080/api/rule/page?current=1&size=10&ruleType=TURNOVER&isActive=true" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### 1.4 报表模板管理分页接口测试

**接口地址：** `GET /api/report/page`

**测试用例：**

| 用例编号 | 测试场景 | 请求参数 | 预期结果 |
|---------|---------|---------|---------|
| TC-014 | 正常分页查询 | current=1, size=10 | 返回第1页数据，每页10条 |
| TC-015 | 按报表分类筛选 | current=1, size=10, category=HR | 返回HR分类的报表 |
| TC-016 | 按报表名称筛选 | current=1, size=10, name=员工 | 返回名称包含"员工"的报表 |
| TC-017 | 组合筛选 | current=1, size=10, category=HR, name=员工 | 返回HR分类且名称包含"员工"的报表 |

**测试命令：**

```bash
# TC-014: 正常分页查询
curl -X GET "http://localhost:8080/api/report/page?current=1&size=10" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-015: 按报表分类筛选
curl -X GET "http://localhost:8080/api/report/page?current=1&size=10&category=HR" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-016: 按报表名称筛选
curl -X GET "http://localhost:8080/api/report/page?current=1&size=10&name=员工" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-017: 组合筛选
curl -X GET "http://localhost:8080/api/report/page?current=1&size=10&category=HR&name=员工" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### 1.5 收藏管理分页接口测试

**接口地址：** `GET /api/favorite/page`

**测试用例：**

| 用例编号 | 测试场景 | 请求参数 | 预期结果 |
|---------|---------|---------|---------|
| TC-018 | 正常分页查询 | current=1, size=10 | 返回当前用户的第1页数据 |
| TC-019 | 按收藏类型筛选 | current=1, size=10, favType=REPORT | 返回当前用户的REPORT类型收藏 |
| TC-020 | 用户数据隔离测试 | 使用用户A的token查询 | 只返回用户A的收藏数据 |

**测试命令：**

```bash
# TC-018: 正常分页查询
curl -X GET "http://localhost:8080/api/favorite/page?current=1&size=10" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-019: 按收藏类型筛选
curl -X GET "http://localhost:8080/api/favorite/page?current=1&size=10&favType=REPORT" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-020: 用户数据隔离测试（使用用户A的token）
curl -X GET "http://localhost:8080/api/favorite/page?current=1&size=10" \
  -H "Authorization: Bearer USER_A_TOKEN"
```

**验证要点：**
- 确保用户只能看到自己的收藏数据
- 不同用户的收藏数据互不干扰

---

## 2. 前端页面功能测试

### 2.1 部门管理页面测试

**测试步骤：**

1. **页面加载测试**
   - 打开部门管理页面
   - 验证默认显示第1页，每页10条数据
   - 验证分页组件显示正确的总记录数和总页数

2. **分页功能测试**
   - 点击"下一页"按钮，验证数据更新为第2页
   - 点击"上一页"按钮，验证数据更新为第1页
   - 点击页码"3"，验证数据更新为第3页
   - 修改每页条数为20，验证数据更新为每页20条

3. **筛选功能测试**
   - 在"部门名称"输入框中输入"技术"
   - 点击"查询"按钮，验证只显示名称包含"技术"的部门
   - 点击"重置"按钮，验证查询条件清空，页码重置为1，显示所有数据

4. **数据操作测试**
   - 点击"新增部门"按钮，验证对话框正常打开
   - 点击"编辑"按钮，验证对话框正常打开并显示部门信息
   - 点击"删除"按钮，验证确认对话框正常显示
   - 操作完成后，验证数据列表自动刷新

**预期结果：**
- 所有功能正常工作
- 分页组件正确显示页码和记录数
- 筛选条件正确生效
- 数据操作后列表自动刷新

---

### 2.2 数据分类管理页面测试

**测试步骤：** 与部门管理页面类似

**预期结果：** 与部门管理页面类似

---

### 2.3 预警规则管理页面测试

**测试步骤：**

1. **页面加载测试**
   - 打开预警规则管理页面
   - 验证默认显示第1页，每页10条数据

2. **分页功能测试**
   - 与部门管理页面类似

3. **筛选功能测试**
   - 在"规则类型"下拉框中选择"TURNOVER"
   - 在"生效状态"下拉框中选择"生效"
   - 点击"查询"按钮，验证只显示符合条件的规则
   - 点击"重置"按钮，验证查询条件清空

**预期结果：**
- 所有功能正常工作
- 筛选条件正确生效

---

### 2.4 报表模板管理页面测试

**测试步骤：** 与预警规则管理页面类似

**预期结果：** 与预警规则管理页面类似

---

### 2.5 我的收藏页面测试

**测试步骤：**

1. **页面加载测试**
   - 打开我的收藏页面
   - 验证默认显示第1页，每页10条数据
   - 验证只显示当前用户的收藏数据

2. **用户数据隔离测试**
   - 使用用户A登录，查看收藏列表
   - 使用用户B登录，查看收藏列表
   - 验证两个用户看到的收藏数据不同

**预期结果：**
- 所有功能正常工作
- 用户数据隔离正确

---

## 3. 性能测试

### 3.1 响应时间测试

**测试目标：** 分页查询响应时间 < 1秒（数据量 < 10000）

**测试步骤：**

1. 使用Postman或curl调用分页接口
2. 记录响应时间
3. 对比不同数据量下的响应时间

**测试命令：**

```bash
# 使用curl测量响应时间
time curl -X GET "http://localhost:8080/api/department/page?current=1&size=10" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**预期结果：**
- 数据量 < 1000：响应时间 < 0.5秒
- 数据量 < 10000：响应时间 < 1秒
- 数据量 > 10000：响应时间 < 2秒

---

### 3.2 数据库分页验证

**测试目标：** 确认使用数据库分页而非内存分页

**测试步骤：**

1. 在数据库中查看慢查询日志
2. 验证SQL语句包含 `LIMIT` 关键字
3. 使用 `EXPLAIN` 分析SQL执行计划

**测试命令：**

```sql
-- 查看慢查询日志
SHOW VARIABLES LIKE 'slow_query_log%';

-- 使用EXPLAIN分析SQL
EXPLAIN SELECT * FROM hr_department WHERE name LIKE '%技术%' ORDER BY id LIMIT 10;
```

**预期结果：**
- SQL语句包含 `LIMIT` 关键字
- 执行计划显示使用了索引
- 没有 `Using filesort` 或 `Using temporary` 等性能警告

---

### 3.3 索引有效性验证

**测试目标：** 确认索引正确创建并生效

**测试步骤：**

1. 执行 `database/verify_indexes.sql` 脚本
2. 查看 `EXPLAIN` 结果中的 `type` 和 `key` 列
3. 验证索引是否被使用

**预期结果：**
- `type` 列显示 `ref` 或 `range`（不是 `ALL`）
- `key` 列显示使用的索引名称
- `rows` 列显示预计扫描的行数较小

---

## 4. 安全测试

### 4.1 JWT认证测试

**测试用例：**

| 用例编号 | 测试场景 | 测试步骤 | 预期结果 |
|---------|---------|---------|---------|
| TC-021 | 未登录访问 | 不携带Token访问分页接口 | 返回401未授权 |
| TC-022 | Token过期 | 使用过期的Token访问分页接口 | 返回401未授权 |
| TC-023 | Token无效 | 使用无效的Token访问分页接口 | 返回401未授权 |

**测试命令：**

```bash
# TC-021: 未登录访问
curl -X GET "http://localhost:8080/api/department/page?current=1&size=10"

# TC-022: Token过期（使用过期的Token）
curl -X GET "http://localhost:8080/api/department/page?current=1&size=10" \
  -H "Authorization: Bearer EXPIRED_TOKEN"

# TC-023: Token无效（使用无效的Token）
curl -X GET "http://localhost:8080/api/department/page?current=1&size=10" \
  -H "Authorization: Bearer INVALID_TOKEN"
```

**预期结果：**
- 所有测试用例都返回401状态码
- 响应体包含未授权的错误信息

---

### 4.2 权限控制测试

**测试用例：**

| 用例编号 | 测试场景 | 测试步骤 | 预期结果 |
|---------|---------|---------|---------|
| TC-024 | 普通用户访问管理员接口 | 使用普通用户Token访问部门分页接口 | 返回403禁止访问 |
| TC-025 | 管理员访问管理员接口 | 使用管理员Token访问部门分页接口 | 返回200成功 |

**测试命令：**

```bash
# TC-024: 普通用户访问管理员接口
curl -X GET "http://localhost:8080/api/department/page?current=1&size=10" \
  -H "Authorization: Bearer USER_TOKEN"

# TC-025: 管理员访问管理员接口
curl -X GET "http://localhost:8080/api/department/page?current=1&size=10" \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

**预期结果：**
- TC-024返回403状态码
- TC-025返回200状态码

---

### 4.3 数据隔离测试

**测试用例：**

| 用例编号 | 测试场景 | 测试步骤 | 预期结果 |
|---------|---------|---------|---------|
| TC-026 | 用户访问其他用户收藏 | 用户A访问用户B的收藏数据 | 只返回用户A的数据 |
| TC-027 | 用户A和用户B数据隔离 | 分别使用用户A和用户B的Token查询 | 返回的数据不同 |

**测试命令：**

```bash
# TC-026: 用户访问其他用户收藏（使用用户A的Token）
curl -X GET "http://localhost:8080/api/favorite/page?current=1&size=10" \
  -H "Authorization: Bearer USER_A_TOKEN"

# TC-027: 用户A和用户B数据隔离
# 使用用户A的Token
curl -X GET "http://localhost:8080/api/favorite/page?current=1&size=10" \
  -H "Authorization: Bearer USER_A_TOKEN"

# 使用用户B的Token
curl -X GET "http://localhost:8080/api/favorite/page?current=1&size=10" \
  -H "Authorization: Bearer USER_B_TOKEN"
```

**预期结果：**
- 用户A只能看到自己的收藏数据
- 用户B只能看到自己的收藏数据
- 两个用户的数据互不干扰

---

### 4.4 SQL注入防护测试

**测试用例：**

| 用例编号 | 测试场景 | 测试步骤 | 预期结果 |
|---------|---------|---------|---------|
| TC-028 | SQL注入攻击 | 在name参数中输入SQL注入字符 | 被正确转义，不执行SQL语句 |

**测试命令：**

```bash
# TC-028: SQL注入攻击
curl -X GET "http://localhost:8080/api/department/page?current=1&size=10&name=' OR '1'='1" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**预期结果：**
- SQL注入字符被正确转义
- 不执行恶意SQL语句
- 返回空数据或正常数据（取决于数据库内容）

---

### 4.5 参数校验测试

**测试用例：**

| 用例编号 | 测试场景 | 测试步骤 | 预期结果 |
|---------|---------|---------|---------|
| TC-029 | 非法分页参数 | 传入负数的页码或每页条数 | 使用默认值或返回错误 |
| TC-030 | 超大每页条数 | 传入超过100的每页条数 | 限制为100 |

**测试命令：**

```bash
# TC-029: 非法分页参数
curl -X GET "http://localhost:8080/api/department/page?current=-1&size=-10" \
  -H "Authorization: Bearer YOUR_TOKEN"

# TC-030: 超大每页条数
curl -X GET "http://localhost:8080/api/department/page?current=1&size=200" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**预期结果：**
- TC-029使用默认值或返回错误
- TC-030限制为100

---

## 5. 测试执行计划

### 5.1 测试环境准备

1. **后端环境**
   - 启动Spring Boot应用
   - 确保数据库连接正常
   - 执行索引创建SQL脚本

2. **前端环境**
   - 启动Vue开发服务器
   - 确保API请求正常

3. **测试数据准备**
   - 准备测试用户账号（管理员和普通用户）
   - 准备测试数据（部门、分类、规则、报表、收藏）

### 5.2 测试执行顺序

1. **第一阶段：后端API测试**
   - 执行所有后端API接口测试用例
   - 记录测试结果

2. **第二阶段：前端页面测试**
   - 执行所有前端页面功能测试用例
   - 记录测试结果

3. **第三阶段：性能测试**
   - 执行性能测试用例
   - 记录性能数据

4. **第四阶段：安全测试**
   - 执行安全测试用例
   - 记录测试结果

### 5.3 测试报告

**测试报告应包含：**

1. **测试概述**
   - 测试范围
   - 测试环境
   - 测试人员
   - 测试时间

2. **测试结果**
   - 测试用例总数
   - 通过用例数
   - 失败用例数
   - 通过率

3. **缺陷清单**
   - 缺陷编号
   - 缺陷描述
   - 严重程度
   - 状态

4. **性能数据**
   - 响应时间统计
   - 数据库性能分析

5. **建议**
   - 优化建议
   - 改进建议

---

## 6. 测试通过标准

### 6.1 功能测试通过标准

- 所有功能测试用例通过率 ≥ 95%
- 核心功能测试用例通过率 = 100%
- 无严重缺陷

### 6.2 性能测试通过标准

- 分页查询响应时间 < 1秒（数据量 < 10000）
- 使用数据库分页而非内存分页
- 索引正确创建并生效

### 6.3 安全测试通过标准

- JWT认证正常
- 权限控制正常
- 数据隔离正常
- SQL注入防护有效
- 参数校验正常

---

## 7. 附录

### 7.1 测试数据准备SQL

```sql
-- 准备测试部门数据
INSERT INTO hr_department (name, parent_id, sort_order) VALUES
('技术部', 0, 1),
('市场部', 0, 2),
('人事部', 0, 3),
('研发中心', 1, 1),
('测试部', 1, 2);

-- 准备测试分类数据
INSERT INTO hr_data_category (name, parent_id, sort_order) VALUES
('人力资源', 0, 1),
('财务数据', 0, 2),
('业务数据', 0, 3),
('员工信息', 1, 1),
('薪资数据', 1, 2);

-- 准备测试规则数据
INSERT INTO warning_rule (rule_name, rule_type, is_active, created_time) VALUES
('离职预警', 'TURNOVER', true, NOW()),
('绩效预警', 'PERFORMANCE', true, NOW()),
('培训预警', 'TRAINING', false, NOW());

-- 准备测试报表数据
INSERT INTO report_template (name, category, created_time) VALUES
('员工统计报表', 'HR', NOW()),
('薪资分析报表', 'HR', NOW()),
('业务数据报表', 'BUSINESS', NOW());

-- 准备测试用户数据（如果不存在）
INSERT INTO sys_user (username, password, role) VALUES
('test_admin', 'hashed_password', 'HR_ADMIN'),
('test_user', 'hashed_password', 'HR_USER');

-- 准备测试收藏数据
INSERT INTO sys_favorite (user_id, fav_type, target_id, created_time) VALUES
(1, 'REPORT', 1, NOW()),
(1, 'REPORT', 2, NOW()),
(2, 'REPORT', 1, NOW());
```

### 7.2 常见问题排查

**问题1：分页查询很慢**

解决方案：
1. 检查是否创建了索引
2. 使用 `EXPLAIN` 分析SQL执行计划
3. 检查是否有全表扫描

**问题2：前端分页组件不显示**

解决方案：
1. 检查API请求是否成功
2. 检查响应数据格式是否正确
3. 检查分页组件的绑定是否正确

**问题3：用户数据隔离失效**

解决方案：
1. 检查JWT Token是否正确
2. 检查Service层是否按用户ID过滤
3. 检查Controller层是否从JWT获取用户ID

---

**文档版本：** v1.0
**创建日期：** 2026-03-25
**作者：** SDD Agent
**最后更新：** 2026-03-25
