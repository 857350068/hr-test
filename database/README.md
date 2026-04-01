# 人力资源数据中心 - 数据库设计文档

## 项目概述

本项目为人力资源数据中心提供完整的数据库设计方案,包括MySQL业务数据库和Hive数据仓库,支持员工管理、考勤、绩效、薪酬、培训等HR业务模块。

## 数据库架构

### MySQL业务数据库 (hr_datacenter)

**用途**: 存储业务数据,支持事务和高并发查询

**核心表结构**:
- `sys_user` - 用户表(系统登录用户)
- `employee` - 员工表(员工基本信息)
- `attendance` - 考勤记录表(每日打卡记录)
- `leave` - 请假记录表(请假申请和审批)
- `performance_goal` - 绩效目标表(绩效目标设定)
- `performance_evaluation` - 绩效评估表(绩效评估结果)
- `salary_payment` - 薪资发放表(每月薪资明细)
- `salary_adjustment` - 薪资调整表(薪资调整记录)
- `training_course` - 培训课程表(培训课程信息)
- `training_enrollment` - 培训报名表(培训报名记录)

**设计特点**:
- 使用utf8mb4字符集,支持emoji和特殊字符
- 所有表使用InnoDB引擎,支持事务
- 主键自增,包含create_time、update_time、deleted字段
- 逻辑删除机制,保留历史数据
- 完善的索引设计,优化查询性能

### Hive数据仓库 (hr_datacenter_dw)

**用途**: 存储历史数据,支持大数据分析和报表生成

**表结构设计**:
- **维度表**:
  - `dim_employee` - 员工维度表
  - `dim_department` - 部门维度表
  - `dim_date` - 日期维度表
  - `dim_course` - 培训课程维度表

- **事实表**:
  - `fact_attendance` - 考勤事实表(按年月分区)
  - `fact_salary` - 薪资事实表(按年月分区)
  - `fact_performance` - 绩效事实表(按年分区)
  - `fact_training` - 培训事实表

- **聚合表**:
  - `agg_dept_monthly_attendance` - 部门月度考勤汇总
  - `agg_dept_monthly_salary` - 部门月度薪资汇总
  - `agg_employee_yearly_performance` - 员工年度绩效汇总
  - `agg_course_statistics` - 培训课程统计

**设计特点**:
- 使用ORC列式存储格式,支持高效压缩
- 使用SNAPPY压缩算法,节省存储空间
- 分区表设计,提高查询性能
- 预聚合表,加速报表查询

## 目录结构

```
database/
├── mysql/                          # MySQL数据库脚本
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
├── hive/                           # Hive数据仓库脚本
│   ├── 01_create_database.sql      # 建库脚本
│   ├── 02_create_dim_tables.sql    # 维度表脚本
│   ├── 03_create_fact_tables.sql   # 事实表脚本
│   ├── 04_create_agg_tables.sql    # 聚合表脚本
│   ├── 05_load_data.sql            # 数据加载脚本
│   └── init.sql                    # 完整初始化脚本
│
└── README.md                       # 本文档
```

## 快速开始

### MySQL数据库初始化

**方式一:使用完整初始化脚本(推荐)**
```bash
# 登录MySQL
mysql -u root -p

# 执行完整初始化脚本
source d:/HrDataCenter/database/mysql/init.sql
```

**方式二:逐步执行脚本**
```bash
mysql -u root -p

# 1. 创建数据库
source d:/HrDataCenter/database/mysql/01_create_database.sql

# 2. 创建表
source d:/HrDataCenter/database/mysql/02_create_tables.sql

# 3. 创建索引
source d:/HrDataCenter/database/mysql/03_create_indexes.sql

# 4-10. 插入数据
source d:/HrDataCenter/database/mysql/04_insert_users.sql
source d:/HrDataCenter/database/mysql/05_insert_employees.sql
source d:/HrDataCenter/database/mysql/06_insert_attendance.sql
source d:/HrDataCenter/database/mysql/07_insert_leave.sql
source d:/HrDataCenter/database/mysql/08_insert_performance.sql
source d:/HrDataCenter/database/mysql/09_insert_salary.sql
source d:/HrDataCenter/database/mysql/10_insert_training.sql
```

### Hive数据仓库初始化

**前提条件**:
- Hadoop集群已启动
- Hive服务已启动
- MySQL数据库已初始化

**初始化步骤**:
```bash
# 登录Hive
hive

# 执行完整初始化脚本
source /path/to/database/hive/init.sql
```

## 数据量说明

**MySQL测试数据量**:
- 用户: 4条(admin、hr001、manager001、emp001)
- 员工: 50条(覆盖技术部、人事部、财务部、市场部、销售部)
- 考勤: 1000+条(最近90天,使用存储过程生成)
- 请假: 50+条(使用存储过程生成)
- 绩效目标: 100+条
- 绩效评估: 50+条
- 薪资发放: 500+条(最近12个月)
- 培训课程: 12条
- 培训报名: 100+条

## 性能优化

### MySQL优化

**索引设计**:
- 主键索引: 所有表都有自增主键
- 唯一索引: 员工编号、用户名等唯一字段
- 联合索引: 针对高频查询场景
  - `(emp_id, attendance_date)` - 考勤查询
  - `(emp_id, year, period_type)` - 绩效查询
  - `(emp_id, year, month)` - 薪资查询

**查询优化建议**:
- 使用索引覆盖查询
- 避免SELECT *
- 使用LIMIT分页
- 避免在索引列上使用函数

### Hive优化

**分区设计**:
- 考勤事实表按年月分区
- 薪资事实表按年月分区
- 绩效事实表按年分区

**存储优化**:
- ORC列式存储,提高查询性能
- SNAPPY压缩,节省存储空间

**聚合优化**:
- 预聚合部门月度考勤汇总
- 预聚合部门月度薪资汇总
- 预聚合员工年度绩效汇总
- 预聚合培训课程统计

## 数据同步策略

**同步方式**: 增量同步 + 全量同步

**同步频率**:
- 维度表: 每日凌晨2点全量同步
- 事实表: 每日凌晨3点增量同步
- 聚合表: 每日凌晨4点重新生成

**同步工具**:
- Sqoop: MySQL → HDFS
- Hive: HDFS → Hive表

## 测试账号

**系统登录账号**:
- 管理员: admin / 123456
- HR用户: hr001 / 123456
- 部门经理: manager001 / 123456
- 普通员工: emp001 / 123456

**注意**: 密码使用BCrypt加密存储

## 常见问题

### Q1: 如何重新初始化数据库?
A: 执行`01_create_database.sql`会删除并重建数据库,所有数据将丢失。

### Q2: 如何只初始化某个模块的数据?
A: 单独执行对应的SQL脚本,如只初始化员工数据:
```bash
source d:/HrDataCenter/database/mysql/05_insert_employees.sql
```

### Q3: Hive数据加载失败怎么办?
A: 检查以下几点:
- MySQL数据库是否已初始化
- Hadoop集群是否正常运行
- Hive服务是否正常启动
- 网络连接是否正常

### Q4: 如何查看数据统计?
A: 执行以下SQL:
```sql
-- MySQL数据统计
SELECT
    TABLE_NAME AS 表名,
    TABLE_ROWS AS 数据行数
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'hr_datacenter';

-- Hive数据统计
SHOW TABLES;
SELECT COUNT(*) FROM fact_attendance;
```

## 技术支持

如有问题,请联系项目维护人员或查看项目文档。

---

**文档版本**: v1.0
**最后更新**: 2026-03-31
**维护人员**: HR数据中心项目组
