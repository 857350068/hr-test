# Hive数据仓库技术文档

## 项目信息

- **项目名称**: 人力资源数据中心 (HrDataCenter)
- **数据库名称**: hr_datacenter_dw
- **Hive版本**: Hive 3.1.3+
- **Hadoop版本**: Hadoop 3.x
- **数据格式**: ORC
- **压缩格式**: SNAPPY
- **文档版本**: v2.0
- **更新日期**: 2026-04-07

## 数据仓库概述

人力资源数据中心Hive数据仓库用于存储和分析大规模的人力资源数据。采用星型模型设计，包含维度表、事实表和聚合表，支持复杂的数据分析和报表查询。

## 数据仓库架构

### 架构层次

```
hr_datacenter_dw (数据仓库)
├── 维度表 (Dimension Tables)
│   ├── dim_employee (员工维度表)
│   ├── dim_department (部门维度表)
│   ├── dim_date (日期维度表)
│   └── dim_course (课程维度表)
├── 事实表 (Fact Tables)
│   ├── fact_attendance (考勤事实表)
│   ├── fact_salary (薪资事实表)
│   ├── fact_performance (绩效事实表)
│   └── fact_training (培训事实表)
└── 聚合表 (Aggregate Tables)
    ├── agg_dept_monthly_attendance (部门月度考勤汇总表)
    ├── agg_dept_monthly_salary (部门月度薪资汇总表)
    ├── agg_employee_yearly_performance (员工年度绩效汇总表)
    ├── agg_course_statistics (培训课程统计表)
    ├── agg_employee_turnover (员工流失分析表)
    └── agg_labor_cost (人力成本分析表)
```

## 详细表结构

### 维度表 (Dimension Tables)

#### 1. dim_employee (员工维度表)

**功能说明**: 存储员工维度信息，用于与其他事实表关联

**表结构**:

| 字段名 | 类型 | 说明 |
|--------|------|------|
| emp_id | BIGINT | 员工ID |
| emp_no | STRING | 员工编号 |
| emp_name | STRING | 员工姓名 |
| gender | INT | 性别(0-女 1-男) |
| birth_date | STRING | 出生日期 |
| age | INT | 年龄 |
| id_card | STRING | 身份证号 |
| phone | STRING | 手机号码 |
| email | STRING | 邮箱 |
| department | STRING | 部门 |
| position | STRING | 职位 |
| salary | DECIMAL(10,2) | 薪资 |
| hire_date | STRING | 入职日期 |
| resign_date | STRING | 离职日期 |
| work_years | INT | 工作年限 |
| status | INT | 状态(0-离职 1-在职 2-试用) |
| education | STRING | 学历 |
| etl_time | TIMESTAMP | ETL时间 |

**分区**: year (年度分区)

**存储格式**: ORC + SNAPPY压缩

**用途**: 与所有事实表关联，提供员工基础信息

#### 2. dim_department (部门维度表)

**功能说明**: 存储部门维度信息

**表结构**:

| 字段名 | 类型 | 说明 |
|--------|------|------|
| dept_id | BIGINT | 部门ID |
| dept_name | STRING | 部门名称 |
| dept_code | STRING | 部门编码 |
| parent_dept_id | BIGINT | 上级部门ID |
| dept_level | INT | 部门层级 |
| manager_name | STRING | 部门负责人 |
| employee_count | INT | 员工数量 |
| avg_salary | DECIMAL(10,2) | 平均薪资 |
| etl_time | TIMESTAMP | ETL时间 |

**存储格式**: ORC + SNAPPY压缩

**用途**: 用于部门级别的分析和报表

#### 3. dim_date (日期维度表)

**功能说明**: 存储日期维度信息，支持时间序列分析

**表结构**:

