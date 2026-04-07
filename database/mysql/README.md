# MySQL数据库技术文档

## 项目信息

- **项目名称**: 人力资源数据中心 (HrDataCenter)
- **数据库名称**: hr_datacenter
- **数据库版本**: MySQL 8.0+
- **字符集**: utf8mb4
- **排序规则**: utf8mb4_unicode_ci
- **文档版本**: v2.0
- **更新日期**: 2026-04-07

## 数据库概述

人力资源数据中心MySQL数据库用于存储业务系统的核心数据，包括员工信息、考勤记录、薪资发放、绩效评估、培训管理等。数据库采用规范化设计，确保数据的一致性和完整性。

## 数据库架构

### 表结构概览

| 序号 | 表名 | 说明 | 行数预估 |
|------|------|------|----------|
| 1 | sys_user | 用户表 | 100+ |
| 2 | sys_role | 角色表 | 10 |
| 3 | employee | 员工表 | 10万+ |
| 4 | attendance | 考勤记录表 | 365万+ |
| 5 | leave | 请假记录表 | 50万+ |
| 6 | performance_goal | 绩效目标表 | 20万+ |
| 7 | performance_evaluation | 绩效评估表 | 20万+ |
| 8 | salary_payment | 薪资发放表 | 120万+ |
| 9 | salary_adjustment | 薪资调整表 | 10万+ |
| 10 | training_course | 培训课程表 | 1000+ |
| 11 | training_enrollment | 培训报名表 | 50万+ |
| 12 | data_category | 数据分类表 | 10 |
| 13 | sys_operation_log | 操作日志表 | 100万+ |
| 14 | message | 消息表 | 10万+ |

## 详细表结构

### 1. sys_user (用户表)

**功能说明**: 存储系统用户信息，用于登录认证和权限管理

**表结构**:

| 字段名 | 类型 | 长度 | 允许空 | 默认值 | 说明 |
|--------|------|------|--------|--------|------|
| user_id | BIGINT | - | NO | AUTO_INCREMENT | 用户ID (主键) |
| username | VARCHAR | 50 | NO | - | 用户名 (唯一) |
| password | VARCHAR | 100 | NO | - | 密码 (BCrypt加密) |
| real_name | VARCHAR | 50 | NO | - | 真实姓名 |
| dept_id | BIGINT | - | YES | - | 部门ID |
| phone | VARCHAR | 20 | YES | - | 手机号码 |
| email | VARCHAR | 100 | YES | - | 邮箱 |
| role_id | BIGINT | - | YES | - | 角色ID |
| status | TINYINT | - | NO | 1 | 状态 (0-禁用 1-启用) |
| avatar | VARCHAR | 255 | YES | - | 头像URL |
| last_login_time | DATETIME | - | YES | - | 最后登录时间 |
| last_login_ip | VARCHAR | 50 | YES | - | 最后登录IP |
| create_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 更新时间 (自动更新) |
| create_by | VARCHAR | 50 | YES | - | 创建人 |
| update_by | VARCHAR | 50 | YES | - | 更新人 |
| remark | VARCHAR | 500 | YES | - | 备注 |
| deleted | TINYINT | - | NO | 0 | 删除标记 (0-未删除 1-已删除) |

**索引**:
- PRIMARY KEY: user_id
- UNIQUE KEY: username
- INDEX: idx_dept_id
- INDEX: idx_role_id
- INDEX: idx_status

### 2. sys_role (角色表)

**功能说明**: 存储系统角色信息

**表结构**:

| 字段名 | 类型 | 长度 | 允许空 | 默认值 | 说明 |
|--------|------|------|--------|--------|------|
| role_id | BIGINT | - | NO | AUTO_INCREMENT | 角色ID (主键) |
| role_name | VARCHAR | 50 | NO | - | 角色名称 |
| role_code | VARCHAR | 50 | NO | - | 角色编码 (唯一) |
| role_desc | VARCHAR | 200 | YES | - | 角色描述 |
| status | TINYINT | - | NO | 1 | 状态 (0-禁用 1-启用) |
| create_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 更新时间 (自动更新) |
| create_by | VARCHAR | 50 | YES | - | 创建人 |
| update_by | VARCHAR | 50 | YES | - | 更新人 |
| remark | VARCHAR | 500 | YES | - | 备注 |

