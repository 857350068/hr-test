# 数据库设计技术实现文档

## 1. 实现模型

### 1.1 上下文视图

本数据库设计组件在整体系统中的位置和作用:

```
┌─────────────────────────────────────────────────────────────┐
│                    人力资源数据中心系统                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐         ┌──────────────┐                 │
│  │  前端应用     │◄───────►│  后端服务     │                 │
│  │  (Vue3)      │         │  (SpringBoot)│                 │
│  └──────────────┘         └──────┬───────┘                 │
│                                   │                           │
│                                   ▼                           │
│                         ┌─────────────────┐                 │
│                         │  数据访问层      │                 │
│                         │  (MyBatis Plus) │                 │
│                         └────┬─────┬─────┘                 │
│                              │     │                         │
│              ┌───────────────┘     └───────────────┐       │
│              ▼                                       ▼       │
│    ┌──────────────────┐              ┌──────────────────┐  │
│    │  MySQL数据库      │              │  Hive数据仓库     │  │
│    │  (业务数据存储)   │              │  (大数据分析)     │  │
│    └──────────────────┘              └──────────────────┘  │
│              │                                       │       │
│              └───────────────┬───────────────────────┘       │
│                              ▼                               │
│                    ┌─────────────────┐                      │
│                    │  数据同步服务    │                      │
│                    └─────────────────┘                      │
└─────────────────────────────────────────────────────────────┘
```

**核心职责**:
- MySQL: 存储业务数据,支持事务和高并发查询
- Hive: 存储历史数据,支持大数据分析和报表生成
- 数据同步: 定时将MySQL数据同步到Hive

### 1.2 服务/组件总体架构

#### 1.2.1 MySQL数据库架构

```
hr_datacenter (数据库)
│
├── 用户权限模块
│   └── sys_user (用户表)
│
├── 员工管理模块
│   └── employee (员工表)
│
├── 考勤管理模块
│   └── attendance (考勤记录表)
│
├── 请假管理模块
│   └── leave (请假记录表)
│
├── 绩效管理模块
│   ├── performance_goal (绩效目标表)
│   └── performance_evaluation (绩效评估表)
│
├── 薪资管理模块
│   ├── salary_payment (薪资发放表)
│   └── salary_adjustment (薪资调整表)
│
└── 培训管理模块
    ├── training_course (培训课程表)
    └── training_enrollment (培训报名表)
```

#### 1.2.2 Hive数据仓库架构

```
hr_datacenter_dw (数据仓库)
│
├── 维度表 (Dimension Tables)
│   ├── dim_employee (员工维度表)
│   ├── dim_department (部门维度表)
│   ├── dim_date (日期维度表)
│   └── dim_course (培训课程维度表)
│
├── 事实表 (Fact Tables)
│   ├── fact_attendance (考勤事实表) - 按年月分区
│   ├── fact_salary (薪资事实表) - 按年月分区
│   ├── fact_performance (绩效事实表) - 按年分区
│   └── fact_training (培训事实表)
│
└── 聚合表 (Aggregation Tables)
    ├── agg_dept_monthly_attendance (部门月度考勤汇总)
    ├── agg_dept_monthly_salary (部门月度薪资汇总)
    ├── agg_employee_yearly_performance (员工年度绩效汇总)
    └── agg_course_statistics (培训课程统计)
```

### 1.3 实现设计文档

#### 1.3.1 MySQL数据库设计

**数据库配置**:
- 数据库名: `hr_datacenter`
- 字符集: `utf8mb4`
- 排序规则: `utf8mb4_unicode_ci`
- 存储引擎: `InnoDB`
- 事务隔离级别: `READ_COMMITTED`

**表设计原则**:
1. 所有表使用自增主键(BIGINT)
2. 所有表包含create_time、update_time字段(自动填充)
3. 所有表使用逻辑删除(deleted字段)
4. 外键关联保证数据完整性
5. 针对高频查询建立索引