| 字段名 | 类型 | 说明 |
|--------|------|------|
| date_id | STRING | 日期ID(YYYYMMDD) |
| date_value | STRING | 日期值 |
| year | INT | 年份 |
| month | INT | 月份 |
| day | INT | 日期 |
| quarter | INT | 季度 |
| week | INT | 周数 |
| day_of_week | INT | 星期几(1-7) |
| is_weekend | BOOLEAN | 是否周末 |
| is_holiday | BOOLEAN | 是否节假日 |
| month_name | STRING | 月份名称 |
| quarter_name | STRING | 季度名称 |
| etl_time | TIMESTAMP | ETL时间 |

**分区**: year (年度分区)

**存储格式**: ORC + SNAPPY压缩

**用途**: 用于时间维度的分析和聚合

#### 4. dim_course (课程维度表)

**功能说明**: 存储培训课程维度信息

**表结构**:

| 字段名 | 类型 | 说明 |
|--------|------|------|
| course_id | BIGINT | 课程ID |
| course_name | STRING | 课程名称 |
| course_type | INT | 课程类型 |
| course_type_name | STRING | 课程类型名称 |
| course_description | STRING | 课程描述 |
| instructor | STRING | 培训讲师 |
| duration | INT | 培训时长(小时) |
| location | STRING | 培训地点 |
| capacity | INT | 培训名额 |
| enrolled_count | INT | 已报名人数 |
| completion_rate | DECIMAL(5,2) | 完成率 |
| avg_score | DECIMAL(5,2) | 平均分数 |
| etl_time | TIMESTAMP | ETL时间 |

**存储格式**: ORC + SNAPPY压缩

**用途**: 用于培训相关的分析和报表

### 事实表 (Fact Tables)

#### 1. fact_attendance (考勤事实表)

**功能说明**: 存储员工考勤事实数据

**表结构**:

| 字段名 | 类型 | 说明 |
|--------|------|------|
| attendance_id | BIGINT | 考勤ID |
| emp_id | BIGINT | 员工ID |
| emp_no | STRING | 员工编号 |
| emp_name | STRING | 员工姓名 |
| department | STRING | 部门 |
| position | STRING | 职位 |
| attendance_date | STRING | 考勤日期 |
| clock_in_time | STRING | 上班打卡时间 |
| clock_out_time | STRING | 下班打卡时间 |
| attendance_type | INT | 考勤类型 |
| attendance_type_name | STRING | 考勤类型名称 |
| attendance_status | INT | 考勤状态 |
| work_duration | INT | 工作时长(分钟) |
| year | INT | 年 |
| month | INT | 月 |
| day | INT | 日 |
| etl_time | TIMESTAMP | ETL时间 |

**分区**: year_month (年月分区 YYYY-MM)

**存储格式**: ORC + SNAPPY压缩

**粒度**: 每日每员工一条记录

**用途**: 考勤分析、出勤率统计、工时分析

#### 2. fact_salary (薪资事实表)

**功能说明**: 存储员工薪资发放事实数据

**表结构**:

| 字段名 | 类型 | 说明 |
|--------|------|------|
| payment_id | BIGINT | 发放ID |
| emp_id | BIGINT | 员工ID |
| emp_no | STRING | 员工编号 |
| emp_name | STRING | 员工姓名 |
| department | STRING | 部门 |
| position | STRING | 职位 |
| year | INT | 发放年度 |
| month | INT | 发放月份 |
| basic_salary | DECIMAL(10,2) | 基本工资 |
| performance_salary | DECIMAL(10,2) | 绩效工资 |
| position_allowance | DECIMAL(10,2) | 岗位津贴 |
| transport_allowance | DECIMAL(10,2) | 交通补贴 |
| communication_allowance | DECIMAL(10,2) | 通讯补贴 |
| meal_allowance | DECIMAL(10,2) | 餐补 |
| other_allowance | DECIMAL(10,2) | 其他补贴 |
| overtime_pay | DECIMAL(10,2) | 加班费 |
| total_gross_salary | DECIMAL(10,2) | 应发工资总额 |
| social_insurance | DECIMAL(10,2) | 社保个人部分 |
| housing_fund | DECIMAL(10,2) | 公积金个人部分 |
| income_tax | DECIMAL(10,2) | 个人所得税 |
| other_deduction | DECIMAL(10,2) | 其他扣款 |
| total_net_salary | DECIMAL(10,2) | 实发工资总额 |
| payment_status | INT | 发放状态 |
| payment_date | STRING | 发放时间 |
| etl_time | TIMESTAMP | ETL时间 |