**索引**:
- PRIMARY KEY: role_id
- UNIQUE KEY: role_code
- INDEX: idx_status

### 3. employee (员工表)

**功能说明**: 存储员工基本信息、工作信息、状态信息

**表结构**:

| 字段名 | 类型 | 长度 | 允许空 | 默认值 | 说明 |
|--------|------|------|--------|--------|------|
| emp_id | BIGINT | - | NO | AUTO_INCREMENT | 员工ID (主键) |
| emp_no | VARCHAR | 20 | NO | - | 员工编号 (唯一) |
| emp_name | VARCHAR | 50 | NO | - | 员工姓名 |
| gender | TINYINT | - | NO | - | 性别 (0-女 1-男) |
| birth_date | DATE | - | NO | - | 出生日期 |
| id_card | VARCHAR | 18 | NO | - | 身份证号 |
| phone | VARCHAR | 20 | NO | - | 手机号码 |
| email | VARCHAR | 100 | YES | - | 邮箱 |
| department | VARCHAR | 50 | NO | - | 部门 |
| position | VARCHAR | 50 | NO | - | 职位 |
| position_id | BIGINT | - | YES | - | 职位ID |
| job_level | VARCHAR | 20 | YES | - | 职级 |
| salary | DECIMAL | 10,2 | NO | - | 薪资 |
| hire_date | DATE | - | NO | - | 入职日期 |
| leave_date | DATE | - | YES | - | 离职日期 |
| status | TINYINT | - | NO | 1 | 状态 (0-离职 1-在职 2-试用) |
| education | VARCHAR | 20 | YES | - | 学历 |
| school | VARCHAR | 100 | YES | - | 毕业院校 |
| major | VARCHAR | 100 | YES | - | 专业 |
| work_years | INT | - | NO | 0 | 工作年限 |
| address | VARCHAR | 200 | YES | - | 居住地址 |
| emergency_contact | VARCHAR | 50 | YES | - | 紧急联系人 |
| emergency_phone | VARCHAR | 20 | YES | - | 紧急联系电话 |
| create_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 更新时间 (自动更新) |
| create_by | VARCHAR | 50 | YES | - | 创建人 |
| update_by | VARCHAR | 50 | YES | - | 更新人 |
| remark | VARCHAR | 500 | YES | - | 备注 |
| deleted | TINYINT | - | NO | 0 | 删除标记 (0-未删除 1-已删除) |

**索引**:
- PRIMARY KEY: emp_id
- UNIQUE KEY: emp_no
- INDEX: idx_department
- INDEX: idx_position_id
- INDEX: idx_status
- INDEX: idx_hire_date
- INDEX: idx_emp_name

### 4. attendance (考勤记录表)

**功能说明**: 存储员工每日考勤打卡记录

**表结构**:

| 字段名 | 类型 | 长度 | 允许空 | 默认值 | 说明 |
|--------|------|------|--------|--------|------|
| attendance_id | BIGINT | - | NO | AUTO_INCREMENT | 考勤ID (主键) |
| emp_id | BIGINT | - | NO | - | 员工ID |
| attendance_date | DATE | - | NO | - | 考勤日期 |
| clock_in_time | TIME | - | YES | - | 上班打卡时间 |
| clock_out_time | TIME | - | YES | - | 下班打卡时间 |
| attendance_type | TINYINT | - | NO | - | 考勤类型 (0-正常 1-迟到 2-早退 3-旷工 4-请假 5-加班) |
| attendance_status | TINYINT | - | NO | - | 考勤状态 (0-未打卡 1-已打卡 2-请假 3-加班) |
| work_duration | INT | - | YES | - | 工作时长(分钟) |
| remark | VARCHAR | 500 | YES | - | 备注 |
| create_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 更新时间 (自动更新) |
| deleted | TINYINT | - | NO | 0 | 删除标记 (0-未删除 1-已删除) |

**索引**:
- PRIMARY KEY: attendance_id
- UNIQUE KEY: uk_emp_date (emp_id, attendance_date)
- INDEX: idx_attendance_date
- INDEX: idx_emp_date
- INDEX: idx_attendance_type
- INDEX: idx_clock_in_time

