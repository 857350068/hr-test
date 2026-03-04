-- ============================================================
-- 人力资源数据中心 - Hive 表结构 DDL
-- 与 databases/mysql/init.sql、backend 实体类 字段对齐
-- 类型映射：BIGINT->BIGINT, VARCHAR->STRING, DECIMAL->DECIMAL, DATE->DATE, DATETIME/TEXT->STRING
-- ============================================================

USE hr_db;

-- ------------------------------------------------------------
-- 1. sys_role - 角色表（与 MySQL / SysRole 实体一致）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS hr_db.sys_role;
CREATE TABLE hr_db.sys_role (
  id                BIGINT        COMMENT '主键',
  role_name         STRING        COMMENT '角色名称',
  role_code         STRING        COMMENT '角色编码',
  description       STRING        COMMENT '角色描述',
  status            TINYINT       COMMENT '状态：1-正常，0-禁用',
  create_time       STRING        COMMENT '创建时间',
  update_time       STRING        COMMENT '更新时间',
  remark            STRING        COMMENT '备注'
)
COMMENT '角色表'
STORED AS PARQUET;

-- ------------------------------------------------------------
-- 2. sys_department - 部门表（与 MySQL / SysDepartment 一致）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS hr_db.sys_department;
CREATE TABLE hr_db.sys_department (
  id          BIGINT   COMMENT '主键',
  dept_name   STRING   COMMENT '部门名称',
  dept_code   STRING   COMMENT '部门编码',
  parent_id   BIGINT   COMMENT '上级部门ID',
  dept_level  INT      COMMENT '部门层级',
  leader_id   BIGINT   COMMENT '负责人ID',
  phone       STRING   COMMENT '联系电话',
  email       STRING   COMMENT '邮箱',
  sort_order  INT      COMMENT '排序',
  status      TINYINT  COMMENT '状态：1-正常，0-禁用',
  create_time STRING   COMMENT '创建时间',
  update_time STRING   COMMENT '更新时间',
  remark      STRING   COMMENT '备注'
)
COMMENT '部门表'
STORED AS PARQUET;

-- ------------------------------------------------------------
-- 3. sys_user - 用户表（与 MySQL / SysUser 一致）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS hr_db.sys_user;
CREATE TABLE hr_db.sys_user (
  id              BIGINT   COMMENT '主键',
  username        STRING   COMMENT '用户名',
  password        STRING   COMMENT '密码',
  real_name       STRING   COMMENT '真实姓名',
  email           STRING   COMMENT '邮箱',
  phone           STRING   COMMENT '手机号',
  role_id         BIGINT   COMMENT '角色ID',
  department_id   BIGINT   COMMENT '部门ID',
  status          TINYINT  COMMENT '状态：1-正常，0-禁用',
  avatar          STRING   COMMENT '头像地址',
  last_login_time STRING   COMMENT '最后登录时间',
  last_login_ip   STRING   COMMENT '最后登录IP',
  create_time     STRING   COMMENT '创建时间',
  update_time     STRING   COMMENT '更新时间',
  create_by       STRING   COMMENT '创建人',
  update_by       STRING   COMMENT '更新人',
  remark          STRING   COMMENT '备注'
)
COMMENT '用户表'
STORED AS PARQUET;

-- ------------------------------------------------------------
-- 4. hr_position - 岗位表（与 MySQL / HrPosition 一致）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS hr_db.hr_position;
CREATE TABLE hr_db.hr_position (
  id              BIGINT    COMMENT '主键',
  position_name   STRING    COMMENT '岗位名称',
  position_code  STRING    COMMENT '岗位编码',
  department_id   BIGINT    COMMENT '所属部门ID',
  position_level  INT       COMMENT '岗位级别：1-初级，2-中级，3-高级',
  is_key_position TINYINT   COMMENT '是否关键岗位：0-否，1-是',
  description     STRING    COMMENT '岗位描述',
  salary_min      DECIMAL(12,2) COMMENT '薪资下限',
  salary_max      DECIMAL(12,2) COMMENT '薪资上限',
  sort_order      INT       COMMENT '排序',
  status          TINYINT   COMMENT '状态：1-正常，0-禁用',
  create_time     STRING   COMMENT '创建时间',
  update_time     STRING   COMMENT '更新时间',
  remark          STRING   COMMENT '备注'
)
COMMENT '岗位表'
STORED AS PARQUET;