**核心表结构**:

**1. sys_user (用户表)**
```sql
CREATE TABLE sys_user (
    user_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(100) NOT NULL COMMENT '密码(BCrypt加密)',
    real_name VARCHAR(50) NOT NULL COMMENT '真实姓名',
    dept_id BIGINT COMMENT '部门ID',
    phone VARCHAR(20) COMMENT '手机号码',
    email VARCHAR(100) COMMENT '邮箱',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态(0-禁用 1-启用)',
    last_login_time DATETIME COMMENT '最后登录时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    INDEX idx_username (username),
    INDEX idx_dept_id (dept_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';
```

**2. employee (员工表)**
```sql
CREATE TABLE employee (
    emp_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '员工ID',
    emp_no VARCHAR(20) NOT NULL UNIQUE COMMENT '员工编号',
    emp_name VARCHAR(50) NOT NULL COMMENT '员工姓名',
    gender TINYINT NOT NULL COMMENT '性别(0-女 1-男)',
    birth_date DATE NOT NULL COMMENT '出生日期',
    id_card VARCHAR(18) NOT NULL COMMENT '身份证号',
    phone VARCHAR(20) NOT NULL COMMENT '手机号码',
    email VARCHAR(100) COMMENT '邮箱',
    department VARCHAR(50) NOT NULL COMMENT '部门',
    position VARCHAR(50) NOT NULL COMMENT '职位',
    salary DECIMAL(10,2) NOT NULL COMMENT '薪资',
    hire_date DATE NOT NULL COMMENT '入职日期',
    resign_date DATE COMMENT '离职日期',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态(0-离职 1-在职 2-试用)',
    education VARCHAR(20) COMMENT '学历',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_emp_no (emp_no),
    INDEX idx_department (department),
    INDEX idx_status (status),
    INDEX idx_hire_date (hire_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工表';
```

**3. attendance (考勤记录表)**
```sql
CREATE TABLE attendance (
    attendance_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '考勤ID',
    emp_id BIGINT NOT NULL COMMENT '员工ID',
    attendance_date DATE NOT NULL COMMENT '考勤日期',
    clock_in_time TIME COMMENT '上班打卡时间',
    clock_out_time TIME COMMENT '下班打卡时间',
    attendance_type TINYINT NOT NULL COMMENT '考勤类型(0-正常 1-迟到 2-早退 3-旷工 4-请假 5-加班)',
    attendance_status TINYINT NOT NULL COMMENT '考勤状态(0-未打卡 1-已打卡 2-请假 3-加班)',
    work_duration INT COMMENT '工作时长(分钟)',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    UNIQUE KEY uk_emp_date (emp_id, attendance_date),
    INDEX idx_attendance_date (attendance_date),
    INDEX idx_emp_date (emp_id, attendance_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考勤记录表';
```

**4. leave (请假记录表)**
```sql
CREATE TABLE leave (
    leave_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '请假ID',
    emp_id BIGINT NOT NULL COMMENT '员工ID',
    leave_type TINYINT NOT NULL COMMENT '请假类型(0-事假 1-病假 2-年假 3-婚假 4-产假 5-丧假)',
    start_time DATETIME NOT NULL COMMENT '请假开始时间',
    end_time DATETIME NOT NULL COMMENT '请假结束时间',
    leave_duration INT NOT NULL COMMENT '请假时长(小时)',
    reason TEXT NOT NULL COMMENT '请假原因',
    approver_id BIGINT NOT NULL COMMENT '审批人ID',
    approval_status TINYINT NOT NULL DEFAULT 0 COMMENT '审批状态(0-待审批 1-已同意 2-已拒绝)',
    approval_comment TEXT COMMENT '审批意见',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_emp_id (emp_id),
    INDEX idx_approver_id (approver_id),
    INDEX idx_start_time (start_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='请假记录表';
```

