-- ============================================================================
-- MySQL 批量补数脚本（可重复执行）
-- 目标：修复页面 NoData，补齐员工/考勤/请假/绩效/薪资/培训等核心数据
-- 规模：新增约 180 名员工 + 多月业务事实数据
-- ============================================================================

USE hr_datacenter;
SET FOREIGN_KEY_CHECKS = 0;

-- 生成序列 1..180
DROP TEMPORARY TABLE IF EXISTS tmp_seq;
CREATE TEMPORARY TABLE tmp_seq (n INT PRIMARY KEY);
INSERT INTO tmp_seq (n)
WITH RECURSIVE cte AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM cte WHERE n < 180
)
SELECT n FROM cte;

-- 生成月份 2025-10 到 2026-03
DROP TEMPORARY TABLE IF EXISTS tmp_months;
CREATE TEMPORARY TABLE tmp_months (
    ym DATE PRIMARY KEY,
    y INT NOT NULL,
    m INT NOT NULL
);
INSERT INTO tmp_months (ym, y, m)
WITH RECURSIVE mth AS (
    SELECT DATE('2025-10-01') AS ym
    UNION ALL
    SELECT DATE_ADD(ym, INTERVAL 1 MONTH) FROM mth WHERE ym < DATE('2026-03-01')
)
SELECT ym, YEAR(ym), MONTH(ym) FROM mth;

-- 生成最近 60 天序列
DROP TEMPORARY TABLE IF EXISTS tmp_days;
CREATE TEMPORARY TABLE tmp_days (d INT PRIMARY KEY);
INSERT INTO tmp_days (d)
WITH RECURSIVE day_seq AS (
    SELECT 0 AS d
    UNION ALL
    SELECT d + 1 FROM day_seq WHERE d < 59
)
SELECT d FROM day_seq;

