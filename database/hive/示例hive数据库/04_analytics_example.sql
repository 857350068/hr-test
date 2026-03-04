-- ============================================================
-- 人力资源数据中心 - Hive 分析示例 SQL
-- 与后端 Analysis 模块、前端数据分析页 指标对齐，可用于数仓层直接跑批或报表
-- ============================================================

USE hr_db;

-- ---------- 1. 组织效能：部门人数与人均产值（与 analysis/org-efficiency 对齐）----------
SELECT
  d.dept_name,
  COUNT(DISTINCT e.id) AS emp_count,
  ROUND(SUM(s.net_salary) / NULLIF(COUNT(DISTINCT e.id), 0), 2) AS avg_net_salary
FROM sys_department d
LEFT JOIN hr_employee e ON e.department_id = d.id AND e.status = 1
LEFT JOIN hr_salary_record s ON s.employee_id = e.id AND s.salary_cycle = '2026-01'
WHERE d.status = 1
GROUP BY d.id, d.dept_name
ORDER BY emp_count DESC;

-- ---------- 2. 预警统计：按类型与级别（与 warning/statistics、Dashboard 对齐）----------
SELECT
  warning_type,
  warning_level,
  COUNT(*) AS cnt,
  SUM(CASE WHEN status = 0 THEN 1 ELSE 0 END) AS unhandled
FROM hr_warning_info
GROUP BY warning_type, warning_level
ORDER BY warning_type, warning_level;

-- ---------- 3. 培训效果：满意度与费用（与 analysis/training、HrTrainingRecord 一致）----------
SELECT
  training_type,
  COUNT(*) AS training_count,
  SUM(participant_count) AS total_participants,
  ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction,
  SUM(training_cost) AS total_cost
FROM hr_training_record
GROUP BY training_type
ORDER BY total_cost DESC;

-- ---------- 4. 绩效分布：等级与周期（与 analysis/performance、HrPerformanceRecord 一致）----------
SELECT
  performance_cycle,
  performance_level,
  COUNT(*) AS cnt,
  ROUND(AVG(performance_score), 2) AS avg_score,
  ROUND(AVG(achievement_rate), 2) AS avg_achievement
FROM hr_performance_record
GROUP BY performance_cycle, performance_level
ORDER BY performance_cycle, performance_level;

-- ---------- 5. 薪酬分布：与 analysis/compensation、HrSalaryRecord 对齐----------
SELECT
  CASE
    WHEN net_salary < 15000 THEN '0-15k'
    WHEN net_salary < 20000 THEN '15k-20k'
    WHEN net_salary < 30000 THEN '20k-30k'
    WHEN net_salary < 40000 THEN '30k-40k'
    ELSE '40k+'
  END AS salary_band,
  COUNT(*) AS emp_count
FROM hr_salary_record
WHERE salary_cycle = '2026-01'
GROUP BY
  CASE
    WHEN net_salary < 15000 THEN '0-15k'
    WHEN net_salary < 20000 THEN '15k-20k'
    WHEN net_salary < 30000 THEN '20k-30k'
    WHEN net_salary < 40000 THEN '30k-40k'
    ELSE '40k+'
  END
ORDER BY salary_band;

-- ---------- 6. 员工清单（与 data/list、HrEmployee 字段一致：emp_no, name, department, position, status）----------
SELECT
  e.emp_no,
  e.name,
  d.dept_name AS department_name,
  p.position_name AS position_name,
  e.entry_date,
  e.status
FROM hr_employee e
LEFT JOIN sys_department d ON d.id = e.department_id
LEFT JOIN hr_position p ON p.id = e.position_id
ORDER BY e.id;