### 5. leave (请假记录表)

**功能说明**: 存储员工请假申请和审批记录

**表结构**:

| 字段名 | 类型 | 长度 | 允许空 | 默认值 | 说明 |
|--------|------|------|--------|--------|------|
| leave_id | BIGINT | - | NO | AUTO_INCREMENT | 请假ID (主键) |
| emp_id | BIGINT | - | NO | - | 员工ID |
| leave_type | TINYINT | - | NO | - | 请假类型 (0-事假 1-病假 2-年假 3-婚假 4-产假 5-丧假 6-其他) |
| start_time | DATETIME | - | NO | - | 请假开始时间 |
| end_time | DATETIME | - | NO | - | 请假结束时间 |
| leave_duration | INT | - | NO | - | 请假时长(小时) |
| reason | TEXT | - | NO | - | 请假原因 |
| approver_id | BIGINT | - | NO | - | 审批人ID |
| approval_status | TINYINT | - | NO | 0 | 审批状态 (0-待审批 1-已同意 2-已拒绝 3-已撤回) |
| approval_comment | TEXT | - | YES | - | 审批意见 |
| approval_time | DATETIME | - | YES | - | 审批时间 |
| attachment | VARCHAR | 500 | YES | - | 附件路径 |
| create_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 更新时间 (自动更新) |
| deleted | TINYINT | - | NO | 0 | 删除标记 (0-未删除 1-已删除) |

**索引**:
- PRIMARY KEY: leave_id
- INDEX: idx_emp_id
- INDEX: idx_approver_id
- INDEX: idx_start_time
- INDEX: idx_end_time
- INDEX: idx_approval_status
- INDEX: idx_approval_time

### 6. performance_goal (绩效目标表)

**功能说明**: 存储员工绩效目标设定

**表结构**:

| 字段名 | 类型 | 长度 | 允许空 | 默认值 | 说明 |
|--------|------|------|--------|--------|------|
| goal_id | BIGINT | - | NO | AUTO_INCREMENT | 目标ID (主键) |
| emp_id | BIGINT | - | NO | - | 员工ID |
| year | INT | - | NO | - | 评估年度 |
| period_type | TINYINT | - | NO | - | 评估周期 (1-年度 2-季度 3-月度) |
| goal_description | VARCHAR | 500 | NO | - | 目标描述 |
| weight | INT | - | NO | - | 权重(百分比) |
| completion_standard | VARCHAR | 500 | NO | - | 完成标准 |
| goal_status | TINYINT | - | NO | 0 | 目标状态 (0-草稿 1-进行中 2-已完成) |
| create_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 更新时间 (自动更新) |
| deleted | TINYINT | - | NO | 0 | 删除标记 (0-未删除 1-已删除) |

**索引**:
- PRIMARY KEY: goal_id
- INDEX: idx_emp_year_period (emp_id, year, period_type)
- INDEX: idx_goal_status
- INDEX: idx_year
- INDEX: idx_period_type

### 7. performance_evaluation (绩效评估表)

**功能说明**: 存储员工绩效评估结果

**表结构**:

| 字段名 | 类型 | 长度 | 允许空 | 默认值 | 说明 |
|--------|------|------|--------|--------|------|
| evaluation_id | BIGINT | - | NO | AUTO_INCREMENT | 评估ID (主键) |
| emp_id | BIGINT | - | NO | - | 员工ID |
| year | INT | - | NO | - | 评估年度 |
| period_type | TINYINT | - | NO | - | 评估周期 (1-年度 2-季度 3-月度) |
| quarter | INT | - | YES | - | 季度 (季度评估时使用) |
| month | INT | - | YES | - | 月份 (月度评估时使用) |
| self_score | DECIMAL | 5,2 | NO | - | 自评分 |
| self_comment | TEXT | - | YES | - | 自评说明 |
| supervisor_score | DECIMAL | 5,2 | YES | - | 上级评分 |
| supervisor_comment | TEXT | - | YES | - | 上级评价意见 |
| final_score | DECIMAL | 5,2 | YES | - | 综合评分 |
| performance_level | CHAR | 1 | YES | - | 绩效等级 (S/A/B/C/D) |
| improvement_plan | TEXT | - | YES | - | 改进建议 |
| interview_record | TEXT | - | YES | - | 面谈记录 |
| interview_date | DATETIME | - | YES | - | 面谈时间 |
| evaluation_status | TINYINT | - | NO | 0 | 评估状态 (0-未评估 1-已自评 2-已评价 3-已完成) |
| create_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 更新时间 (自动更新) |
| deleted | TINYINT | - | NO | 0 | 删除标记 (0-未删除 1-已删除) |