-- 1) 员工主数据（新增 EMP1001+）
INSERT INTO employee (
    emp_no, emp_name, gender, birth_date, id_card, phone, email, department, position,
    salary, hire_date, resign_date, status, education
)
SELECT
    CONCAT('EMP', LPAD(1000 + s.n, 4, '0')) AS emp_no,
    CONCAT(
        CASE MOD(s.n, 30)
            WHEN 0 THEN '王' WHEN 1 THEN '李' WHEN 2 THEN '张' WHEN 3 THEN '刘' WHEN 4 THEN '陈'
            WHEN 5 THEN '杨' WHEN 6 THEN '赵' WHEN 7 THEN '黄' WHEN 8 THEN '周' WHEN 9 THEN '吴'
            WHEN 10 THEN '徐' WHEN 11 THEN '孙' WHEN 12 THEN '马' WHEN 13 THEN '朱' WHEN 14 THEN '胡'
            WHEN 15 THEN '郭' WHEN 16 THEN '何' WHEN 17 THEN '高' WHEN 18 THEN '林' WHEN 19 THEN '罗'
            WHEN 20 THEN '郑' WHEN 21 THEN '梁' WHEN 22 THEN '谢' WHEN 23 THEN '宋' WHEN 24 THEN '唐'
            WHEN 25 THEN '韩' WHEN 26 THEN '冯' WHEN 27 THEN '于' WHEN 28 THEN '董' ELSE '萧'
        END,
        CASE MOD(s.n, 40)
            WHEN 0 THEN '伟' WHEN 1 THEN '芳' WHEN 2 THEN '娜' WHEN 3 THEN '敏' WHEN 4 THEN '磊'
            WHEN 5 THEN '静' WHEN 6 THEN '洋' WHEN 7 THEN '强' WHEN 8 THEN '涛' WHEN 9 THEN '杰'
            WHEN 10 THEN '琳' WHEN 11 THEN '雪' WHEN 12 THEN '博' WHEN 13 THEN '晨' WHEN 14 THEN '宇'
            WHEN 15 THEN '轩' WHEN 16 THEN '雨桐' WHEN 17 THEN '子涵' WHEN 18 THEN '思远' WHEN 19 THEN '佳宁'
            WHEN 20 THEN '浩然' WHEN 21 THEN '梦瑶' WHEN 22 THEN '文博' WHEN 23 THEN '欣怡' WHEN 24 THEN '梓轩'
            WHEN 25 THEN '雅婷' WHEN 26 THEN '俊豪' WHEN 27 THEN '明轩' WHEN 28 THEN '嘉怡' WHEN 29 THEN '天宇'
            WHEN 30 THEN '晓彤' WHEN 31 THEN '诗涵' WHEN 32 THEN '瑞泽' WHEN 33 THEN '心怡' WHEN 34 THEN '乐天'
            WHEN 35 THEN '亦凡' WHEN 36 THEN '俊杰' WHEN 37 THEN '雨晨' WHEN 38 THEN '家豪' ELSE '若曦'
        END
    ) AS emp_name,
    MOD(s.n, 2) AS gender,
    DATE_ADD('1988-01-01', INTERVAL MOD(s.n * 37, 9500) DAY) AS birth_date,
    CONCAT('430101', DATE_FORMAT(DATE_ADD('1988-01-01', INTERVAL MOD(s.n * 37, 9500) DAY), '%Y%m%d'), LPAD(MOD(1000 + s.n, 4), 4, '0')) AS id_card,
    CONCAT('13', LPAD(200000000 + s.n, 9, '0')) AS phone,
    CONCAT('emp', 1000 + s.n, '@hrdatacenter.local') AS email,
    CASE MOD(s.n, 8)
        WHEN 0 THEN '技术部'
        WHEN 1 THEN '研发部'
        WHEN 2 THEN '市场部'
        WHEN 3 THEN '人力资源部'
        WHEN 4 THEN '财务部'
        WHEN 5 THEN '运营部'
        WHEN 6 THEN '客服部'
        ELSE '行政部'
    END AS department,
    CASE MOD(s.n, 10)
        WHEN 0 THEN '高级工程师'
        WHEN 1 THEN '开发工程师'
        WHEN 2 THEN '产品经理'
        WHEN 3 THEN '测试工程师'
        WHEN 4 THEN '算法工程师'
        WHEN 5 THEN '运营专员'
        WHEN 6 THEN '招聘专员'
        WHEN 7 THEN '会计'
        WHEN 8 THEN '销售经理'
        ELSE '数据分析师'
    END AS position,
    ROUND(
        7000
        + MOD(s.n, 15) * 900
        + CASE
            WHEN MOD(s.n, 8) IN (0, 1) THEN 2500
            WHEN MOD(s.n, 8) = 2 THEN 1800
            WHEN MOD(s.n, 8) = 4 THEN 1200
            ELSE 900
          END
    , 2) AS salary,
    DATE_ADD('2016-01-01', INTERVAL MOD(s.n * 23, 3300) DAY) AS hire_date,
    CASE
        WHEN MOD(s.n, 17) = 0 THEN DATE_ADD(DATE_ADD('2016-01-01', INTERVAL MOD(s.n * 23, 3300) DAY), INTERVAL (300 + MOD(s.n, 700)) DAY)
        ELSE NULL
    END AS resign_date,
    CASE
        WHEN MOD(s.n, 17) = 0 THEN 0
        WHEN MOD(s.n, 13) = 0 THEN 2
        ELSE 1
    END AS status,
    CASE MOD(s.n, 5)
        WHEN 0 THEN '本科'
        WHEN 1 THEN '硕士'
        WHEN 2 THEN '本科'
        WHEN 3 THEN '大专'
        ELSE '博士'
    END AS education
FROM tmp_seq s
ON DUPLICATE KEY UPDATE
    emp_name = VALUES(emp_name),
    salary = VALUES(salary),
    department = VALUES(department),
    position = VALUES(position),
    status = VALUES(status),
    education = VALUES(education),
    update_time = NOW();

