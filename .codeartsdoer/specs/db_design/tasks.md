# 数据库设计实现任务清单

## 任务概述
根据需求规格文档(spec.md)和技术设计文档(design.md),完成人力资源数据中心项目的MySQL和Hive数据库设计,包括建库建表、索引优化、初始化数据生成等全部工作。

---

## 第一阶段:MySQL数据库设计与实现

### 任务1.1:创建MySQL建库脚本
**任务描述**: 创建MySQL数据库创建脚本,配置字符集和排序规则
**输入**: design.md中的数据库配置要求
**输出**: database/mysql/01_create_database.sql
**验收标准**:
- 数据库名为hr_datacenter
- 字符集为utf8mb4
- 排序规则为utf8mb4_unicode_ci
- 包含数据库删除和重建逻辑

### 任务1.2:创建MySQL建表脚本
**任务描述**: 创建10张核心业务表的DDL脚本
**输入**: design.md中的表结构设计
**输出**: database/mysql/02_create_tables.sql
**验收标准**:
- 包含sys_user、employee、attendance、leave、performance_goal、performance_evaluation、salary_payment、salary_adjustment、training_course、training_enrollment共10张表
- 每张表都有主键、create_time、update_time、deleted字段
- 所有字段都有COMMENT注释
- 使用InnoDB引擎和utf8mb4字符集

### 任务1.3:创建MySQL索引脚本
**任务描述**: 创建高频查询字段的索引脚本
**输入**: design.md中的索引设计
**输出**: database/mysql/03_create_indexes.sql
**验收标准**:
- 为员工编号、用户名创建唯一索引
- 为考勤日期、绩效年度周期、薪资年月创建联合索引
- 为部门、状态等高频查询字段创建普通索引
- 所有索引都有性能优化说明注释

### 任务1.4:生成用户初始化数据
**任务描述**: 生成至少2个测试用户的INSERT脚本
**输入**: spec.md中的用户数据规则
**输出**: database/mysql/04_insert_users.sql
**验收标准**:
- 包含admin和hr001两个用户
- 密码使用BCrypt加密(123456的加密结果)
- 用户名唯一
- 包含完整的用户信息

### 任务1.5:生成员工初始化数据
**任务描述**: 生成至少50个测试员工的INSERT脚本
**输入**: spec.md中的员工数据规则
**输出**: database/mysql/05_insert_employees.sql
**验收标准**:
- 至少50条员工记录
- 覆盖不同部门(技术部、人事部、财务部、市场部等)
- 覆盖不同职位(工程师、经理、主管、专员等)
- 覆盖不同状态(在职、离职、试用)
- 员工编号格式为EMP+8位数字
- 所有数据符合业务规则(入职日期、薪资等)

### 任务1.6:生成考勤初始化数据
**任务描述**: 生成至少1000条考勤记录的INSERT脚本
**输入**: spec.md中的考勤数据规则
**输出**: database/mysql/06_insert_attendance.sql
**验收标准**:
- 至少1000条考勤记录
- 覆盖最近3个月的数据
- 覆盖各种考勤类型(正常、迟到、早退、旷工、请假、加班)
- 同一员工同一天只有一条记录
- 工作时长计算合理

### 任务1.7:生成请假初始化数据
**任务描述**: 生成至少50条请假记录的INSERT脚本
**输入**: spec.md中的请假数据规则
**输出**: database/mysql/07_insert_leave.sql
**验收标准**:
- 至少50条请假记录
- 覆盖各种请假类型(事假、病假、年假、婚假、产假、丧假)
- 覆盖各种审批状态(待审批、已同意、已拒绝)
- 请假时长计算正确
- 关联有效的员工和审批人

### 任务1.8:生成绩效初始化数据
**任务描述**: 生成至少100条绩效目标和50条绩效评估的INSERT脚本
**输入**: spec.md中的绩效数据规则
**输出**: database/mysql/08_insert_performance.sql
**验收标准**:
- 至少100条绩效目标记录
- 至少50条绩效评估记录
- 覆盖不同年度(2024、2025)
- 覆盖不同评估周期(年度、季度、月度)
- 覆盖不同绩效等级(S、A、B、C、D)
- 评分在0-100之间

### 任务1.9:生成薪资初始化数据
**任务描述**: 生成至少500条薪资发放记录的INSERT脚本
**输入**: spec.md中的薪资数据规则
**输出**: database/mysql/09_insert_salary.sql
**验收标准**:
- 至少500条薪资发放记录
- 覆盖最近12个月
- 应发工资=所有收入项之和
- 实发工资=应发工资-所有扣款项
- 薪资金额精确到分
- 包含完整的收入项和扣款项

### 任务1.10:生成培训初始化数据
**任务描述**: 生成至少10个培训课程和100条培训报名的INSERT脚本
**输入**: spec.md中的培训数据规则
**输出**: database/mysql/10_insert_training.sql
**验收标准**:
- 至少10个培训课程
- 至少100条培训报名记录
- 覆盖各种课程类型(新员工、技能、管理、安全)
- 覆盖各种审核状态(待审核、已通过、已拒绝)
- 已报名人数与实际报名记录一致

### 任务1.11:创建MySQL完整初始化脚本
**任务描述**: 整合所有MySQL脚本为一个完整的初始化脚本
**输入**: 任务1.1-1.10的所有脚本
**输出**: database/mysql/init.sql
**验收标准**:
- 按正确顺序执行所有脚本
- 包含事务控制
- 包含错误处理
- 包含执行日志输出

---

## 第二阶段:Hive数据仓库设计与实现

