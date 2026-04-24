# 人力资源数据中心答辩映射清单（题目条目 -> 页面/接口/数据表）

## 使用说明

- 本清单用于答辩PPT逐条对照展示。
- 每个条目都给出前端页面、后端接口（控制器）、数据库表（MySQL/Hive）与核心代码文件。
- 推荐演示顺序：先“数据中心主链路”，再“业务数据源支撑”，最后“治理与闭环”。

## 1）组织效能分析

- 页面：
  - `frontend/src/views/analysis/OrgEfficiency.vue`
  - `frontend/src/views/analysis/Dashboard.vue`
- 接口：
  - `GET /api/analysis/org-efficiency/department`
  - `GET /api/analysis/org-efficiency/health`
  - 控制器：`backend/src/main/java/com/hr/datacenter/controller/analysis/AnalysisController.java`
  - 服务：`backend/src/main/java/com/hr/datacenter/service/analysis/OrgEfficiencyAnalysisService.java`
- 数据表：
  - Hive：`dim_employee`、`dim_department`（`database/hr_datacenter_hive_init.sql`）
  - MySQL源：`employee`（`database/hr_datacenter_mysql_init.sql`）

## 2）人才梯队建设

- 页面：
  - `frontend/src/views/analysis/TalentPipeline.vue`
  - `frontend/src/views/analysis/Dashboard.vue`
- 接口：
  - `GET /api/analysis/talent-pipeline/reserve`
  - `GET /api/analysis/talent-pipeline/health`
  - 控制器：`backend/src/main/java/com/hr/datacenter/controller/analysis/AnalysisController.java`
  - 服务：`backend/src/main/java/com/hr/datacenter/service/analysis/TalentPipelineAnalysisService.java`
- 数据表：
  - Hive：`dim_employee`、`fact_performance`、`fact_training`
  - MySQL源：`employee`、`performance_evaluation`、`training_enrollment`

## 3）薪酬福利分析

- 页面：
  - `frontend/src/views/analysis/SalaryAnalysis.vue`
- 接口：
  - `GET /api/analysis/salary/structure`
  - `GET /api/analysis/salary/cost`
  - 控制器：`backend/src/main/java/com/hr/datacenter/controller/analysis/AnalysisController.java`
  - 服务：`backend/src/main/java/com/hr/datacenter/service/analysis/SalaryAnalysisService.java`
- 数据表：
  - Hive：`dim_employee`、`fact_salary`、`agg_department_monthly_cost`
  - MySQL源：`salary_payment`、`salary_adjustment`

## 4）员工流失预警 / 人才缺口预警 / 成本超支预警

- 页面：
  - `frontend/src/views/analysis/WarningAnalysis.vue`
  - `frontend/src/views/analysis/Dashboard.vue`
- 接口：
  - `GET /api/warning/turnover/risk-analysis`
  - `GET /api/warning/talent-gap/analysis`
  - `GET /api/warning/cost/overrun-analysis`
  - 控制器：`backend/src/main/java/com/hr/datacenter/controller/warning/WarningController.java`
  - 服务：
    - `backend/src/main/java/com/hr/datacenter/service/warning/TurnoverWarningService.java`
    - `backend/src/main/java/com/hr/datacenter/service/warning/TalentGapWarningService.java`
    - `backend/src/main/java/com/hr/datacenter/service/warning/CostWarningService.java`
- 参数/模型：
  - MySQL：`analysis_rule`、`warning_model`
  - 管理页：`frontend/src/views/system/RuleManager.vue`、`frontend/src/views/system/ModelManager.vue`

## 5）分析看板（筛选/导出/收藏）

- 页面：
  - `frontend/src/views/analysis/Dashboard.vue`
  - `frontend/src/views/analysis/WarningAnalysis.vue`
  - `frontend/src/views/system/FavoriteCenter.vue`
- 接口：
  - `GET /api/analysis/...`（多维统计）
  - `GET /api/analysis/export`
  - `POST /api/favorite/add`、`GET /api/favorite/list`
  - 控制器：
    - `backend/src/main/java/com/hr/datacenter/controller/analysis/AnalysisController.java`
    - `backend/src/main/java/com/hr/datacenter/controller/FavoriteController.java`
- 数据表：
  - MySQL：`user_favorite`
  - Hive：`dim_employee`、各分析事实/聚合表

## 6）数据分类与报表中心（治理能力）

- 页面：
  - `frontend/src/views/category/Index.vue`
  - `frontend/src/views/system/ReportCenter.vue`
- 接口：
  - `GET/POST/PUT/DELETE /api/data-category/...`
  - `GET /api/system/report/task/list`
  - `GET /api/system/report/export-file`
  - 控制器：
    - `backend/src/main/java/com/hr/datacenter/controller/DataCategoryController.java`
    - `backend/src/main/java/com/hr/datacenter/controller/system/ReportController.java`
- 数据表：
  - MySQL：`data_category`、`report_task`、`report_execution_log`、`report_share_log`

## 7）MySQL -> Hive 数据中心链路

- 配置文件：
  - 标准模式：`backend/src/main/resources/application.yml`
  - VM兼容模式：`backend/src/main/resources/application-vm.yml`
- 数据源配置代码：
  - `backend/src/main/java/com/hr/datacenter/config/MySQLDataSourceConfig.java`
  - `backend/src/main/java/com/hr/datacenter/config/HiveDataSourceConfig.java`
- 同步任务：
  - `backend/src/main/java/com/hr/datacenter/service/sync/DataSyncService.java`
  - `backend/src/main/java/com/hr/datacenter/config/ScheduleConfig.java`
- SQL脚本：
  - MySQL：`database/hr_datacenter_mysql_init.sql`
  - Hive：`database/hr_datacenter_hive_init.sql`

## 8）答辩演示模式（新加）

- 作用：一键弱化/隐藏非核心业务菜单，仅突出数据中心主链路。
- 前端代码：
  - `frontend/src/views/Layout.vue`
  - `localStorage`键：`defenseModeEnabled`
- 后端模式识别接口：
  - `GET /api/system/runtime/profile`
  - 控制器：`backend/src/main/java/com/hr/datacenter/controller/system/RuntimeProfileController.java`

## 9）业务模块与数据中心关系（答辩可直接说）

- 业务模块（员工/考勤/请假/绩效/薪酬/培训/招聘）是“数据采集层与运营层”。
- 数据中心模块（总览/专题分析/预警/报表/规则模型）是“分析决策层”。
- 题目主线是“从业务数据沉淀 -> Hive整合分析 -> 可视化与预警决策支持”。