-- ------------------------------------------------------------
-- 5. hr_employee - 员工表（与 MySQL / HrEmployee 一致，emp_no/status）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS hr_db.hr_employee;
CREATE TABLE hr_db.hr_employee (
  id                BIGINT   COMMENT '主键',
  emp_no            STRING   COMMENT '员工编号',
  name              STRING   COMMENT '员工姓名',
  gender            TINYINT  COMMENT '性别：1-男，2-女',
  birth_date        STRING   COMMENT '出生日期',
  phone             STRING   COMMENT '手机号',
  email             STRING   COMMENT '邮箱',
  department_id     BIGINT   COMMENT '部门ID',
  position_id       BIGINT   COMMENT '岗位ID',
  job_level         STRING   COMMENT '职级',
  entry_date        STRING   COMMENT '入职日期',
  status            TINYINT  COMMENT '状态：1-在职，2-离职，3-休假',
  education         STRING   COMMENT '学历',
  school            STRING   COMMENT '毕业院校',
  major             STRING   COMMENT '专业',
  work_years        INT      COMMENT '工作年限',
  address           STRING   COMMENT '住址',
  emergency_contact STRING   COMMENT '紧急联系人',
  emergency_phone   STRING   COMMENT '紧急联系电话',
  create_time       STRING   COMMENT '创建时间',
  update_time       STRING   COMMENT '更新时间'
)
COMMENT '员工表'
STORED AS PARQUET;

-- ------------------------------------------------------------
-- 6. hr_data_category - 数据分类表（与 MySQL / HrDataCategory 一致）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS hr_db.hr_data_category;
CREATE TABLE hr_db.hr_data_category (
  id            BIGINT   COMMENT '主键',
  category_name STRING   COMMENT '分类名称',
  category_code STRING   COMMENT '分类编码',
  icon          STRING   COMMENT '图标',
  description   STRING   COMMENT '分类描述',
  sort_order    INT      COMMENT '排序',
  status        TINYINT  COMMENT '状态：1-正常，0-禁用',
  create_time   STRING   COMMENT '创建时间',
  update_time   STRING   COMMENT '更新时间'
)
COMMENT '数据分类表'
STORED AS PARQUET;

-- ------------------------------------------------------------
-- 7. hr_warning_rule - 预警规则表（与 MySQL / HrWarningRule 一致）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS hr_db.hr_warning_rule;
CREATE TABLE hr_db.hr_warning_rule (
  id              BIGINT         COMMENT '主键',
  rule_name       STRING         COMMENT '规则名称',
  rule_code       STRING         COMMENT '规则编码',
  rule_type       STRING         COMMENT '规则类型',
  warning_level   INT            COMMENT '预警级别：1-高，2-中，3-低',
  threshold_value DECIMAL(10,2)  COMMENT '阈值',
  threshold_unit  STRING         COMMENT '阈值单位',
  description     STRING         COMMENT '规则描述',
  status          TINYINT        COMMENT '状态：1-启用，0-禁用',
  create_time     STRING         COMMENT '创建时间',
  update_time     STRING         COMMENT '更新时间'
)
COMMENT '预警规则表'
STORED AS PARQUET;

-- ------------------------------------------------------------
-- 8. hr_warning_info - 预警信息表（与 MySQL / HrWarningInfo 一致）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS hr_db.hr_warning_info;
CREATE TABLE hr_db.hr_warning_info (
  id               BIGINT   COMMENT '主键',
  warning_rule_id  BIGINT   COMMENT '预警规则ID',
  warning_type     STRING   COMMENT '预警类型：TURNOVER/TALENT_GAP/COST等',
  warning_level    INT      COMMENT '预警级别：1-高，2-中，3-低',
  warning_content  STRING   COMMENT '预警内容',
  warning_object   STRING   COMMENT '预警对象',
  object_id        BIGINT   COMMENT '预警对象ID',
  status           TINYINT  COMMENT '状态：0-未处理，1-已处理',
  handle_time      STRING   COMMENT '处理时间',
  handle_by        STRING   COMMENT '处理人',
  handle_remark    STRING   COMMENT '处理备注',
  create_time      STRING   COMMENT '创建时间',
  update_time      STRING   COMMENT '更新时间'
)
COMMENT '预警信息表'
STORED AS PARQUET;