-- 2) 考勤（最近 60 天工作日）
DELETE FROM attendance WHERE remark = 'AUTO_GEN_BULK';
INSERT INTO attendance (
    emp_id, attendance_date, clock_in_time, clock_out_time,
    attendance_type, attendance_status, work_duration, remark
)
SELECT
    e.emp_id,
    DATE_SUB(CURDATE(), INTERVAL d.d DAY) AS attendance_date,
    MAKETIME(8 + MOD(e.emp_id + d.d, 2), MOD(e.emp_id + d.d, 6) * 10, 0) AS clock_in_time,
    MAKETIME(18 + MOD(e.emp_id + d.d, 3), MOD(e.emp_id + d.d, 6) * 5, 0) AS clock_out_time,
    CASE
        WHEN MOD(e.emp_id + d.d, 33) = 0 THEN 5
        WHEN MOD(e.emp_id + d.d, 21) = 0 THEN 1
        ELSE 0
    END AS attendance_type,
    CASE
        WHEN MOD(e.emp_id + d.d, 33) = 0 THEN 3
        ELSE 1
    END AS attendance_status,
    510 + MOD(e.emp_id * 7 + d.d * 13, 120) AS work_duration,
    'AUTO_GEN_BULK' AS remark
FROM employee e
JOIN tmp_days d ON 1 = 1
WHERE e.deleted = 0
  AND e.status IN (1, 2)
  AND e.emp_no LIKE 'EMP1%'
  AND WEEKDAY(DATE_SUB(CURDATE(), INTERVAL d.d DAY)) < 5;

-- 3) 请假
DELETE FROM emp_leave WHERE reason LIKE 'AUTO_GEN_BULK%';
INSERT INTO emp_leave (
    emp_id, leave_type, start_time, end_time, leave_duration,
    reason, approver_id, approval_status, approval_comment, approval_time
)
SELECT
    e.emp_id,
    MOD(e.emp_id, 3) AS leave_type,
    DATE_ADD(CURDATE(), INTERVAL -MOD(e.emp_id, 40) DAY),
    DATE_ADD(DATE_ADD(CURDATE(), INTERVAL -MOD(e.emp_id, 40) DAY), INTERVAL 1 DAY),
    16,
    'AUTO_GEN_BULK-业务请假',
    1,
    1,
    '批量补数自动审批',
    NOW()
FROM employee e
WHERE e.deleted = 0
  AND e.status IN (1, 2)
  AND e.emp_no LIKE 'EMP1%'
  AND MOD(e.emp_id, 19) = 0;

-- 4) 绩效目标
DELETE FROM performance_goal WHERE goal_description LIKE 'AUTO_GEN_BULK%';
INSERT INTO performance_goal (
    emp_id, year, period_type, goal_description, weight, completion_standard, goal_status
)
SELECT
    e.emp_id,
    2025,
    1,
    CONCAT('AUTO_GEN_BULK-年度目标-', e.position),
    100,
    '达成岗位核心目标并完成月度复盘',
    1
FROM employee e
WHERE e.deleted = 0
  AND e.status IN (1, 2)
  AND e.emp_no LIKE 'EMP1%';

-- 5) 绩效评估（2025 年四个季度）
DROP TEMPORARY TABLE IF EXISTS tmp_quarters;
CREATE TEMPORARY TABLE tmp_quarters (q INT PRIMARY KEY);
INSERT INTO tmp_quarters (q) VALUES (1), (2), (3), (4);