**5. performance_goal (绩效目标表)**
```sql
CREATE TABLE performance_goal (
    goal_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '目标ID',
    emp_id BIGINT NOT NULL COMMENT '员工ID',
    year INT NOT NULL COMMENT '评估年度',
    period_type TINYINT NOT NULL COMMENT '评估周期(1-年度 2-季度 3-月度)',
    goal_description VARCHAR(500) NOT NULL COMMENT '目标描述',
    weight INT NOT NULL COMMENT '权重(百分比)',
    completion_standard VARCHAR(500) NOT NULL COMMENT '完成标准',
    goal_status TINYINT NOT NULL DEFAULT 0 COMMENT '目标状态(0-草稿 1-进行中 2-已完成)',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_emp_year_period (emp_id, year, period_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效目标表';
```

**6. performance_evaluation (绩效评估表)**
```sql
CREATE TABLE performance_evaluation (
    evaluation_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评估ID',
    emp_id BIGINT NOT NULL COMMENT '员工ID',
    year INT NOT NULL COMMENT '评估年度',
    period_type TINYINT NOT NULL COMMENT '评估周期',
    self_score DECIMAL(5,2) NOT NULL COMMENT '自评分',
    self_comment TEXT COMMENT '自评说明',
    supervisor_score DECIMAL(5,2) COMMENT '上级评分',
    supervisor_comment TEXT COMMENT '上级评价意见',
    final_score DECIMAL(5,2) COMMENT '综合评分',
    performance_level CHAR(1) COMMENT '绩效等级(S/A/B/C/D)',
    interview_record TEXT COMMENT '面谈记录',
    improvement_plan TEXT COMMENT '改进建议',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_emp_year_period (emp_id, year, period_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效评估表';
```

**7. salary_payment (薪资发放表)**
```sql
CREATE TABLE salary_payment (
    payment_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '发放ID',
    emp_id BIGINT NOT NULL COMMENT '员工ID',
    year INT NOT NULL COMMENT '发放年度',
    month INT NOT NULL COMMENT '发放月份',
    basic_salary DECIMAL(10,2) NOT NULL COMMENT '基本工资',
    performance_salary DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '绩效工资',
    position_allowance DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '岗位津贴',
    transport_allowance DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '交通补贴',
    communication_allowance DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '通讯补贴',
    meal_allowance DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '餐补',
    overtime_pay DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '加班费',
    social_insurance DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '社保个人部分',
    housing_fund DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '公积金个人部分',
    income_tax DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '个人所得税',
    other_deduction DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '其他扣款',
    total_gross_salary DECIMAL(10,2) NOT NULL COMMENT '应发工资总额',
    total_net_salary DECIMAL(10,2) NOT NULL COMMENT '实发工资总额',
    payment_status TINYINT NOT NULL DEFAULT 0 COMMENT '发放状态(0-未发放 1-已发放)',
    payment_date DATE COMMENT '发放日期',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_emp_year_month (emp_id, year, month),
    INDEX idx_year_month (year, month)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='薪资发放表';
```

**8. salary_adjustment (薪资调整表)**
```sql
CREATE TABLE salary_adjustment (
    adjustment_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '调整ID',
    emp_id BIGINT NOT NULL COMMENT '员工ID',
    adjustment_type TINYINT NOT NULL COMMENT '调整类型(1-晋升 2-降职 3-调薪 4-转正)',
    before_salary DECIMAL(10,2) NOT NULL COMMENT '调整前工资',
    after_salary DECIMAL(10,2) NOT NULL COMMENT '调整后工资',
    adjustment_rate DECIMAL(5,2) COMMENT '调整幅度(%)',
    effective_date DATE NOT NULL COMMENT '生效日期',
    reason TEXT COMMENT '调整原因',
    approver_id BIGINT NOT NULL COMMENT '审批人ID',
    approval_status TINYINT NOT NULL DEFAULT 0 COMMENT '审批状态',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_emp_id (emp_id),
    INDEX idx_effective_date (effective_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='薪资调整表';
```