-- ------------------------------------------------------------
-- 9. hr_training_record - 培训记录表（与 MySQL / HrTrainingRecord 一致）
-- participant_count, satisfaction_score, training_cost, description
-- ------------------------------------------------------------
DROP TABLE IF EXISTS hr_db.hr_training_record;
CREATE TABLE hr_db.hr_training_record (
  id                 BIGINT         COMMENT '主键',
  training_name      STRING         COMMENT '培训名称',
  training_type      STRING         COMMENT '培训类型',
  department_id      BIGINT         COMMENT '部门ID',
  start_date         STRING         COMMENT '开始日期',
  end_date           STRING         COMMENT '结束日期',
  participant_count  INT            COMMENT '参与人数',
  satisfaction_score DECIMAL(3,1)   COMMENT '满意度评分',
  training_cost      DECIMAL(12,2)  COMMENT '培训费用',
  trainer            STRING         COMMENT '讲师',
  description        STRING         COMMENT '培训描述',
  create_time        STRING         COMMENT '创建时间',
  update_time        STRING         COMMENT '更新时间'
)
COMMENT '培训记录表'
STORED AS PARQUET;

-- ------------------------------------------------------------
-- 10. hr_performance_record - 绩效记录表（与 MySQL / HrPerformanceRecord 一致）
-- performance_cycle, performance_score, performance_level, achievement_rate, evaluation_date, comments
-- ------------------------------------------------------------
DROP TABLE IF EXISTS hr_db.hr_performance_record;
CREATE TABLE hr_db.hr_performance_record (
  id                 BIGINT         COMMENT '主键',
  employee_id        BIGINT         COMMENT '员工ID',
  performance_cycle  STRING         COMMENT '绩效周期',
  performance_score  DECIMAL(5,1)   COMMENT '绩效得分',
  performance_level  STRING         COMMENT '绩效等级：S/A/B/C/D',
  achievement_rate  DECIMAL(5,1)   COMMENT '目标达成率(%)',
  evaluator          STRING         COMMENT '评价人',
  evaluation_date    STRING         COMMENT '评价日期',
  comments           STRING         COMMENT '评价意见',
  create_time        STRING         COMMENT '创建时间',
  update_time        STRING         COMMENT '更新时间'
)
COMMENT '绩效记录表'
STORED AS PARQUET;

-- ------------------------------------------------------------
-- 11. hr_salary_record - 薪资记录表（与 MySQL / HrSalaryRecord 一致）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS hr_db.hr_salary_record;
CREATE TABLE hr_db.hr_salary_record (
  id                 BIGINT         COMMENT '主键',
  employee_id        BIGINT         COMMENT '员工ID',
  salary_cycle       STRING         COMMENT '薪资周期',
  basic_salary       DECIMAL(12,2)  COMMENT '基本工资',
  performance_salary DECIMAL(12,2)  COMMENT '绩效工资',
  bonus              DECIMAL(12,2)  COMMENT '奖金',
  subsidy            DECIMAL(12,2)  COMMENT '补贴',
  total_salary       DECIMAL(12,2)  COMMENT '应发工资',
  social_security    DECIMAL(12,2)  COMMENT '社保扣除',
  provident_fund     DECIMAL(12,2)  COMMENT '公积金扣除',
  tax                DECIMAL(12,2)  COMMENT '个税',
  net_salary         DECIMAL(12,2)  COMMENT '实发工资',
  pay_date           STRING         COMMENT '发薪日期',
  create_time        STRING         COMMENT '创建时间',
  update_time        STRING         COMMENT '更新时间'
)
COMMENT '薪资记录表'
STORED AS PARQUET;

-- ------------------------------------------------------------
-- 12. hr_favorite - 收藏表（与 MySQL / HrFavorite 一致，content_type/content_id/content_name）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS hr_db.hr_favorite;
CREATE TABLE hr_db.hr_favorite (
  id           BIGINT   COMMENT '主键',
  user_id      BIGINT   COMMENT '用户ID',
  content_type STRING   COMMENT '内容类型：报表/预警/档案等',
  content_id   BIGINT   COMMENT '内容ID',
  content_name STRING   COMMENT '内容名称',
  create_time  STRING   COMMENT '创建时间'
)
COMMENT '收藏表'
STORED AS PARQUET;

-- ------------------------------------------------------------
-- 13. hr_report_template - 报表模板表（与 MySQL / HrReportTemplate 一致）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS hr_db.hr_report_template;
CREATE TABLE hr_db.hr_report_template (
  id            BIGINT   COMMENT '主键',
  template_name STRING   COMMENT '模板名称',
  template_code STRING   COMMENT '模板编码',
  report_type   STRING   COMMENT '报表类型',
  description   STRING   COMMENT '报表描述',
  is_public     TINYINT  COMMENT '是否公开：1-公开，0-私有',
  create_by     STRING   COMMENT '创建人',
  create_time   STRING   COMMENT '创建时间',
  update_time   STRING   COMMENT '更新时间'
)
COMMENT '报表模板表'
STORED AS PARQUET;