DELETE FROM performance_evaluation WHERE self_comment LIKE 'AUTO_GEN_BULK%';
INSERT INTO performance_evaluation (
    emp_id, year, period_type, quarter, month,
    self_score, self_comment, supervisor_score, supervisor_comment,
    final_score, performance_level, improvement_plan, interview_record, interview_date, evaluation_status
)
SELECT
    e.emp_id,
    2025,
    2,
    q.q,
    NULL,
    ROUND(75 + MOD(e.emp_id + q.q * 7, 25) + MOD(e.emp_id, 10) / 10, 2) AS self_score,
    'AUTO_GEN_BULK-员工自评',
    ROUND(76 + MOD(e.emp_id + q.q * 9, 23) + MOD(e.emp_id, 10) / 10, 2) AS supervisor_score,
    'AUTO_GEN_BULK-主管评语',
    ROUND((ROUND(75 + MOD(e.emp_id + q.q * 7, 25) + MOD(e.emp_id, 10) / 10, 2) * 0.4)
        + (ROUND(76 + MOD(e.emp_id + q.q * 9, 23) + MOD(e.emp_id, 10) / 10, 2) * 0.6), 2) AS final_score,
    CASE
        WHEN ((75 + MOD(e.emp_id + q.q * 7, 25)) * 0.4 + (76 + MOD(e.emp_id + q.q * 9, 23)) * 0.6) >= 90 THEN 'S'
        WHEN ((75 + MOD(e.emp_id + q.q * 7, 25)) * 0.4 + (76 + MOD(e.emp_id + q.q * 9, 23)) * 0.6) >= 80 THEN 'A'
        WHEN ((75 + MOD(e.emp_id + q.q * 7, 25)) * 0.4 + (76 + MOD(e.emp_id + q.q * 9, 23)) * 0.6) >= 70 THEN 'B'
        WHEN ((75 + MOD(e.emp_id + q.q * 7, 25)) * 0.4 + (76 + MOD(e.emp_id + q.q * 9, 23)) * 0.6) >= 60 THEN 'C'
        ELSE 'D'
    END AS performance_level,
    'AUTO_GEN_BULK-持续改进',
    'AUTO_GEN_BULK-季度面谈',
    DATE_ADD('2025-01-15', INTERVAL (q.q - 1) * 90 DAY),
    3
FROM employee e
JOIN tmp_quarters q ON 1 = 1
WHERE e.deleted = 0
  AND e.status IN (1, 2)
  AND e.emp_no LIKE 'EMP1%';

-- 6) 薪资发放（6 个月）
INSERT INTO salary_payment (
    emp_id, year, month,
    basic_salary, performance_salary,
    position_allowance, transport_allowance, communication_allowance, meal_allowance, other_allowance,
    overtime_pay, total_gross_salary,
    social_insurance, housing_fund, income_tax, other_deduction,
    total_net_salary, payment_status, payment_date, remark
)
SELECT
    e.emp_id,
    m.y,
    m.m,
    ROUND(e.salary * (0.90 + MOD(e.emp_id + m.m, 4) * 0.03), 2) AS basic_salary,
    ROUND(e.salary * (0.10 + MOD(e.emp_id + m.m, 5) * 0.02), 2) AS performance_salary,
    ROUND(500 + MOD(e.emp_id, 8) * 120, 2) AS position_allowance,
    300.00 AS transport_allowance,
    200.00 AS communication_allowance,
    300.00 AS meal_allowance,
    0.00 AS other_allowance,
    ROUND(MOD(e.emp_id + m.m, 6) * 120, 2) AS overtime_pay,
    ROUND(
        ROUND(e.salary * (0.90 + MOD(e.emp_id + m.m, 4) * 0.03), 2)
        + ROUND(e.salary * (0.10 + MOD(e.emp_id + m.m, 5) * 0.02), 2)
        + ROUND(500 + MOD(e.emp_id, 8) * 120, 2)
        + 300 + 200 + 300 + ROUND(MOD(e.emp_id + m.m, 6) * 120, 2)
    , 2) AS total_gross_salary,
    ROUND(e.salary * 0.08, 2) AS social_insurance,
    ROUND(e.salary * 0.08, 2) AS housing_fund,
    ROUND(e.salary * 0.03, 2) AS income_tax,
    0.00 AS other_deduction,
    ROUND(
        ROUND(
            ROUND(e.salary * (0.90 + MOD(e.emp_id + m.m, 4) * 0.03), 2)
            + ROUND(e.salary * (0.10 + MOD(e.emp_id + m.m, 5) * 0.02), 2)
            + ROUND(500 + MOD(e.emp_id, 8) * 120, 2)
            + 300 + 200 + 300 + ROUND(MOD(e.emp_id + m.m, 6) * 120, 2)
        , 2)
        - ROUND(e.salary * 0.08, 2)
        - ROUND(e.salary * 0.08, 2)
        - ROUND(e.salary * 0.03, 2)
    , 2) AS total_net_salary,
    1 AS payment_status,
    LAST_DAY(m.ym) AS payment_date,
    'AUTO_GEN_BULK'
