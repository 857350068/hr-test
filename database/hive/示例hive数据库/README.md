# 人力资源数据中心 - Hive 数仓脚本

本目录包含与 **MySQL**（`databases/mysql/init.sql`）、**后端实体类**、**前端数据流** 对齐的 Hive 建表与示例数据，用于数仓层、离线分析与报表。

## 文件说明

| 文件 | 说明 |
|------|------|
| `01_create_database.sql` | 创建库 `hr_db`，与 MySQL 库名一致 |
| `02_ddl_tables.sql` | 13 张表 DDL，字段与 MySQL/实体一一对应 |
| `03_insert_data.sql` | 与 MySQL 初始数据一致的示例/真实数据 INSERT |
| `04_analytics_example.sql` | 分析示例 SQL（组织效能、预警、培训、绩效、薪酬、员工列表） |

## 表与实体/MySQL 对应关系

| Hive 表 | MySQL 表 | 后端实体 | 说明 |
|---------|----------|----------|------|
| sys_role | sys_role | SysRole | 角色 |
| sys_department | sys_department | SysDepartment | 部门 |
| sys_user | sys_user | SysUser | 用户 |
| hr_position | hr_position | HrPosition | 岗位 |
| hr_employee | hr_employee | HrEmployee | 员工（emp_no, status） |
| hr_data_category | hr_data_category | HrDataCategory | 数据分类 |
| hr_warning_rule | hr_warning_rule | HrWarningRule | 预警规则 |
| hr_warning_info | hr_warning_info | HrWarningInfo | 预警信息（warning_type: TURNOVER/TALENT_GAP/COST） |
| hr_training_record | hr_training_record | HrTrainingRecord | 培训记录（participant_count, satisfaction_score, training_cost, description） |
| hr_performance_record | hr_performance_record | HrPerformanceRecord | 绩效记录（performance_cycle, performance_score, achievement_rate, evaluation_date, comments） |
| hr_salary_record | hr_salary_record | HrSalaryRecord | 薪资记录 |
| hr_favorite | hr_favorite | HrFavorite | 收藏（content_type, content_id, content_name） |
| hr_report_template | hr_report_template | HrReportTemplate | 报表模板 |

## 类型与存储

- **类型**：BIGINT/INT/TINYINT 与 MySQL 一致；VARCHAR/TEXT 统一为 `STRING`；日期/时间用 `STRING` 存储（如 `yyyy-MM-dd`、`yyyy-MM-dd HH:mm:ss`），便于与 MySQL 导出格式一致。
- **存储**：表为 `STORED AS PARQUET`。若集群不支持，可改为 `STORED AS TEXTFILE` 或 `ORC`。

## 执行顺序

```bash
# 1. 建库
hive -f 01_create_database.sql

# 2. 建表
hive -f 02_ddl_tables.sql

# 3. 插入数据（Hive 0.14+ 支持 INSERT INTO ... VALUES）
hive -f 03_insert_data.sql

# 4. 跑分析示例（可选）
hive -f 04_analytics_example.sql
```

或使用 Beeline：

```bash
beeline -u "jdbc:hive2://localhost:10000" -f 01_create_database.sql
beeline -u "jdbc:hive2://localhost:10000" -f 02_ddl_tables.sql
beeline -u "jdbc:hive2://localhost:10000" -f 03_insert_data.sql
```

## 与 MySQL 的协作流程（可选）

1. **MySQL**：业务库，支撑后端 API 与前端读写。
2. **数据同步**：通过 Sqoop、DataX、Canal 等将 MySQL 表增量/全量同步到 Hive（表名、字段名与本 DDL 保持一致即可）。
3. **Hive**：数仓层做离线统计、历史分析、大表 join；结果可写回 MySQL 或导出供前端报表使用。
4. **本目录**：不依赖同步工具时，可直接用 `03_insert_data.sql` 在 Hive 中生成与 MySQL 一致的示例数据，用于开发与联调。

## 注意事项

- 若 Hive 版本较低不支持 `INSERT INTO ... VALUES` 多行，可改用 `LOAD DATA LOCAL INPATH` 从 CSV 导入，或先建临时表再 INSERT SELECT。
- 本脚本未做分区设计；生产可按 `salary_cycle`、`create_time` 等做分区以提升查询性能。