**9. training_course (培训课程表)**
```sql
CREATE TABLE training_course (
    course_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '课程ID',
    course_name VARCHAR(100) NOT NULL COMMENT '课程名称',
    course_type TINYINT NOT NULL COMMENT '课程类型(1-新员工 2-技能 3-管理 4-安全)',
    instructor VARCHAR(50) NOT NULL COMMENT '培训讲师',
    duration INT NOT NULL COMMENT '培训时长(小时)',
    location VARCHAR(100) NOT NULL COMMENT '培训地点',
    start_date DATE NOT NULL COMMENT '开始日期',
    end_date DATE NOT NULL COMMENT '结束日期',
    capacity INT NOT NULL COMMENT '培训名额',
    enrolled_count INT NOT NULL DEFAULT 0 COMMENT '已报名人数',
    course_status TINYINT NOT NULL DEFAULT 0 COMMENT '课程状态(0-未开始 1-进行中 2-已结束)',
    description TEXT COMMENT '课程描述',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_course_type (course_type),
    INDEX idx_start_date (start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训课程表';
```

**10. training_enrollment (培训报名表)**
```sql
CREATE TABLE training_enrollment (
    enrollment_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '报名ID',
    course_id BIGINT NOT NULL COMMENT '课程ID',
    emp_id BIGINT NOT NULL COMMENT '员工ID',
    enrollment_time DATETIME NOT NULL COMMENT '报名时间',
    approval_status TINYINT NOT NULL DEFAULT 0 COMMENT '审核状态(0-待审核 1-已通过 2-已拒绝)',
    attendance_status TINYINT NOT NULL DEFAULT 0 COMMENT '出勤状态(0-未出勤 1-已出勤)',
    score INT COMMENT '培训成绩',
    feedback TEXT COMMENT '培训反馈',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    UNIQUE KEY uk_course_emp (course_id, emp_id),
    INDEX idx_course_id (course_id),
    INDEX idx_emp_id (emp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训报名表';
```

#### 1.3.2 Hive数据仓库设计

**数据库配置**:
- 数据库名: `hr_datacenter_dw`
- 存储格式: `ORC` (列式存储,支持压缩)
- 压缩格式: `SNAPPY`

**核心表结构**:

**1. dim_employee (员工维度表)**
```sql
CREATE TABLE dim_employee (
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    gender INT COMMENT '性别',
    birth_date STRING COMMENT '出生日期',
    department STRING COMMENT '部门',
    position STRING COMMENT '职位',
    hire_date STRING COMMENT '入职日期',
    education STRING COMMENT '学历',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');
```

**2. fact_attendance (考勤事实表)**
```sql
CREATE TABLE fact_attendance (
    attendance_id BIGINT COMMENT '考勤ID',
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    department STRING COMMENT '部门',
    attendance_date STRING COMMENT '考勤日期',
    clock_in_time STRING COMMENT '上班打卡时间',
    clock_out_time STRING COMMENT '下班打卡时间',
    attendance_type INT COMMENT '考勤类型',
    work_duration INT COMMENT '工作时长',
    year INT COMMENT '年',
    month INT COMMENT '月',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
PARTITIONED BY (year_month STRING)
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');
```

**3. fact_salary (薪资事实表)**
```sql
CREATE TABLE fact_salary (
    payment_id BIGINT COMMENT '发放ID',
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    department STRING COMMENT '部门',
    year INT COMMENT '发放年度',
    month INT COMMENT '发放月份',
    basic_salary DECIMAL(10,2) COMMENT '基本工资',
    performance_salary DECIMAL(10,2) COMMENT '绩效工资',
    total_gross_salary DECIMAL(10,2) COMMENT '应发工资',
    total_net_salary DECIMAL(10,2) COMMENT '实发工资',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
PARTITIONED BY (year_month STRING)
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');
```

