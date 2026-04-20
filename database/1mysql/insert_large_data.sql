-- ============================================================================
-- MySQL 大规模补数脚本（扩容版）
-- 用途：在 insert_data.sql 基础上继续扩容，解决更多页面 NoData 场景
-- 规模：额外新增约 240 名员工 + 120 天考勤 + 12 个月薪资
-- ============================================================================

USE hr_datacenter;
SET FOREIGN_KEY_CHECKS = 0;

-- 序列：181..420
DROP TEMPORARY TABLE IF EXISTS tmp_seq_large;
CREATE TEMPORARY TABLE tmp_seq_large (n INT PRIMARY KEY);
INSERT INTO tmp_seq_large (n)
WITH RECURSIVE cte AS (
    SELECT 181 AS n
    UNION ALL
    SELECT n + 1 FROM cte WHERE n < 420
)
SELECT n FROM cte;

-- 月份：2025-01..2025-12
DROP TEMPORARY TABLE IF EXISTS tmp_months_large;
CREATE TEMPORARY TABLE tmp_months_large (
    ym DATE PRIMARY KEY,
    y INT NOT NULL,
    m INT NOT NULL
);
INSERT INTO tmp_months_large (ym, y, m)
WITH RECURSIVE mth AS (
    SELECT DATE('2025-01-01') AS ym
    UNION ALL
    SELECT DATE_ADD(ym, INTERVAL 1 MONTH) FROM mth WHERE ym < DATE('2025-12-01')
)
SELECT ym, YEAR(ym), MONTH(ym) FROM mth;

-- 天序列：0..119
DROP TEMPORARY TABLE IF EXISTS tmp_days_large;
CREATE TEMPORARY TABLE tmp_days_large (d INT PRIMARY KEY);
INSERT INTO tmp_days_large (d)
WITH RECURSIVE ds AS (
    SELECT 0 AS d
    UNION ALL
    SELECT d + 1 FROM ds WHERE d < 119
)
SELECT d FROM ds;

-- 1) 扩容员工
INSERT INTO employee (
    emp_no, emp_name, gender, birth_date, id_card, phone, email, department, position,
    salary, hire_date, resign_date, status, education
)
SELECT
    CONCAT('EMP', LPAD(1000 + s.n, 4, '0')) AS emp_no,
    CONCAT(
        CASE MOD(s.n + 7, 30)
            WHEN 0 THEN '王' WHEN 1 THEN '李' WHEN 2 THEN '张' WHEN 3 THEN '刘' WHEN 4 THEN '陈'
            WHEN 5 THEN '杨' WHEN 6 THEN '赵' WHEN 7 THEN '黄' WHEN 8 THEN '周' WHEN 9 THEN '吴'
            WHEN 10 THEN '徐' WHEN 11 THEN '孙' WHEN 12 THEN '马' WHEN 13 THEN '朱' WHEN 14 THEN '胡'
            WHEN 15 THEN '郭' WHEN 16 THEN '何' WHEN 17 THEN '高' WHEN 18 THEN '林' WHEN 19 THEN '罗'
            WHEN 20 THEN '郑' WHEN 21 THEN '梁' WHEN 22 THEN '谢' WHEN 23 THEN '宋' WHEN 24 THEN '唐'
            WHEN 25 THEN '韩' WHEN 26 THEN '冯' WHEN 27 THEN '于' WHEN 28 THEN '董' ELSE '萧'
        END,
        CASE MOD(s.n + 11, 40)
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
    DATE_ADD('1986-01-01', INTERVAL MOD(s.n * 29, 12000) DAY) AS birth_date,
    CONCAT('440101', DATE_FORMAT(DATE_ADD('1986-01-01', INTERVAL MOD(s.n * 29, 12000) DAY), '%Y%m%d'), LPAD(MOD(2000 + s.n, 4), 4, '0')) AS id_card,
    CONCAT('15', LPAD(300000000 + s.n, 9, '0')) AS phone,
    CONCAT('bulk', 1000 + s.n, '@hrdatacenter.local') AS email,
    CASE MOD(s.n, 10)
        WHEN 0 THEN '技术部'
        WHEN 1 THEN '研发部'
        WHEN 2 THEN '市场部'
        WHEN 3 THEN '人力资源部'
        WHEN 4 THEN '财务部'
        WHEN 5 THEN '运营部'
        WHEN 6 THEN '客服部'
        WHEN 7 THEN '行政部'
        WHEN 8 THEN '法务部'
        ELSE '供应链部'
    END AS department,
    CASE MOD(s.n, 12)
        WHEN 0 THEN '高级工程师'
        WHEN 1 THEN '开发工程师'
        WHEN 2 THEN '测试工程师'
        WHEN 3 THEN '产品经理'
        WHEN 4 THEN '数据分析师'
        WHEN 5 THEN '运营专员'
        WHEN 6 THEN '招聘专员'
        WHEN 7 THEN '会计'
        WHEN 8 THEN '销售代表'
        WHEN 9 THEN '客服专员'
        WHEN 10 THEN '法务专员'
        ELSE '采购专员'
    END AS position,
    ROUND(7600 + MOD(s.n, 20) * 860 + MOD(s.n, 7) * 170, 2) AS salary,
    DATE_ADD('2014-01-01', INTERVAL MOD(s.n * 17, 4100) DAY) AS hire_date,
    CASE
        WHEN MOD(s.n, 23) = 0 THEN DATE_ADD('2022-01-01', INTERVAL MOD(s.n, 520) DAY)
        ELSE NULL
    END AS resign_date,
    CASE
        WHEN MOD(s.n, 23) = 0 THEN 0
        WHEN MOD(s.n, 14) = 0 THEN 2
        ELSE 1
    END AS status,
    CASE MOD(s.n, 6)
        WHEN 0 THEN '本科'
        WHEN 1 THEN '硕士'
        WHEN 2 THEN '本科'
        WHEN 3 THEN '大专'
        WHEN 4 THEN '博士'
        ELSE '本科'
    END AS education
FROM tmp_seq_large s
ON DUPLICATE KEY UPDATE
    emp_name = VALUES(emp_name),
    salary = VALUES(salary),
    department = VALUES(department),
    position = VALUES(position),
    status = VALUES(status),
    education = VALUES(education),
    update_time = NOW();

-- 2) 考勤扩容（120 天，工作日）
DELETE FROM attendance WHERE remark = 'AUTO_GEN_BULK_LARGE';
INSERT INTO attendance (
    emp_id, attendance_date, clock_in_time, clock_out_time,
    attendance_type, attendance_status, work_duration, remark
)
SELECT
    e.emp_id,
    DATE_SUB(CURDATE(), INTERVAL d.d DAY),
    MAKETIME(8 + MOD(e.emp_id + d.d, 3), MOD(e.emp_id + d.d, 6) * 10, 0),
    MAKETIME(18 + MOD(e.emp_id + d.d, 4), MOD(e.emp_id + d.d, 6) * 10, 0),
    CASE
        WHEN MOD(e.emp_id + d.d, 29) = 0 THEN 5
        WHEN MOD(e.emp_id + d.d, 17) = 0 THEN 1
        WHEN MOD(e.emp_id + d.d, 61) = 0 THEN 4
        ELSE 0
    END,
    CASE
        WHEN MOD(e.emp_id + d.d, 29) = 0 THEN 3
        WHEN MOD(e.emp_id + d.d, 61) = 0 THEN 2
        ELSE 1
    END,
    500 + MOD(e.emp_id * 11 + d.d * 7, 150),
    'AUTO_GEN_BULK_LARGE'