**分区**: year_month (年月分区 YYYY-MM)

**存储格式**: ORC + SNAPPY压缩

**粒度**: 每月每员工一条记录

**用途**: 薪资分析、成本核算、薪酬结构分析

#### 3. fact_performance (绩效事实表)

**功能说明**: 存储员工绩效评估事实数据

**表结构**:

| 字段名 | 类型 | 说明 |
|--------|------|------|
| evaluation_id | BIGINT | 评估ID |
| emp_id | BIGINT | 员工ID |
| emp_no | STRING | 员工编号 |
| emp_name | STRING | 员工姓名 |
| department | STRING | 部门 |
| position | STRING | 职位 |
| year | INT | 评估年度 |
| period_type | INT | 评估周期 |
| period_type_name | STRING | 评估周期名称 |
| quarter | INT | 季度 |
| month | INT | 月份 |
| self_score | DECIMAL(5,2) | 自评分 |
| supervisor_score | DECIMAL(5,2) | 上级评分 |
| final_score | DECIMAL(5,2) | 综合评分 |
| performance_level | STRING | 绩效等级 |
| performance_level_name | STRING | 绩效等级名称 |
| improvement_plan | STRING | 改进建议 |
| interview_date | STRING | 面谈时间 |
| evaluation_status | INT | 评估状态 |
| evaluation_status_name | STRING | 评估状态名称 |
| etl_time | TIMESTAMP | ETL时间 |

**分区**: year (年度分区)

**存储格式**: ORC + SNAPPY压缩

**粒度**: 每次评估一条记录

**用途**: 绩效分析、人才评估、绩效趋势分析

#### 4. fact_training (培训事实表)

**功能说明**: 存储员工培训事实数据

**表结构**:

| 字段名 | 类型 | 说明 |
|--------|------|------|
| enrollment_id | BIGINT | 报名ID |
| course_id | BIGINT | 课程ID |
| course_name | STRING | 课程名称 |
| course_type | INT | 课程类型 |
| course_type_name | STRING | 课程类型名称 |
| emp_id | BIGINT | 员工ID |
| emp_no | STRING | 员工编号 |
| emp_name | STRING | 员工姓名 |
| department | STRING | 部门 |
| position | STRING | 职位 |
| enrollment_time | STRING | 报名时间 |
| approval_status | INT | 审核状态 |
| approval_status_name | STRING | 审核状态名称 |
| approver_id | BIGINT | 审核人ID |
| attendance_status | INT | 出勤状态 |
| attendance_status_name | STRING | 出勤状态名称 |
| score | INT | 培训成绩 |
| score_level | STRING | 成绩等级 |
| feedback | STRING | 培训反馈 |
| year | INT | 年份 |
| month | INT | 月份 |
| etl_time | TIMESTAMP | ETL时间 |

**分区**: year_month (年月分区 YYYY-MM)

**存储格式**: ORC + SNAPPY压缩

**粒度**: 每次培训报名一条记录

**用途**: 培训分析、培训效果评估、培训需求分析

### 聚合表 (Aggregate Tables)

#### 1. agg_dept_monthly_attendance (部门月度考勤汇总表)

**功能说明**: 按部门和月度聚合考勤数据

**表结构**:

| 字段名 | 类型 | 说明 |
|--------|------|------|
| department | STRING | 部门 |
| year_month | STRING | 年月 |
| year | INT | 年份 |
| month | INT | 月份 |
| total_employees | INT | 总员工数 |
| total_days | INT | 总工作天数 |
| total_attendance | INT | 总出勤天数 |
| attendance_rate | DECIMAL(5,2) | 出勤率 |
| normal_count | INT | 正常次数 |
| late_count | INT | 迟到次数 |
| early_leave_count | INT | 早退次数 |
| absence_count | INT | 旷工次数 |
| leave_count | INT | 请假次数 |
| overtime_count | INT | 加班次数 |
| avg_work_duration | DECIMAL(10,2) | 平均工作时长 |
| etl_time | TIMESTAMP | ETL时间 |