**4. agg_dept_monthly_attendance (部门月度考勤汇总)**
```sql
CREATE TABLE agg_dept_monthly_attendance (
    department STRING COMMENT '部门',
    year INT COMMENT '年',
    month INT COMMENT '月',
    total_employees INT COMMENT '总人数',
    normal_count INT COMMENT '正常次数',
    late_count INT COMMENT '迟到次数',
    early_leave_count INT COMMENT '早退次数',
    absent_count INT COMMENT '旷工次数',
    leave_count INT COMMENT '请假次数',
    overtime_count INT COMMENT '加班次数',
    avg_work_duration DECIMAL(10,2) COMMENT '平均工作时长',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');
```

## 2. 接口设计

### 2.1 总体设计

数据库设计组件不直接对外提供API接口,而是通过SQL脚本文件的形式提供:

**文件组织结构**:
```
database/
├── mysql/
│   ├── 01_create_database.sql      # 建库脚本
│   ├── 02_create_tables.sql        # 建表脚本
│   ├── 03_create_indexes.sql       # 索引脚本
│   ├── 04_insert_users.sql         # 用户数据
│   ├── 05_insert_employees.sql     # 员工数据
│   ├── 06_insert_attendance.sql    # 考勤数据
│   ├── 07_insert_leave.sql         # 请假数据
│   ├── 08_insert_performance.sql   # 绩效数据
│   ├── 09_insert_salary.sql        # 薪资数据
│   ├── 10_insert_training.sql      # 培训数据
│   └── init.sql                    # 完整初始化脚本
│
└── hive/
    ├── 01_create_database.sql      # 建库脚本
    ├── 02_create_dim_tables.sql    # 维度表脚本
    ├── 03_create_fact_tables.sql   # 事实表脚本
    ├── 04_create_agg_tables.sql    # 聚合表脚本
    ├── 05_load_dim_data.sql        # 加载维度数据
    ├── 06_load_fact_data.sql       # 加载事实数据
    ├── 07_generate_agg_data.sql    # 生成聚合数据
    └── init.sql                    # 完整初始化脚本
```

### 2.2 接口清单

**MySQL脚本接口**:

| 脚本文件 | 功能说明 | 执行顺序 | 依赖关系 |
|---------|---------|---------|---------|
| 01_create_database.sql | 创建hr_datacenter数据库 | 1 | 无 |
| 02_create_tables.sql | 创建10张业务表 | 2 | 01 |
| 03_create_indexes.sql | 创建索引和约束 | 3 | 02 |
| 04_insert_users.sql | 插入用户数据(2条) | 4 | 02 |
| 05_insert_employees.sql | 插入员工数据(50条) | 5 | 02 |
| 06_insert_attendance.sql | 插入考勤数据(1000条) | 6 | 02,05 |
| 07_insert_leave.sql | 插入请假数据(50条) | 7 | 02,04,05 |
| 08_insert_performance.sql | 插入绩效数据(150条) | 8 | 02,05 |
| 09_insert_salary.sql | 插入薪资数据(500条) | 9 | 02,05 |
| 10_insert_training.sql | 插入培训数据(110条) | 10 | 02,05 |
| init.sql | 完整初始化(包含以上所有) | - | 无 |

**Hive脚本接口**:

| 脚本文件 | 功能说明 | 执行顺序 | 依赖关系 |
|---------|---------|---------|---------|
| 01_create_database.sql | 创建hr_datacenter_dw数据仓库 | 1 | 无 |
| 02_create_dim_tables.sql | 创建维度表(4张) | 2 | 01 |
| 03_create_fact_tables.sql | 创建事实表(4张) | 3 | 01 |
| 04_create_agg_tables.sql | 创建聚合表(4张) | 4 | 01 |
| 05_load_dim_data.sql | 从MySQL加载维度数据 | 5 | 02,MySQL数据 |
| 06_load_fact_data.sql | 从MySQL加载事实数据 | 6 | 03,MySQL数据 |
| 07_generate_agg_data.sql | 生成聚合数据 | 7 | 04,05,06 |
| init.sql | 完整初始化(包含以上所有) | - | 无 |