FROM employee e
JOIN tmp_months m ON 1 = 1
WHERE e.deleted = 0
  AND e.status IN (1, 2)
  AND e.emp_no LIKE 'EMP1%'
ON DUPLICATE KEY UPDATE
    basic_salary = VALUES(basic_salary),
    performance_salary = VALUES(performance_salary),
    total_gross_salary = VALUES(total_gross_salary),
    total_net_salary = VALUES(total_net_salary),
    payment_status = VALUES(payment_status),
    payment_date = VALUES(payment_date),
    remark = VALUES(remark),
    update_time = NOW();

-- 7) 薪资调整
DELETE FROM salary_adjustment WHERE reason LIKE 'AUTO_GEN_BULK%';
INSERT INTO salary_adjustment (
    emp_id, adjustment_type, before_salary, after_salary, adjustment_rate, effective_date,
    reason, approver_id, approval_status, approval_comment, approval_date, creator_id
)
SELECT
    e.emp_id,
    3,
    ROUND(e.salary * 0.95, 2),
    e.salary,
    ROUND((e.salary - ROUND(e.salary * 0.95, 2)) / ROUND(e.salary * 0.95, 2) * 100, 2),
    DATE('2025-01-01'),
    'AUTO_GEN_BULK-年度调薪',
    1,
    1,
    '批量补数自动通过',
    NOW(),
    1
FROM employee e
WHERE e.deleted = 0
  AND e.status IN (1, 2)
  AND e.emp_no LIKE 'EMP1%'
  AND MOD(e.emp_id, 10) = 0;

-- 8) 培训课程 + 报名
DELETE FROM training_enrollment WHERE feedback = 'AUTO_GEN_BULK';
DELETE FROM training_course WHERE course_name LIKE 'AUTO_GEN_BULK课程%';

INSERT INTO training_course (
    course_name, course_type, course_description, instructor, duration, location,
    start_date, end_date, capacity, enrolled_count, course_status
)
SELECT
    CONCAT('AUTO_GEN_BULK课程', LPAD(s.n, 2, '0')),
    MOD(s.n, 5) + 1,
    '批量补数课程',
    CONCAT('讲师', s.n),
    8 + MOD(s.n, 4) * 4,
    CONCAT('培训室', CHAR(65 + MOD(s.n, 5))),
    DATE_ADD('2026-01-01 09:00:00', INTERVAL s.n DAY),
    DATE_ADD('2026-01-01 17:00:00', INTERVAL s.n DAY),
    30 + MOD(s.n, 3) * 10,
    0,
    0
FROM (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
    UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
) s;

DROP TEMPORARY TABLE IF EXISTS tmp_training_course_ids;
CREATE TEMPORARY TABLE tmp_training_course_ids (
    course_id BIGINT PRIMARY KEY
);
INSERT INTO tmp_training_course_ids (course_id)
SELECT course_id
FROM training_course
WHERE course_name LIKE 'AUTO_GEN_BULK课程%';

INSERT INTO training_enrollment (
    course_id, emp_id, enrollment_time, approval_status, approver_id, attendance_status, score, feedback
)
SELECT
    c.course_id,
    e.emp_id,
    DATE_SUB(NOW(), INTERVAL MOD(e.emp_id, 20) DAY),
    1,
    1,
    CASE WHEN MOD(e.emp_id, 10) = 0 THEN 2 ELSE 1 END,
    70 + MOD(e.emp_id, 31),
    'AUTO_GEN_BULK'
FROM tmp_training_course_ids c
JOIN employee e ON e.deleted = 0 AND e.status IN (1, 2) AND e.emp_no LIKE 'EMP1%'
WHERE MOD(e.emp_id + c.course_id, 9) = 0;