**索引**:
- PRIMARY KEY: evaluation_id
- INDEX: idx_emp_year_period (emp_id, year, period_type)
- INDEX: idx_performance_level
- INDEX: idx_evaluation_status
- INDEX: idx_interview_date
- INDEX: idx_quarter
- INDEX: idx_month

### 8. salary_payment (薪资发放表)

**功能说明**: 存储员工每月薪资发放明细

**表结构**:

| 字段名 | 类型 | 长度 | 允许空 | 默认值 | 说明 |
|--------|------|------|--------|--------|------|
| payment_id | BIGINT | - | NO | AUTO_INCREMENT | 发放ID (主键) |
| emp_id | BIGINT | - | NO | - | 员工ID |
| year | INT | - | NO | - | 发放年度 |
| month | INT | - | NO | - | 发放月份 |
| basic_salary | DECIMAL | 10,2 | NO | - | 基本工资 |
| performance_salary | DECIMAL | 10,2 | NO | 0 | 绩效工资 |
| position_allowance | DECIMAL | 10,2 | NO | 0 | 岗位津贴 |
| transport_allowance | DECIMAL | 10,2 | NO | 0 | 交通补贴 |
| communication_allowance | DECIMAL | 10,2 | NO | 0 | 通讯补贴 |
| meal_allowance | DECIMAL | 10,2 | NO | 0 | 餐补 |
| other_allowance | DECIMAL | 10,2 | NO | 0 | 其他补贴 |
| overtime_pay | DECIMAL | 10,2 | NO | 0 | 加班费 |
| total_gross_salary | DECIMAL | 10,2 | NO | - | 应发工资总额 |
| social_insurance | DECIMAL | 10,2 | NO | 0 | 社保个人部分 |
| housing_fund | DECIMAL | 10,2 | NO | 0 | 公积金个人部分 |
| income_tax | DECIMAL | 10,2 | NO | 0 | 个人所得税 |
| other_deduction | DECIMAL | 10,2 | NO | 0 | 其他扣款 |
| total_net_salary | DECIMAL | 10,2 | NO | - | 实发工资总额 |
| payment_status | TINYINT | - | NO | 0 | 发放状态 (0-未发放 1-已发放) |
| payment_date | DATETIME | - | YES | - | 发放时间 |
| remark | VARCHAR | 500 | YES | - | 备注 |
| create_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 更新时间 (自动更新) |
| deleted | TINYINT | - | NO | 0 | 删除标记 (0-未删除 1-已删除) |

**索引**:
- PRIMARY KEY: payment_id
- INDEX: idx_emp_year_month (emp_id, year, month)
- INDEX: idx_year_month
- INDEX: idx_payment_status
- INDEX: idx_basic_salary
- INDEX: idx_total_gross_salary

### 9. salary_adjustment (薪资调整表)

**功能说明**: 存储员工薪资调整记录

**表结构**:

| 字段名 | 类型 | 长度 | 允许空 | 默认值 | 说明 |
|--------|------|------|--------|--------|------|
| adjustment_id | BIGINT | - | NO | AUTO_INCREMENT | 调整ID (主键) |
| emp_id | BIGINT | - | NO | - | 员工ID |
| adjustment_type | TINYINT | - | NO | - | 调整类型 (1-晋升 2-降职 3-调薪 4-转正) |
| before_salary | DECIMAL | 10,2 | NO | - | 调整前工资 |
| after_salary | DECIMAL | 10,2 | NO | - | 调整后工资 |
| adjustment_rate | DECIMAL | 5,2 | YES | - | 调整幅度(%) |
| effective_date | DATETIME | - | NO | - | 生效日期 |
| reason | TEXT | - | YES | - | 调整原因 |
| approver_id | BIGINT | - | NO | - | 审批人ID |
| approval_status | TINYINT | - | NO | 0 | 审批状态 (0-待审批 1-已同意 2-已拒绝) |
| approval_comment | TEXT | - | YES | - | 审批意见 |
| approval_date | DATETIME | - | YES | - | 审批时间 |
| creator_id | BIGINT | - | YES | - | 创建人ID |
| create_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 更新时间 (自动更新) |
| deleted | TINYINT | - | NO | 0 | 删除标记 (0-未删除 1-已删除) |

**索引**:
- PRIMARY KEY: adjustment_id
- INDEX: idx_emp_id
- INDEX: idx_effective_date
- INDEX: idx_adjustment_type
- INDEX: idx_approval_date
- INDEX: idx_creator_id
- INDEX: idx_before_salary
- INDEX: idx_after_salary

### 10. training_course (培训课程表)

**功能说明**: 存储企业培训课程信息

**表结构**:

| 字段名 | 类型 | 长度 | 允许空 | 默认值 | 说明 |
|--------|------|------|--------|--------|------|
| course_id | BIGINT | - | NO | AUTO_INCREMENT | 课程ID (主键) |
| course_name | VARCHAR | 100 | NO | - | 课程名称 |
| course_type | TINYINT | - | NO | - | 课程类型 (1-新员工培训 2-技能培训 3-管理培训 4-安全培训 5-其他) |
| course_description | VARCHAR | 500 | YES | - | 课程描述 |
| instructor | VARCHAR | 50 | NO | - | 培训讲师 |
| duration | INT | - | NO | - | 培训时长(小时) |
| location | VARCHAR | 100 | NO | - | 培训地点 |
| start_date | DATETIME | - | NO | - | 培训开始时间 |
| end_date | DATETIME | - | NO | - | 培训结束时间 |
| capacity | INT | - | NO | - | 培训名额 |
| enrolled_count | INT | - | NO | 0 | 已报名人数 |
| course_status | TINYINT | - | NO | 0 | 课程状态 (0-未开始 1-进行中 2-已结束) |
| create_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 更新时间 (自动更新) |
| deleted | TINYINT | - | NO | 0 | 删除标记 (0-未删除 1-已删除) |

**索引**:
- PRIMARY KEY: course_id
- INDEX: idx_course_type
- INDEX: idx_course_name
- INDEX: idx_instructor
- INDEX: idx_start_date
- INDEX: idx_course_status

### 11. training_enrollment (培训报名表)

**功能说明**: 存储员工培训报名记录

**表结构**:

| 字段名 | 类型 | 长度 | 允许空 | 默认值 | 说明 |
|--------|------|------|--------|--------|------|
| enrollment_id | BIGINT | - | NO | AUTO_INCREMENT | 报名ID (主键) |
| course_id | BIGINT | - | NO | - | 课程ID |
| emp_id | BIGINT | - | NO | - | 员工ID |
| enrollment_time | DATETIME | - | NO | - | 报名时间 |
| approval_status | TINYINT | - | NO | 0 | 审核状态 (0-待审核 1-已通过 2-已拒绝) |
| approver_id | BIGINT | - | YES | - | 审核人ID |
| attendance_status | TINYINT | - | NO | 0 | 出勤状态 (0-未出勤 1-已出勤 2-请假) |
| score | INT | - | YES | - | 培训成绩 |
| feedback | TEXT | - | YES | - | 培训反馈 |
| create_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 更新时间 (自动更新) |
| deleted | TINYINT | - | NO | 0 | 删除标记 (0-未删除 1-已删除) |

**索引**:
- PRIMARY KEY: enrollment_id
- UNIQUE KEY: uk_course_emp (course_id, emp_id)
- INDEX: idx_course_id
- INDEX: idx_emp_id
- INDEX: idx_approval_status
- INDEX: idx_approver_id
- INDEX: idx_enrollment_time

### 12. data_category (数据分类表)

**功能说明**: 存储数据分析分类信息

**表结构**:

| 字段名 | 类型 | 长度 | 允许空 | 默认值 | 说明 |
|--------|------|------|--------|--------|------|
| category_id | BIGINT | - | NO | AUTO_INCREMENT | 分类ID (主键) |
| category_name | VARCHAR | 50 | NO | - | 分类名称 |
| category_code | VARCHAR | 50 | NO | - | 分类编码 (唯一) |
| parent_id | BIGINT | - | NO | 0 | 父分类ID |
| icon | VARCHAR | 50 | YES | - | 图标 |
| description | VARCHAR | 200 | YES | - | 分类描述 |
| sort_order | INT | - | NO | 0 | 排序序号 |
| status | TINYINT | - | NO | 1 | 状态 (0-禁用 1-启用) |
| create_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 更新时间 (自动更新) |
| create_by | VARCHAR | 50 | YES | - | 创建人 |
| update_by | VARCHAR | 50 | YES | - | 更新人 |
| remark | VARCHAR | 500 | YES | - | 备注 |
| deleted | TINYINT | - | NO | 0 | 删除标记 (0-未删除 1-已删除) |

**索引**:
- PRIMARY KEY: category_id
- UNIQUE KEY: category_code
- INDEX: idx_parent_id
- INDEX: idx_status
- INDEX: idx_category_name

### 13. sys_operation_log (操作日志表)

**功能说明**: 记录用户操作日志

**表结构**:

| 字段名 | 类型 | 长度 | 允许空 | 默认值 | 说明 |
|--------|------|------|--------|--------|------|
| log_id | BIGINT | - | NO | AUTO_INCREMENT | 日志ID (主键) |
| user_id | BIGINT | - | YES | - | 用户ID |
| username | VARCHAR | 50 | YES | - | 用户名 |
| module | VARCHAR | 50 | YES | - | 模块名 |
| type | VARCHAR | 20 | YES | - | 操作类型 |
| description | VARCHAR | 200 | YES | - | 操作描述 |
| request_method | VARCHAR | 10 | YES | - | 请求方法 |
| request_url | VARCHAR | 500 | YES | - | 请求URL |
| request_ip | VARCHAR | 50 | YES | - | 请求IP |
| request_params | TEXT | - | YES | - | 请求参数 |
| response_data | TEXT | - | YES | - | 响应数据 |
| status | TINYINT | - | NO | 1 | 状态 (0-失败 1-成功) |
| error_message | TEXT | - | YES | - | 错误信息 |
| execution_time | INT | - | YES | - | 执行时长(毫秒) |
| create_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 创建时间 |

**索引**:
- PRIMARY KEY: log_id
- INDEX: idx_user_id
- INDEX: idx_module
- INDEX: idx_type
- INDEX: idx_create_time

### 14. message (消息表)

**功能说明**: 存储系统消息通知

**表结构**:

| 字段名 | 类型 | 长度 | 允许空 | 默认值 | 说明 |
|--------|------|------|--------|--------|------|
| message_id | BIGINT | - | NO | AUTO_INCREMENT | 消息ID (主键) |
| title | VARCHAR | 200 | NO | - | 消息标题 |
| content | TEXT | - | NO | - | 消息内容 |
| message_type | TINYINT | - | NO | - | 消息类型 (0-系统通知 1-业务通知) |
| receiver_id | BIGINT | - | YES | - | 接收人ID |
| sender_id | BIGINT | - | YES | - | 发送人ID |
| is_read | TINYINT | - | NO | 0 | 是否已读 (0-未读 1-已读) |
| read_time | DATETIME | - | YES | - | 阅读时间 |
| create_time | DATETIME | - | NO | CURRENT_TIMESTAMP | 创建时间 |
| deleted | TINYINT | - | NO | 0 | 删除标记 (0-未删除 1-已删除) |

**索引**:
- PRIMARY KEY: message_id
- INDEX: idx_receiver_id
- INDEX: idx_is_read
- INDEX: idx_title
- INDEX: idx_create_time

## 数据字典

### 状态码说明

#### 用户状态 (sys_user.status)
- 0: 禁用
- 1: 启用

#### 员工状态 (employee.status)
- 0: 离职
- 1: 在职
- 2: 试用