**分区**: year (年度分区)

**存储格式**: ORC + SNAPPY压缩

**更新频率**: 每日更新

#### 2. agg_dept_monthly_salary (部门月度薪资汇总表)

**功能说明**: 按部门和月度聚合薪资数据

**表结构**:

| 字段名 | 类型 | 说明 |
|--------|------|------|
| department | STRING | 部门 |
| year_month | STRING | 年月 |
| year | INT | 年份 |
| month | INT | 月份 |
| employee_count | INT | 员工人数 |
| total_basic_salary | DECIMAL(15,2) | 基本工资总额 |
| total_performance_salary | DECIMAL(15,2) | 绩效工资总额 |
| total_allowance | DECIMAL(15,2) | 津贴总额 |
| total_overtime_pay | DECIMAL(15,2) | 加班费总额 |
| total_gross_salary | DECIMAL(15,2) | 应发工资总额 |
| total_deduction | DECIMAL(15,2) | 扣款总额 |
| total_net_salary | DECIMAL(15,2) | 实发工资总额 |
| avg_basic_salary | DECIMAL(10,2) | 平均基本工资 |
| avg_net_salary | DECIMAL(10,2) | 平均实发工资 |
| max_salary | DECIMAL(10,2) | 最高薪资 |
| min_salary | DECIMAL(10,2) | 最低薪资 |
| payment_count | INT | 已发放人数 |
| etl_time | TIMESTAMP | ETL时间 |

**分区**: year (年度分区)

**存储格式**: ORC + SNAPPY压缩

**更新频率**: 每月更新

#### 3. agg_employee_yearly_performance (员工年度绩效汇总表)

**功能说明**: 按员工和年度聚合绩效数据

**表结构**:

| 字段名 | 类型 | 说明 |
|--------|------|------|
| emp_id | BIGINT | 员工ID |
| emp_no | STRING | 员工编号 |
| emp_name | STRING | 员工姓名 |
| department | STRING | 部门 |
| position | STRING | 职位 |
| year | INT | 年份 |
| total_evaluations | INT | 总评估次数 |
| avg_self_score | DECIMAL(5,2) | 平均自评分 |
| avg_supervisor_score | DECIMAL(5,2) | 平均上级评分 |
| avg_final_score | DECIMAL(5,2) | 平均综合分数 |
| s_level_count | INT | S级次数 |
| a_level_count | INT | A级次数 |
| b_level_count | INT | B级次数 |
| c_level_count | INT | C级次数 |
| d_level_count | INT | D级次数 |
| overall_level | STRING | 总体等级 |
| score_trend | STRING | 分数趋势 |
| improvement_count | INT | 改进计划数量 |
| etl_time | TIMESTAMP | ETL时间 |

**分区**: year (年度分区)

**存储格式**: ORC + SNAPPY压缩

**更新频率**: 每季度更新

#### 4. agg_course_statistics (培训课程统计表)

**功能说明**: 按课程聚合培训统计信息

**表结构**:

| 字段名 | 类型 | 说明 |
|--------|------|------|
| course_id | BIGINT | 课程ID |
| course_name | STRING | 课程名称 |
| course_type | INT | 课程类型 |
| course_type_name | STRING | 课程类型名称 |
| instructor | STRING | 培训讲师 |
| duration | INT | 培训时长 |
| location | STRING | 培训地点 |
| capacity | INT | 培训名额 |
| total_enrollments | INT | 总报名人数 |
| approved_count | INT | 已通过审核人数 |
| completed_count | INT | 已完成人数 |
| completion_rate | DECIMAL(5,2) | 完成率 |
| attendance_rate | DECIMAL(5,2) | 出勤率 |
| avg_score | DECIMAL(5,2) | 平均分数 |
| satisfaction_rate | DECIMAL(5,2) | 满意度 |
| excellent_rate | DECIMAL(5,2) | 优秀率(80分以上) |
| good_rate | DECIMAL(5,2) | 良好率(60-79分) |
| pass_rate | DECIMAL(5,2) | 及格率(60分以上) |
| fail_rate | DECIMAL(5,2) | 不及格率(60分以下) |
| first_course_date | STRING | 首次开课日期 |
| last_course_date | STRING | 最近开课日期 |
| total_feedback | INT | 总反馈数量 |
| etl_time | TIMESTAMP | ETL时间 |