-- 8.1) 清洗历史脏姓名（数字名/新增员工/测试员工/Hive前缀）
UPDATE employee
SET emp_name = CONCAT(
    CASE MOD(emp_id, 30)
        WHEN 0 THEN '王' WHEN 1 THEN '李' WHEN 2 THEN '张' WHEN 3 THEN '刘' WHEN 4 THEN '陈'
        WHEN 5 THEN '杨' WHEN 6 THEN '赵' WHEN 7 THEN '黄' WHEN 8 THEN '周' WHEN 9 THEN '吴'
        WHEN 10 THEN '徐' WHEN 11 THEN '孙' WHEN 12 THEN '马' WHEN 13 THEN '朱' WHEN 14 THEN '胡'
        WHEN 15 THEN '郭' WHEN 16 THEN '何' WHEN 17 THEN '高' WHEN 18 THEN '林' WHEN 19 THEN '罗'
        WHEN 20 THEN '郑' WHEN 21 THEN '梁' WHEN 22 THEN '谢' WHEN 23 THEN '宋' WHEN 24 THEN '唐'
        WHEN 25 THEN '韩' WHEN 26 THEN '冯' WHEN 27 THEN '于' WHEN 28 THEN '董' ELSE '萧'
    END,
    CASE MOD(emp_id, 40)
        WHEN 0 THEN '伟' WHEN 1 THEN '芳' WHEN 2 THEN '娜' WHEN 3 THEN '敏' WHEN 4 THEN '磊'
        WHEN 5 THEN '静' WHEN 6 THEN '洋' WHEN 7 THEN '强' WHEN 8 THEN '涛' WHEN 9 THEN '杰'
        WHEN 10 THEN '琳' WHEN 11 THEN '雪' WHEN 12 THEN '博' WHEN 13 THEN '晨' WHEN 14 THEN '宇'
        WHEN 15 THEN '轩' WHEN 16 THEN '雨桐' WHEN 17 THEN '子涵' WHEN 18 THEN '思远' WHEN 19 THEN '佳宁'
        WHEN 20 THEN '浩然' WHEN 21 THEN '梦瑶' WHEN 22 THEN '文博' WHEN 23 THEN '欣怡' WHEN 24 THEN '梓轩'
        WHEN 25 THEN '雅婷' WHEN 26 THEN '俊豪' WHEN 27 THEN '明轩' WHEN 28 THEN '嘉怡' WHEN 29 THEN '天宇'
        WHEN 30 THEN '晓彤' WHEN 31 THEN '诗涵' WHEN 32 THEN '瑞泽' WHEN 33 THEN '心怡' WHEN 34 THEN '乐天'
        WHEN 35 THEN '亦凡' WHEN 36 THEN '俊杰' WHEN 37 THEN '雨晨' WHEN 38 THEN '家豪' ELSE '若曦'
    END
)
WHERE deleted = 0
  AND (emp_name REGEXP '[0-9]' OR emp_name LIKE '员工%' OR emp_name LIKE '新增员工%' OR emp_name LIKE '测试员工%' OR emp_name LIKE 'Hive%');

-- 9) 兼容分析模块：确保 dim_employee 可查
CREATE OR REPLACE VIEW dim_employee AS
SELECT
    emp_id,
    emp_no,
    emp_name,
    gender,
    birth_date,
    id_card,
    phone,
    email,
    department,
    position,
    salary AS current_salary,
    hire_date,
    resign_date,
    status,
    education,
    DATE_FORMAT(COALESCE(update_time, create_time, NOW()), '%Y%m%d') AS dt
FROM employee
WHERE deleted = 0;

SET FOREIGN_KEY_CHECKS = 1;

SELECT
    'MySQL批量补数完成' AS status,
    (SELECT COUNT(*) FROM employee WHERE deleted = 0) AS employee_count,
    (SELECT COUNT(*) FROM attendance WHERE deleted = 0) AS attendance_count,
    (SELECT COUNT(*) FROM salary_payment WHERE deleted = 0) AS salary_payment_count,
    (SELECT COUNT(*) FROM performance_evaluation WHERE deleted = 0) AS performance_eval_count;