FROM employee e
JOIN tmp_days_large d ON 1 = 1
WHERE e.deleted = 0
  AND e.status IN (1, 2)
  AND e.emp_no LIKE 'EMP1%'
  AND WEEKDAY(DATE_SUB(CURDATE(), INTERVAL d.d DAY)) < 5;

-- 3) 薪资发放扩容（12 个月）
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
    ROUND(e.salary * (0.88 + MOD(e.emp_id + m.m, 5) * 0.025), 2),
    ROUND(e.salary * (0.12 + MOD(e.emp_id + m.m, 6) * 0.015), 2),
    ROUND(600 + MOD(e.emp_id, 9) * 110, 2),
    320.00,
    220.00,
    320.00,
    0.00,
    ROUND(MOD(e.emp_id + m.m, 8) * 130, 2),
    ROUND(
        ROUND(e.salary * (0.88 + MOD(e.emp_id + m.m, 5) * 0.025), 2)
        + ROUND(e.salary * (0.12 + MOD(e.emp_id + m.m, 6) * 0.015), 2)
        + ROUND(600 + MOD(e.emp_id, 9) * 110, 2)
        + 320 + 220 + 320
        + ROUND(MOD(e.emp_id + m.m, 8) * 130, 2)
    , 2),
    ROUND(e.salary * 0.08, 2),
    ROUND(e.salary * 0.08, 2),
    ROUND(e.salary * 0.035, 2),
    0.00,
    ROUND(
        ROUND(
            ROUND(e.salary * (0.88 + MOD(e.emp_id + m.m, 5) * 0.025), 2)
            + ROUND(e.salary * (0.12 + MOD(e.emp_id + m.m, 6) * 0.015), 2)
            + ROUND(600 + MOD(e.emp_id, 9) * 110, 2)
            + 320 + 220 + 320
            + ROUND(MOD(e.emp_id + m.m, 8) * 130, 2)
        , 2)
        - ROUND(e.salary * 0.08, 2)
        - ROUND(e.salary * 0.08, 2)
        - ROUND(e.salary * 0.035, 2)
    , 2),
    1,
    LAST_DAY(m.ym),
    'AUTO_GEN_BULK_LARGE'
FROM employee e
JOIN tmp_months_large m ON 1 = 1
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

-- 4) 兼容分析模块的视图
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
    'MySQL大规模补数完成' AS status,
    (SELECT COUNT(*) FROM employee WHERE deleted = 0) AS employee_count,
    (SELECT COUNT(*) FROM attendance WHERE deleted = 0) AS attendance_count,
    (SELECT COUNT(*) FROM salary_payment WHERE deleted = 0) AS salary_payment_count,
    (SELECT COUNT(*) FROM employee WHERE deleted = 0 AND (emp_name REGEXP '[0-9]' OR emp_name LIKE '员工%' OR emp_name LIKE '新增员工%' OR emp_name LIKE '测试员工%' OR emp_name LIKE 'Hive%')) AS invalid_name_count;