**存储格式**: ORC + SNAPPY压缩

**更新频率**: 每周更新

#### 5. agg_employee_turnover (员工流失分析表)

**功能说明**: 按部门和月度分析员工流失情况

**表结构**:

| 字段名 | 类型 | 说明 |
|--------|------|------|
| department | STRING | 部门 |
| year_month | STRING | 年月 |
| year | INT | 年份 |
| month | INT | 月份 |
| beginning_count | INT | 期初人数 |
| new_hire_count | INT | 新入职人数 |
| resign_count | INT | 离职人数 |
| turnover_rate | DECIMAL(5,2) | 流失率 |
| avg_tenure | DECIMAL(10,2) | 平均在职时长(月) |
| avg_salary_resigned | DECIMAL(10,2) | 离职员工平均薪资 |
| avg_salary_current | DECIMAL(10,2) | 在职员工平均薪资 |
| high_performer_resign_count | INT | 高绩效离职人数 |
| high_performer_resign_rate | DECIMAL(5,2) | 高绩效流失率 |
| new_hire_avg_age | DECIMAL(5,2) | 新员工平均年龄 |
| resign_avg_age | DECIMAL(5,2) | 离职员工平均年龄 |
| etl_time | TIMESTAMP | ETL时间 |

**分区**: year (年度分区)

**存储格式**: ORC + SNAPPY压缩

**更新频率**: 每月更新

#### 6. agg_labor_cost (人力成本分析表)

**功能说明**: 按部门和月度分析人力成本

**表结构**:

| 字段名 | 类型 | 说明 |
|--------|------|------|
| department | STRING | 部门 |
| year_month | STRING | 年月 |
| year | INT | 年份 |
| month | INT | 月份 |
| employee_count | INT | 员工人数 |
| total_labor_cost | DECIMAL(18,2) | 总人力成本 |
| salary_cost | DECIMAL(18,2) | 薪资成本 |
| allowance_cost | DECIMAL(18,2) | 津贴成本 |
| benefit_cost | DECIMAL(18,2) | 福利成本 |
| training_cost | DECIMAL(18,2) | 培训成本 |
| recruitment_cost | DECIMAL(18,2) | 招聘成本 |
| avg_cost_per_employee | DECIMAL(12,2) | 人均成本 |
| cost_growth_rate | DECIMAL(5,2) | 成本增长率 |
| cost_per_revenue | DECIMAL(5,2) | 成本占收入比 |
| overtime_cost_ratio | DECIMAL(5,2) | 加班费占比 |
| etl_time | TIMESTAMP | ETL时间 |

**分区**: year (年度分区)

**存储格式**: ORC + SNAPPY压缩

**更新频率**: 每月更新

## ETL流程

### 数据同步流程

```
MySQL (业务库)
    ↓ Sqoop / DataX
Hive ODS层 (原始数据)
    ↓ 清洗转换
Hive DW层 (维度表、事实表)
    ↓ 聚合计算
Hive ADS层 (聚合表)
```

### 同步频率

- **维度表**: 每天同步一次
- **事实表**: 每天同步一次
- **聚合表**: 根据业务需求，每日/每周/每月更新

### 数据质量检查

1. **完整性检查**: 确保所有必需字段都有值
2. **一致性检查**: 确保关联键匹配
3. **准确性检查**: 确保数据类型和格式正确
4. **及时性检查**: 确保数据及时更新

## 初始化脚本

数据仓库初始化脚本位于: `database/hive/init.sql`