### 任务2.1:创建Hive建库脚本
**任务描述**: 创建Hive数据仓库创建脚本
**输入**: design.md中的Hive数据库配置
**输出**: database/hive/01_create_database.sql
**验收标准**:
- 数据库名为hr_datacenter_dw
- 包含数据库删除和重建逻辑
- 包含注释说明

### 任务2.2:创建Hive维度表脚本
**任务描述**: 创建4张维度表的DDL脚本
**输入**: design.md中的维度表设计
**输出**: database/hive/02_create_dim_tables.sql
**验收标准**:
- 包含dim_employee、dim_department、dim_date、dim_course共4张维度表
- 使用ORC存储格式
- 使用SNAPPY压缩
- 包含etl_time字段

### 任务2.3:创建Hive事实表脚本
**任务描述**: 创建4张事实表的DDL脚本
**输入**: design.md中的事实表设计
**输出**: database/hive/03_create_fact_tables.sql
**验收标准**:
- 包含fact_attendance、fact_salary、fact_performance、fact_training共4张事实表
- fact_attendance和fact_salary按年月分区
- fact_performance按年分区
- 使用ORC存储格式和SNAPPY压缩
- 包含员工维度信息(冗余设计)

### 任务2.4:创建Hive聚合表脚本
**任务描述**: 创建4张聚合表的DDL脚本
**输入**: design.md中的聚合表设计
**输出**: database/hive/04_create_agg_tables.sql
**验收标准**:
- 包含agg_dept_monthly_attendance、agg_dept_monthly_salary、agg_employee_yearly_performance、agg_course_statistics共4张聚合表
- 使用ORC存储格式和SNAPPY压缩
- 包含预聚合的统计字段

### 任务2.5:创建Hive维度数据加载脚本
**任务描述**: 创建从MySQL加载维度数据的脚本
**输入**: MySQL维度数据
**输出**: database/hive/05_load_dim_data.sql
**验收标准**:
- 使用INSERT OVERWRITE语句
- 从MySQL加载员工、部门、课程等维度数据
- 包含etl_time时间戳
- 包含数据清洗逻辑

### 任务2.6:创建Hive事实数据加载脚本
**任务描述**: 创建从MySQL加载事实数据的脚本
**输入**: MySQL事实数据
**输出**: database/hive/06_load_fact_data.sql
**验收标准**:
- 使用INSERT OVERWRITE语句
- 从MySQL加载考勤、薪资、绩效、培训等事实数据
- 按分区加载数据
- 包含etl_time时间戳

### 任务2.7:创建Hive聚合数据生成脚本
**任务描述**: 创建生成聚合数据的脚本
**输入**: Hive维度表和事实表数据
**输出**: database/hive/07_generate_agg_data.sql
**验收标准**:
- 使用INSERT OVERWRITE语句
- 从事实表聚合生成汇总数据
- 包含部门月度考勤汇总
- 包含部门月度薪资汇总
- 包含员工年度绩效汇总
- 包含培训课程统计

### 任务2.8:创建Hive完整初始化脚本
**任务描述**: 整合所有Hive脚本为一个完整的初始化脚本
**输入**: 任务2.1-2.7的所有脚本
**输出**: database/hive/init.sql
**验收标准**:
- 按正确顺序执行所有脚本
- 包含执行日志输出
- 包含注释说明

---

## 第三阶段:数据验证与优化

### 任务3.1:创建数据验证脚本
**任务描述**: 创建数据完整性和一致性验证脚本
**输入**: MySQL和Hive数据库
**输出**: database/verify_data.sql
**验收标准**:
- 验证MySQL数据量(用户≥2、员工≥50、考勤≥1000等)
- 验证外键完整性
- 验证薪资计算准确性
- 验证Hive分区数据
- 输出验证报告

### 任务3.2:创建性能测试脚本
**任务描述**: 创建数据库查询性能测试脚本
**输入**: MySQL和Hive数据库
**输出**: database/performance_test.sql
**验收标准**:
- 测试员工列表查询性能(<1秒)
- 测试考勤统计查询性能(<3秒)
- 测试薪资汇总查询性能(<3秒)
- 测试Hive分析查询性能
- 输出性能报告

### 任务3.3:创建数据库文档
**任务描述**: 创建数据库设计说明文档
**输入**: 所有SQL脚本
**输出**: database/README.md
**验收标准**:
- 包含数据库架构说明
- 包含表结构说明
- 包含索引设计说明
- 包含初始化步骤说明
- 包含使用示例

---

## 任务执行顺序

**第一阶段(MySQL)**: 任务1.1 → 任务1.2 → 任务1.3 → 任务1.4 → 任务1.5 → 任务1.6 → 任务1.7 → 任务1.8 → 任务1.9 → 任务1.10 → 任务1.11

**第二阶段(Hive)**: 任务2.1 → 任务2.2 → 任务2.3 → 任务2.4 → 任务2.5 → 任务2.6 → 任务2.7 → 任务2.8

**第三阶段(验证)**: 任务3.1 → 任务3.2 → 任务3.3

**总体顺序**: 第一阶段 → 第二阶段 → 第三阶段

---

## 预计工作量

- **MySQL数据库设计**: 约2小时
- **Hive数据仓库设计**: 约1.5小时
- **初始化数据生成**: 约3小时
- **数据验证与优化**: 约1小时
- **文档编写**: 约0.5小时

**总计**: 约8小时

---

## 注意事项

1. 所有SQL脚本必须包含详细注释
2. 所有表和字段必须有COMMENT说明
3. 初始化数据必须符合业务规则
4. 薪资计算必须精确到分
5. 外键关联必须保证数据完整性
6. Hive表必须使用ORC格式和SNAPPY压缩
7. 分区表必须按设计要求分区
8. 所有脚本必须可重复执行(幂等性)