#### 考勤类型 (attendance.attendance_type)
- 0: 正常
- 1: 迟到
- 2: 早退
- 3: 旷工
- 4: 请假
- 5: 加班

#### 考勤状态 (attendance.attendance_status)
- 0: 未打卡
- 1: 已打卡
- 2: 请假
- 3: 加班

#### 请假类型 (leave.leave_type)
- 0: 事假
- 1: 病假
- 2: 年假
- 3: 婚假
- 4: 产假
- 5: 丧假
- 6: 其他

#### 审批状态 (通用)
- 0: 待审批
- 1: 已同意
- 2: 已拒绝
- 3: 已撤回

#### 评估周期 (performance_goal.period_type, performance_evaluation.period_type)
- 1: 年度
- 2: 季度
- 3: 月度

#### 目标状态 (performance_goal.goal_status)
- 0: 草稿
- 1: 进行中
- 2: 已完成

#### 评估状态 (performance_evaluation.evaluation_status)
- 0: 未评估
- 1: 已自评
- 2: 已评价
- 3: 已完成

#### 绩效等级 (performance_evaluation.performance_level)
- S: 优秀
- A: 良好
- B: 合格
- C: 待改进
- D: 不合格

#### 薪资调整类型 (salary_adjustment.adjustment_type)
- 1: 晋升
- 2: 降职
- 3: 调薪
- 4: 转正

#### 培训课程类型 (training_course.course_type)
- 1: 新员工培训
- 2: 技能培训
- 3: 管理培训
- 4: 安全培训
- 5: 其他

#### 课程状态 (training_course.course_status)
- 0: 未开始
- 1: 进行中
- 2: 已结束

#### 出勤状态 (training_enrollment.attendance_status)
- 0: 未出勤
- 1: 已出勤
- 2: 请假

## 初始化脚本

数据库初始化脚本位于: `database/mysql/init.sql`

该脚本包含:
1. 创建数据库
2. 创建所有业务表
3. 创建所有索引
4. 插入测试数据

### 执行初始化

```bash
mysql -u root -p < database/mysql/init.sql
```

## 数据备份与恢复

### 备份

```bash
mysqldump -u root -p hr_datacenter > hr_datacenter_backup_$(date +%Y%m%d).sql
```

### 恢复

```bash
mysql -u root -p hr_datacenter < hr_datacenter_backup_20260407.sql
```

## 性能优化建议

1. **索引优化**: 确保常用查询字段都有适当的索引
2. **分表分库**: 当数据量达到千万级时，考虑按时间或业务维度进行分表
3. **读写分离**: 使用主从复制，将读操作分流到从库
4. **定期清理**: 定期清理过期的操作日志和消息数据
5. **参数调优**: 根据实际负载调整MySQL配置参数

## 安全建议

1. **密码加密**: 所有用户密码使用BCrypt加密存储
2. **权限控制**: 严格控制数据库用户权限
3. **审计日志**: 启用MySQL审计日志功能
4. **定期备份**: 建立完善的备份策略
5. **网络安全**: 使用SSL连接，限制远程访问

## 维护说明

### 定期维护任务

1. **每天**:
   - 检查慢查询日志
   - 监控数据库连接数
   - 检查磁盘空间

2. **每周**:
   - 分析表性能
   - 优化索引
   - 检查数据一致性

3. **每月**:
   - 执行数据库备份
   - 清理过期数据
   - 更新统计信息

### 监控指标

- 连接数
- 查询响应时间
- 慢查询数量
- 磁盘使用率
- 缓存命中率

## 常见问题

### Q: 如何重置密码?

A: 使用BCrypt生成新密码的哈希值，然后更新sys_user表的password字段。

### Q: 如何清空测试数据?

A: 执行各表的TRUNCATE语句，保留基础配置数据。

### Q: 如何导入大量数据?

A: 使用LOAD DATA INFILE命令批量导入，比INSERT语句快很多。

## 版本历史

- v2.0 (2026-04-07): 统一初始化脚本，完善表结构和索引
- v1.0 (2026-03-31): 初始版本

## 联系方式

如有问题，请联系数据库管理员或开发团队。