## 3. 数据模型

### 3.1 设计目标

**MySQL数据模型目标**:
1. **事务支持**: 支持ACID事务,保证数据一致性
2. **高并发查询**: 通过索引优化,支持高并发查询
3. **数据完整性**: 通过外键约束保证数据完整性
4. **逻辑删除**: 所有表支持逻辑删除,保留历史数据
5. **自动时间戳**: 自动维护创建时间和更新时间

**Hive数据模型目标**:
1. **大数据分析**: 支持TB级数据分析
2. **高性能查询**: 通过分区和列式存储提高查询性能
3. **数据压缩**: 使用ORC+SNAPPY压缩,节省存储空间
4. **预聚合**: 通过聚合表提高报表查询性能
5. **历史数据**: 存储历史数据,支持趋势分析

### 3.2 模型实现

#### 3.2.1 MySQL数据模型ER图

```
┌─────────────┐
│  sys_user   │
│  (用户表)   │
└──────┬──────┘
       │
       │ 1:N
       │
       ▼
┌─────────────┐         ┌──────────────┐
│  employee  │◄────────│  attendance  │
│  (员工表)  │   1:N    │  (考勤表)    │
└──────┬──────┘         └──────────────┘
       │
       │ 1:N
       ├──────────────────┐
       │                  │
       ▼                  ▼
┌─────────────┐    ┌──────────────┐
│   leave     │    │ performance_ │
│  (请假表)   │    │    goal      │
└─────────────┘    │  (绩效目标)  │
                    └──────┬───────┘
                           │
                           │ 1:1
                           ▼
                    ┌──────────────┐
                    │ performance_ │
                    │ evaluation   │
                    │ (绩效评估)   │
                    └──────────────┘

┌─────────────┐         ┌──────────────┐
│  employee  │◄────────│    salary_   │
│            │   1:N   │   payment    │
└──────┬──────┘         │  (薪资发放)  │
       │                └──────────────┘
       │ 1:N
       ▼
┌─────────────┐
│   salary_   │
│ adjustment  │
│ (薪资调整)  │
└─────────────┘

┌─────────────┐         ┌──────────────┐
│  training_  │◄────────│  training_   │
│   course    │   1:N   │ enrollment   │
│ (培训课程)  │         │  (培训报名)  │
└─────────────┘         └──────┬───────┘
                               │
                               │ N:1
                               ▼
                        ┌─────────────┐
                        │  employee   │
                        └─────────────┘
```

#### 3.2.2 Hive数据模型星型模式

```
                    ┌──────────────┐
                    │ dim_employee │
                    │  (员工维度)  │
                    └──────┬───────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
    ┌──────────────┐ ┌──────────┐ ┌──────────────┐
    │fact_attendance│ │fact_salary│ │fact_performance│
    │  (考勤事实)  │ │(薪资事实)│ │  (绩效事实)  │
    └──────────────┘ └──────────┘ └──────────────┘
              │            │            │
              └────────────┼────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   dim_date   │
                    │  (日期维度)  │
                    └──────────────┘

                    ┌──────────────┐
                    │ dim_course   │
                    │ (课程维度)   │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │fact_training │
                    │ (培训事实)   │
                    └──────────────┘
```

#### 3.2.3 数据同步策略

**同步方式**: 增量同步 + 全量同步

**同步频率**:
- 维度表: 每日凌晨2点全量同步
- 事实表: 每日凌晨3点增量同步(同步前一天数据)
- 聚合表: 每日凌晨4点重新生成

**同步流程**:
```
MySQL → Sqoop/DataX → HDFS → Hive ODS层 → Hive DW层
```

**数据分层**:
- ODS层(操作数据层): 原始数据,与MySQL结构一致
- DW层(数据仓库层): 清洗后的维度表和事实表
- DM层(数据集市层): 预聚合的汇总表