该脚本包含:
1. 创建数据库
2. 创建所有维度表
3. 创建所有事实表
4. 创建所有聚合表
5. 配置ORC存储和SNAPPY压缩

### 执行初始化

```bash
hive -f database/hive/init.sql
```

## 常用查询示例

### 1. 查询部门月度出勤率

```sql
SELECT
    department,
    year_month,
    attendance_rate,
    late_count,
    early_leave_count
FROM hr_datacenter_dw.agg_dept_monthly_attendance
WHERE year >= 2024
ORDER BY year_month DESC, department;
```

### 2. 查询员工绩效趋势

```sql
SELECT
    emp_name,
    department,
    year,
    avg_final_score,
    overall_level,
    score_trend
FROM hr_datacenter_dw.agg_employee_yearly_performance
WHERE department = '技术部'
ORDER BY year DESC, avg_final_score DESC;
```

### 3. 查询培训课程效果

```sql
SELECT
    course_name,
    course_type_name,
    total_enrollments,
    completion_rate,
    attendance_rate,
    avg_score,
    excellent_rate
FROM hr_datacenter_dw.agg_course_statistics
WHERE completion_rate > 0.8
ORDER BY avg_score DESC;
```

### 4. 查询员工流失情况

```sql
SELECT
    department,
    year_month,
    turnover_rate,
    avg_tenure,
    high_performer_resign_rate
FROM hr_datacenter_dw.agg_employee_turnover
WHERE year >= 2024
ORDER BY year_month DESC, turnover_rate DESC;
```

### 5. 查询人力成本对比

```sql
SELECT
    department,
    year_month,
    total_labor_cost,
    avg_cost_per_employee,
    cost_growth_rate,
    overtime_cost_ratio
FROM hr_datacenter_dw.agg_labor_cost
WHERE year >= 2024
ORDER BY year_month DESC, total_labor_cost DESC;
```

## 性能优化

### 1. 分区优化

- 合理设置分区字段
- 避免过多小文件
- 定期合并小文件

### 2. 存储优化

- 使用ORC列式存储
- 启用SNAPPY压缩
- 合理设置压缩级别

### 3. 查询优化

- 使用分区裁剪
- 避免全表扫描
- 合理使用缓存

### 4. 资源配置

```xml
<property>
  <name>hive.exec.reducers.bytes.per.reducer</name>
  <value>256000000</value>
</property>

<property>
  <name>hive.exec.parallel</name>
  <value>true</value>
</property>

<property>
  <name>hive.exec.parallel.thread.number</name>
  <value>8</value>
</property>
```

## 监控指标

### 1. 数据质量

- 数据完整性
- 数据准确性
- 数据及时性

### 2. 性能指标

- 查询响应时间
- ETL执行时间
- 数据同步延迟

### 3. 资源使用

- CPU使用率
- 内存使用率
- 磁盘使用率
- 网络流量

## 备份与恢复

### 备份策略

1. **元数据备份**: 定期备份Hive元数据
2. **数据备份**: 使用HDFS快照或DistCp
3. **配置备份**: 备份Hive配置文件

### 恢复流程

1. 恢复元数据
2. 恢复数据文件
3. 验证数据完整性

## 安全建议

1. **权限控制**: 使用Hive授权和Kerberos认证
2. **数据加密**: 敏感数据加密存储
3. **审计日志**: 启用Hive审计日志
4. **网络安全**: 使用SSL/TLS加密传输

## 常见问题

### Q: 如何处理小文件问题?

A: 使用Hive的CONCATENATE命令或定期运行合并任务。

### Q: 如何优化查询性能?

A: 合理使用分区、索引、缓存，优化SQL语句。

### Q: 如何处理数据倾斜?

A: 使用Skew Join优化、增加Reducer数量、重新设计数据模型。

## 版本历史

- v2.0 (2026-04-07): 统一初始化脚本，完善表结构和聚合表
- v1.0 (2026-03-31): 初始版本

## 联系方式

如有问题，请联系数据仓库管理员或数据团队。
