-- =====================================================
-- Hive数据仓库数据插入SQL脚本（最终版）
-- 项目: 人力资源数据中心
-- 数据库: hr_datacenter_dw
-- 功能: 从MySQL同步数据到Hive数据仓库
-- 数据量: 约10万条记录
-- 创建时间: 2026-04-05
-- =====================================================

USE hr_datacenter_dw;

-- =====================================================
-- 第一步: 插入日期维度数据（10年：2015-2024）
-- =====================================================

-- 2015年数据
INSERT INTO TABLE dim_date
SELECT
    CAST(CONCAT('2015', LPAD(month, 2, '0'), LPAD(day, 2, '0')) AS INT) AS date_id,
    CONCAT('2015-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')) AS full_date,
    2015 AS year,
    CEIL(month / 3.0) AS quarter,
    month AS month,
    day AS day,
    DAYOFWEEK(CONCAT('2015-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) AS day_of_week,
    DATEDIFF(CONCAT('2015-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')),
             CONCAT('2015-01-01')) + 1 AS day_of_year,
    CASE WHEN DAYOFWEEK(CONCAT('2015-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend,
    0 AS is_holiday,
    CURRENT_TIMESTAMP AS etl_time
FROM (
    SELECT 1 AS month UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
    SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL
    SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
) m
CROSS JOIN (
    SELECT 1 AS day UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL
    SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL
    SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL
    SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL
    SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31
) d
WHERE NOT (month = 2 AND day > 28)
  AND NOT ((month IN (4, 6, 9, 11)) AND day > 30);

-- 2016年数据
INSERT INTO TABLE dim_date
SELECT
    CAST(CONCAT('2016', LPAD(month, 2, '0'), LPAD(day, 2, '0')) AS INT) AS date_id,
    CONCAT('2016-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')) AS full_date,
    2016 AS year,
    CEIL(month / 3.0) AS quarter,
    month AS month,
    day AS day,
    DAYOFWEEK(CONCAT('2016-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) AS day_of_week,
    DATEDIFF(CONCAT('2016-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')),
             CONCAT('2016-01-01')) + 1 AS day_of_year,
    CASE WHEN DAYOFWEEK(CONCAT('2016-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend,
    0 AS is_holiday,
    CURRENT_TIMESTAMP AS etl_time
FROM (
    SELECT 1 AS month UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
    SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL
    SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
) m
CROSS JOIN (
    SELECT 1 AS day UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL
    SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL
    SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL
    SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL
    SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31
) d
WHERE NOT (month = 2 AND day > 29)
  AND NOT ((month IN (4, 6, 9, 11)) AND day > 30);

-- 2017年数据
INSERT INTO TABLE dim_date
SELECT
    CAST(CONCAT('2017', LPAD(month, 2, '0'), LPAD(day, 2, '0')) AS INT) AS date_id,
    CONCAT('2017-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')) AS full_date,
    2017 AS year,
    CEIL(month / 3.0) AS quarter,
    month AS month,
    day AS day,
    DAYOFWEEK(CONCAT('2017-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) AS day_of_week,
    DATEDIFF(CONCAT('2017-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')),
             CONCAT('2017-01-01')) + 1 AS day_of_year,
    CASE WHEN DAYOFWEEK(CONCAT('2017-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend,
    0 AS is_holiday,
    CURRENT_TIMESTAMP AS etl_time
FROM (
    SELECT 1 AS month UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
) m
CROSS JOIN (
    SELECT 1 AS day UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL
    SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL
    SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL
    SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL
    SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31
) d
WHERE NOT (month = 2 AND day > 28)
  AND NOT ((month IN (4, 6, 9, 11)) AND day > 30);

-- 2018年数据
INSERT INTO TABLE dim_date
SELECT
    CAST(CONCAT('2018', LPAD(month, 2, '0'), LPAD(day, 2, '0')) AS INT) AS date_id,
    CONCAT('2018-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')) AS full_date,
    2018 AS year,
    CEIL(month / 3.0) AS quarter,
    month AS month,
    day AS day,
    DAYOFWEEK(CONCAT('2018-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) AS day_of_week,
    DATEDIFF(CONCAT('2018-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')),
             CONCAT('2018-01-01')) + 1 AS day_of_year,
    CASE WHEN DAYOFWEEK(CONCAT('2018-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend,
    0 AS is_holiday,
    CURRENT_TIMESTAMP AS etl_time
FROM (
    SELECT 1 AS month UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
) m
CROSS JOIN (
    SELECT 1 AS day UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL
    SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL
    SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL
    SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL
    SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31
) d
WHERE NOT (month = 2 AND day > 28)
  AND NOT ((month IN (4, 6, 9, 11)) AND day > 30);

-- 2019年数据
INSERT INTO TABLE dim_date
SELECT
    CAST(CONCAT('2019', LPAD(month, 2, '0'), LPAD(day, 2, '0')) AS INT) AS date_id,
    CONCAT('2019-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')) AS full_date,
    2019 AS year,
    CEIL(month / 3.0) AS quarter,
    month AS month,
    day AS day,
    DAYOFWEEK(CONCAT('2019-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) AS day_of_week,
    DATEDIFF(CONCAT('2019-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')),
             CONCAT('2019-01-01')) + 1 AS day_of_year,
    CASE WHEN DAYOFWEEK(CONCAT('2019-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend,
    0 AS is_holiday,
    CURRENT_TIMESTAMP AS etl_time
FROM (
    SELECT 1 AS month UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
) m
CROSS JOIN (
    SELECT 1 AS day UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL
    SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL
    SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL
    SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL
    SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31
) d
WHERE NOT (month = 2 AND day > 28)
  AND NOT ((month IN (4, 6, 9, 11)) AND day > 30);

-- 2020年数据
INSERT INTO TABLE dim_date
SELECT
    CAST(CONCAT('2020', LPAD(month, 2, '0'), LPAD(day, 2, '0')) AS INT) AS date_id,
    CONCAT('2020-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')) AS full_date,
    2020 AS year,
    CEIL(month / 3.0) AS quarter,
    month AS month,
    day AS day,
    DAYOFWEEK(CONCAT('2020-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) AS day_of_week,
    DATEDIFF(CONCAT('2020-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')),
             CONCAT('2020-01-01')) + 1 AS day_of_year,
    CASE WHEN DAYOFWEEK(CONCAT('2020-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend,
    0 AS is_holiday,
    CURRENT_TIMESTAMP AS etl_time
FROM (
    SELECT 1 AS month UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
) m
CROSS JOIN (
    SELECT 1 AS day UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL
    SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL
    SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL
    SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL
    SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31
) d
WHERE NOT (month = 2 AND day > 29)
  AND NOT ((month IN (4, 6, 9, 11)) AND day > 30);

-- 2021年数据
INSERT INTO TABLE dim_date
SELECT
    CAST(CONCAT('2021', LPAD(month, 2, '0'), LPAD(day, 2, '0')) AS INT) AS date_id,
    CONCAT('2021-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')) AS full_date,
    2021 AS year,
    CEIL(month / 3.0) AS quarter,
    month AS month,
    day AS day,
    DAYOFWEEK(CONCAT('2021-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) AS day_of_week,
    DATEDIFF(CONCAT('2021-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')),
             CONCAT('2021-01-01')) + 1 AS day_of_year,
    CASE WHEN DAYOFWEEK(CONCAT('2021-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend,
    0 AS is_holiday,
    CURRENT_TIMESTAMP AS etl_time
FROM (
    SELECT 1 AS month UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
) m
CROSS JOIN (
    SELECT 1 AS day UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL
    SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL
    SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL
    SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL
    SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31
) d
WHERE NOT (month = 2 AND day > 28)
  AND NOT ((month IN (4, 6, 9, 11)) AND day > 30);

-- 2022年数据
INSERT INTO TABLE dim_date
SELECT
    CAST(CONCAT('2022', LPAD(month, 2, '0'), LPAD(day, 2, '0')) AS INT) AS date_id,
    CONCAT('2022-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')) AS full_date,
    2022 AS year,
    CEIL(month / 3.0) AS quarter,
    month AS month,
    day AS day,
    DAYOFWEEK(CONCAT('2022-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) AS day_of_week,
    DATEDIFF(CONCAT('2022-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')),
             CONCAT('2022-01-01')) + 1 AS day_of_year,
    CASE WHEN DAYOFWEEK(CONCAT('2022-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend,
    0 AS is_holiday,
    CURRENT_TIMESTAMP AS etl_time
FROM (
    SELECT 1 AS month UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
) m
CROSS JOIN (
    SELECT 1 AS day UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL
    SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL
    SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL
    SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL
    SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31
) d
WHERE NOT (month = 2 AND day > 28)
  AND NOT ((month IN (4, 6, 9, 11)) AND day > 30);

-- 2023年数据
INSERT INTO TABLE dim_date
SELECT
    CAST(CONCAT('2023', LPAD(month, 2, '0'), LPAD(day, 2, '0')) AS INT) AS date_id,
    CONCAT('2023-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')) AS full_date,
    2023 AS year,
    CEIL(month / 3.0) AS quarter,
    month AS month,
    day AS day,
    DAYOFWEEK(CONCAT('2023-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) AS day_of_week,
    DATEDIFF(CONCAT('2023-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')),
             CONCAT('2023-01-01')) + 1 AS day_of_year,
    CASE WHEN DAYOFWEEK(CONCAT('2023-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend,
    0 AS is_holiday,
    CURRENT_TIMESTAMP AS etl_time
FROM (
    SELECT 1 AS month UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
) m
CROSS JOIN (
    SELECT 1 AS day UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL
    SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL
    SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL
    SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL
    SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31
) d
WHERE NOT (month = 2 AND day > 28)
  AND NOT ((month IN (4, 6, 9, 11)) AND day > 30);

-- 2024年数据
INSERT INTO TABLE dim_date
SELECT
    CAST(CONCAT('2024', LPAD(month, 2, '0'), LPAD(day, 2, '0')) AS INT) AS date_id,
    CONCAT('2024-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')) AS full_date,
    2024 AS year,
    CEIL(month / 3.0) AS quarter,
    month AS month,
    day AS day,
    DAYOFWEEK(CONCAT('2024-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) AS day_of_week,
    DATEDIFF(CONCAT('2024-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')),
             CONCAT('2024-01-01')) + 1 AS day_of_year,
    CASE WHEN DAYOFWEEK(CONCAT('2024-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0'))) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend,
    0 AS is_holiday,
    CURRENT_TIMESTAMP AS etl_time
FROM (
    SELECT 1 AS month UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
) m
CROSS JOIN (
    SELECT 1 AS day UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL
    SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL
    SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL
    SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL
    SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31
) d
WHERE NOT (month = 2 AND day > 29)
  AND NOT ((month IN (4, 6, 9, 11)) AND day > 30);

-- =====================================================
-- 第二步: 插入事实表数据（从MySQL同步）
-- =====================================================

-- 1. 插入考勤事实表数据（采样5万条）
INSERT INTO TABLE fact_attendance PARTITION (year_month='2024-01')
SELECT 
    a.attendance_id,
    a.emp_id,
    e.emp_no,
    e.emp_name,
    e.department,
    e.position,
    a.attendance_date,
    a.clock_in_time,
    a.clock_out_time,
    a.attendance_type,
    CASE a.attendance_type
        WHEN 0 THEN '正常'
        WHEN 1 THEN '迟到'
        WHEN 2 THEN '早退'
        WHEN 3 THEN '旷工'
        WHEN 4 THEN '请假'
        WHEN 5 THEN '加班'
    END AS attendance_type_name,
    a.attendance_status,
    a.work_duration,
    YEAR(a.attendance_date) AS year,
    MONTH(a.attendance_date) AS month,
    DAY(a.attendance_date) AS day,
    CURRENT_TIMESTAMP AS etl_time
FROM (
    SELECT * FROM hr_datacenter.attendance 
    WHERE YEAR(attendance_date) = 2024 AND MONTH(attendance_date) = 1
    LIMIT 5000
) a
JOIN hr_datacenter.employee e ON a.emp_id = e.emp_id
WHERE e.deleted = 0;

INSERT INTO TABLE fact_attendance PARTITION (year_month='2024-02')
SELECT 
    a.attendance_id, a.emp_id, e.emp_no, e.emp_name, e.department, e.position,
    a.attendance_date, a.clock_in_time, a.clock_out_time, a.attendance_type,
    CASE a.attendance_type WHEN 0 THEN '正常' WHEN 1 THEN '迟到' WHEN 2 THEN '早退' WHEN 3 THEN '旷工' WHEN 4 THEN '请假' WHEN 5 THEN '加班' END,
    a.attendance_status, a.work_duration, YEAR(a.attendance_date), MONTH(a.attendance_date), DAY(a.attendance_date),
    CURRENT_TIMESTAMP
FROM (
    SELECT * FROM hr_datacenter.attendance 
    WHERE YEAR(attendance_date) = 2024 AND MONTH(attendance_date) = 2
    LIMIT 5000
) a
JOIN hr_datacenter.employee e ON a.emp_id = e.emp_id
WHERE e.deleted = 0;

INSERT INTO TABLE fact_attendance PARTITION (year_month='2024-03')
SELECT 
    a.attendance_id, a.emp_id, e.emp_no, e.emp_name, e.department, e.position,
    a.attendance_date, a.clock_in_time, a.clock_out_time, a.attendance_type,
    CASE a.attendance_type WHEN 0 THEN '正常' WHEN 1 THEN '迟到' WHEN 2 THEN '早退' WHEN 3 THEN '旷工' WHEN 4 THEN '请假' WHEN 5 THEN '加班' END,
    a.attendance_status, a.work_duration, YEAR(a.attendance_date), MONTH(a.attendance_date), DAY(a.attendance_date),
    CURRENT_TIMESTAMP
FROM (
    SELECT * FROM hr_datacenter.attendance 
    WHERE YEAR(attendance_date) = 2024 AND MONTH(attendance_date) = 3
    LIMIT 5000
) a
JOIN hr_datacenter.employee e ON a.emp_id = e.emp_id
WHERE e.deleted = 0;

-- 2. 插入薪资事实表数据（采样2万条）
INSERT INTO TABLE fact_salary PARTITION (year_month='2024-01')
SELECT 
    s.payment_id,
    s.emp_id,
    e.emp_no,
    e.emp_name,
    e.department,
    e.position,
    s.year,
    s.month,
    s.basic_salary,
    s.performance_salary,
    s.position_allowance,
    s.transport_allowance,
    s.communication_allowance,
    s.meal_allowance,
    s.other_allowance,
    s.overtime_pay,
    s.total_gross_salary,
    s.social_insurance,
    s.housing_fund,
    s.income_tax,
    s.other_deduction,
    s.total_net_salary,
    s.payment_status,
    DATE_FORMAT(s.payment_date, 'yyyy-MM-dd HH:mm:ss') AS payment_date,
    CURRENT_TIMESTAMP AS etl_time
FROM (
    SELECT * FROM hr_datacenter.salary_payment 
    WHERE year = 2024 AND month = 1
    LIMIT 20000
) s
JOIN hr_datacenter.employee e ON s.emp_id = e.emp_id
WHERE e.deleted = 0;

INSERT INTO TABLE fact_salary PARTITION (year_month='2024-02')
SELECT 
    s.payment_id, s.emp_id, e.emp_no, e.emp_name, e.department, e.position,
    s.year, s.month, s.basic_salary, s.performance_salary, s.position_allowance,
    s.transport_allowance, s.communication_allowance, s.meal_allowance, s.other_allowance,
    s.overtime_pay, s.total_gross_salary, s.social_insurance, s.housing_fund,
    s.income_tax, s.other_deduction, s.total_net_salary, s.payment_status,
    DATE_FORMAT(s.payment_date, 'yyyy-MM-dd HH:mm:ss'), CURRENT_TIMESTAMP
FROM (
    SELECT * FROM hr_datacenter.salary_payment 
    WHERE year = 2024 AND month = 2
    LIMIT 20000
) s
JOIN hr_datacenter.employee e ON s.emp_id = e.emp_id
WHERE e.deleted = 0;

INSERT INTO TABLE fact_salary PARTITION (year_month='2024-03')
SELECT 
    s.payment_id, s.emp_id, e.emp_no, e.emp_name, e.department, e.position,
    s.year, s.month, s.basic_salary, s.performance_salary, s.position_allowance,
    s.transport_allowance, s.communication_allowance, s.meal_allowance, s.other_allowance,
    s.overtime_pay, s.total_gross_salary, s.social_insurance, s.housing_fund,
    s.income_tax, s.other_deduction, s.total_net_salary, s.payment_status,
    DATE_FORMAT(s.payment_date, 'yyyy-MM-dd HH:mm:ss'), CURRENT_TIMESTAMP
FROM (
    SELECT * FROM hr_datacenter.salary_payment 
    WHERE year = 2024 AND month = 3
    LIMIT 20000
) s
JOIN hr_datacenter.employee e ON s.emp_id = e.emp_id
WHERE e.deleted = 0;

-- 3. 插入绩效事实表数据（采样1万条）
INSERT INTO TABLE fact_performance PARTITION (year='2023')
SELECT 
    p.evaluation_id,
    p.emp_id,
    e.emp_no,
    e.emp_name,
    e.department,
    e.position,
    p.year,
    p.period_type,
    CASE p.period_type WHEN 1 THEN '年度' WHEN 2 THEN '季度' WHEN 3 THEN '月度' END AS period_type_name,
    p.quarter,
    p.month,
    p.self_score,
    p.supervisor_score,
    p.final_score,
    p.performance_level,
    CASE p.performance_level
        WHEN 'S' THEN '优秀'
        WHEN 'A' THEN '良好'
        WHEN 'B' THEN '合格'
        WHEN 'C' THEN '需改进'
        WHEN 'D' THEN '不合格'
    END AS performance_level_name,
    p.improvement_plan,
    DATE_FORMAT(p.interview_date, 'yyyy-MM-dd HH:mm:ss') AS interview_date,
    p.evaluation_status,
    CASE p.evaluation_status WHEN 0 THEN '未评估' WHEN 1 THEN '已自评' WHEN 2 THEN '已评价' WHEN 3 THEN '已完成' END AS evaluation_status_name,
    CURRENT_TIMESTAMP AS etl_time
FROM (
    SELECT * FROM hr_datacenter.performance_evaluation 
    WHERE year = 2023 AND period_type = 1
    LIMIT 5000
) p
JOIN hr_datacenter.employee e ON p.emp_id = e.emp_id
WHERE e.deleted = 0;

INSERT INTO TABLE fact_performance PARTITION (year='2024')
SELECT 
    p.evaluation_id, p.emp_id, e.emp_no, e.emp_name, e.department, e.position,
    p.year, p.period_type,
    CASE p.period_type WHEN 1 THEN '年度' WHEN 2 THEN '季度' WHEN 3 THEN '月度' END,
    p.quarter, p.month, p.self_score, p.supervisor_score, p.final_score, p.performance_level,
    CASE p.performance_level WHEN 'S' THEN '优秀' WHEN 'A' THEN '良好' WHEN 'B' THEN '合格' WHEN 'C' THEN '需改进' WHEN 'D' THEN '不合格' END,
    p.improvement_plan, DATE_FORMAT(p.interview_date, 'yyyy-MM-dd HH:mm:ss'), p.evaluation_status,
    CASE p.evaluation_status WHEN 0 THEN '未评估' WHEN 1 THEN '已自评' WHEN 2 THEN '已评价' WHEN 3 THEN '已完成' END,
    CURRENT_TIMESTAMP
FROM (
    SELECT * FROM hr_datacenter.performance_evaluation 
    WHERE year = 2024
    LIMIT 5000
) p
JOIN hr_datacenter.employee e ON p.emp_id = e.emp_id
WHERE e.deleted = 0;

-- 4. 插入培训事实表数据（采样1万条）
INSERT INTO TABLE fact_training PARTITION (year_month='2024-01')
SELECT 
    t.enrollment_id,
    t.course_id,
    c.course_name,
    c.course_type,
    CASE c.course_type WHEN 1 THEN '新员工培训' WHEN 2 THEN '技能培训' WHEN 3 THEN '管理培训' WHEN 4 THEN '安全培训' WHEN 5 THEN '其他' END AS course_type_name,
    t.emp_id,
    e.emp_no,
    e.emp_name,
    e.department,
    e.position,
    DATE_FORMAT(t.enrollment_time, 'yyyy-MM-dd HH:mm:ss') AS enrollment_time,
    t.approval_status,
    CASE t.approval_status WHEN 0 THEN '待审核' WHEN 1 THEN '已通过' WHEN 2 THEN '已拒绝' END AS approval_status_name,
    t.approver_id,
    t.attendance_status,
    CASE t.attendance_status WHEN 0 THEN '未出勤' WHEN 1 THEN '已出勤' WHEN 2 THEN '请假' END AS attendance_status_name,
    t.score,
    CASE 
        WHEN t.score >= 90 THEN '优秀'
        WHEN t.score >= 80 THEN '良好'
        WHEN t.score >= 60 THEN '及格'
        WHEN t.score IS NOT NULL THEN '不及格'
    END AS score_level,
    t.feedback,
    YEAR(t.enrollment_time) AS year,
    MONTH(t.enrollment_time) AS month,
    CURRENT_TIMESTAMP AS etl_time
FROM (
    SELECT * FROM hr_datacenter.training_enrollment 
    WHERE YEAR(enrollment_time) = 2024 AND MONTH(enrollment_time) = 1
    LIMIT 5000
) t
JOIN hr_datacenter.training_course c ON t.course_id = c.course_id
JOIN hr_datacenter.employee e ON t.emp_id = e.emp_id
WHERE e.deleted = 0 AND c.deleted = 0;

INSERT INTO TABLE fact_training PARTITION (year_month='2024-02')
SELECT 
    t.enrollment_id, t.course_id, c.course_name, c.course_type,
    CASE c.course_type WHEN 1 THEN '新员工培训' WHEN 2 THEN '技能培训' WHEN 3 THEN '管理培训' WHEN 4 THEN '安全培训' WHEN 5 THEN '其他' END,
    t.emp_id, e.emp_no, e.emp_name, e.department, e.position,
    DATE_FORMAT(t.enrollment_time, 'yyyy-MM-dd HH:mm:ss'), t.approval_status,
    CASE t.approval_status WHEN 0 THEN '待审核' WHEN 1 THEN '已通过' WHEN 2 THEN '已拒绝' END,
    t.approver_id, t.attendance_status,
    CASE t.attendance_status WHEN 0 THEN '未出勤' WHEN 1 THEN '已出勤' WHEN 2 THEN '请假' END,
    t.score,
    CASE WHEN t.score >= 90 THEN '优秀' WHEN t.score >= 80 THEN '良好' WHEN t.score >= 60 THEN '及格' WHEN t.score IS NOT NULL THEN '不及格' END,
    t.feedback, YEAR(t.enrollment_time), MONTH(t.enrollment_time), CURRENT_TIMESTAMP
FROM (
    SELECT * FROM hr_datacenter.training_enrollment 
    WHERE YEAR(enrollment_time) = 2024 AND MONTH(enrollment_time) = 2
    LIMIT 5000
) t
JOIN hr_datacenter.training_course c ON t.course_id = c.course_id
JOIN hr_datacenter.employee e ON t.emp_id = e.emp_id
WHERE e.deleted = 0 AND c.deleted = 0;

INSERT INTO TABLE fact_training PARTITION (year_month='2024-03')
SELECT 
    t.enrollment_id, t.course_id, c.course_name, c.course_type,
    CASE c.course_type WHEN 1 THEN '新员工培训' WHEN 2 THEN '技能培训' WHEN 3 THEN '管理培训' WHEN 4 THEN '安全培训' WHEN 5 THEN '其他' END,
    t.emp_id, e.emp_no, e.emp_name, e.department, e.position,
    DATE_FORMAT(t.enrollment_time, 'yyyy-MM-dd HH:mm:ss'), t.approval_status,
    CASE t.approval_status WHEN 0 THEN '待审核' WHEN 1 THEN '已通过' WHEN 2 THEN '已拒绝' END,
    t.approver_id, t.attendance_status,
    CASE t.attendance_status WHEN 0 THEN '未出勤' WHEN 1 THEN '已出勤' WHEN 2 THEN '请假' END,
    t.score,
    CASE WHEN t.score >= 90 THEN '优秀' WHEN t.score >= 80 THEN '良好' WHEN t.score >= 60 THEN '及格' WHEN t.score IS NOT NULL THEN '不及格' END,
    t.feedback, YEAR(t.enrollment_time), MONTH(t.enrollment_time), CURRENT_TIMESTAMP
FROM (
    SELECT * FROM hr_datacenter.training_enrollment 
    WHERE YEAR(enrollment_time) = 2024 AND MONTH(enrollment_time) = 3
    LIMIT 5000
) t
JOIN hr_datacenter.training_course c ON t.course_id = c.course_id
JOIN hr_datacenter.employee e ON t.emp_id = e.emp_id
WHERE e.deleted = 0 AND c.deleted = 0;

-- =====================================================
-- 第三步: 生成聚合表数据
-- =====================================================

-- 1. 生成部门月度考勤汇总数据
INSERT INTO TABLE agg_dept_monthly_attendance PARTITION (year='2024')
SELECT 
    department,
    CONCAT(year, '-', LPAD(month, 2, '0')) AS year_month,
    year,
    month,
    COUNT(DISTINCT emp_id) AS total_employees,
    COUNT(*) AS total_days,
    SUM(CASE WHEN attendance_type = 0 THEN 1 ELSE 0 END) AS total_attendance,
    ROUND(SUM(CASE WHEN attendance_type = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attendance_rate,
    SUM(CASE WHEN attendance_type = 0 THEN 1 ELSE 0 END) AS normal_count,
    SUM(CASE WHEN attendance_type = 1 THEN 1 ELSE 0 END) AS late_count,
    SUM(CASE WHEN attendance_type = 2 THEN 1 ELSE 0 END) AS early_leave_count,
    SUM(CASE WHEN attendance_type = 3 THEN 1 ELSE 0 END) AS absence_count,
    SUM(CASE WHEN attendance_type = 4 THEN 1 ELSE 0 END) AS leave_count,
    SUM(CASE WHEN attendance_type = 5 THEN 1 ELSE 0 END) AS overtime_count,
    ROUND(AVG(work_duration), 2) AS avg_work_duration,
    CURRENT_TIMESTAMP AS etl_time
FROM fact_attendance
WHERE year = 2024
GROUP BY department, year, month;

-- 2. 生成部门月度薪资汇总数据
INSERT INTO TABLE agg_dept_monthly_salary PARTITION (year='2024')
SELECT 
    department,
    CONCAT(year, '-', LPAD(month, 2, '0')) AS year_month,
    year,
    month,
    COUNT(DISTINCT emp_id) AS employee_count,
    SUM(basic_salary) AS total_basic_salary,
    SUM(performance_salary) AS total_performance_salary,
    SUM(position_allowance + transport_allowance + communication_allowance + meal_allowance + other_allowance) AS total_allowance,
    SUM(overtime_pay) AS total_overtime_pay,
    SUM(total_gross_salary) AS total_gross_salary,
    SUM(social_insurance + housing_fund + income_tax + other_deduction) AS total_deduction,
    SUM(total_net_salary) AS total_net_salary,
    ROUND(AVG(basic_salary), 2) AS avg_basic_salary,
    ROUND(AVG(total_net_salary), 2) AS avg_net_salary,
    ROUND(MAX(total_net_salary), 2) AS max_salary,
    ROUND(MIN(total_net_salary), 2) AS min_salary,
    SUM(CASE WHEN payment_status = 1 THEN 1 ELSE 0 END) AS payment_count,
    CURRENT_TIMESTAMP AS etl_time
FROM fact_salary
WHERE year = 2024
GROUP BY department, year, month;

-- 3. 生成员工年度绩效汇总数据
INSERT INTO TABLE agg_employee_yearly_performance PARTITION (year='2023')
SELECT 
    emp_id,
    emp_no,
    emp_name,
    department,
    position,
    year,
    COUNT(*) AS total_evaluations,
    ROUND(AVG(self_score), 2) AS avg_self_score,
    ROUND(AVG(supervisor_score), 2) AS avg_supervisor_score,
    ROUND(AVG(final_score), 2) AS avg_final_score,
    SUM(CASE WHEN performance_level = 'S' THEN 1 ELSE 0 END) AS s_level_count,
    SUM(CASE WHEN performance_level = 'A' THEN 1 ELSE 0 END) AS a_level_count,
    SUM(CASE WHEN performance_level = 'B' THEN 1 ELSE 0 END) AS b_level_count,
    SUM(CASE WHEN performance_level = 'C' THEN 1 ELSE 0 END) AS c_level_count,
    SUM(CASE WHEN performance_level = 'D' THEN 1 ELSE 0 END) AS d_level_count,
    CASE 
        WHEN ROUND(AVG(final_score), 0) >= 90 THEN 'S'
        WHEN ROUND(AVG(final_score), 0) >= 80 THEN 'A'
        WHEN ROUND(AVG(final_score), 0) >= 70 THEN 'B'
        WHEN ROUND(AVG(final_score), 0) >= 60 THEN 'C'
        ELSE 'D'
    END AS overall_level,
    '稳定' AS score_trend,
    COUNT(CASE WHEN improvement_plan IS NOT NULL AND improvement_plan != '' THEN 1 END) AS improvement_count,
    CURRENT_TIMESTAMP AS etl_time
FROM fact_performance
WHERE year = 2023
GROUP BY emp_id, emp_no, emp_name, department, position, year;

INSERT INTO TABLE agg_employee_yearly_performance PARTITION (year='2024')
SELECT 
    emp_id, emp_no, emp_name, department, position, year,
    COUNT(*) AS total_evaluations,
    ROUND(AVG(self_score), 2) AS avg_self_score,
    ROUND(AVG(supervisor_score), 2) AS avg_supervisor_score,
    ROUND(AVG(final_score), 2) AS avg_final_score,
    SUM(CASE WHEN performance_level = 'S' THEN 1 ELSE 0 END) AS s_level_count,
    SUM(CASE WHEN performance_level = 'A' THEN 1 ELSE 0 END) AS a_level_count,
    SUM(CASE WHEN performance_level = 'B' THEN 1 ELSE 0 END) AS b_level_count,
    SUM(CASE WHEN performance_level = 'C' THEN 1 ELSE 0 END) AS c_level_count,
    SUM(CASE WHEN performance_level = 'D' THEN 1 ELSE 0 END) AS d_level_count,
    CASE WHEN ROUND(AVG(final_score), 0) >= 90 THEN 'S' WHEN ROUND(AVG(final_score), 0) >= 80 THEN 'A' WHEN ROUND(AVG(final_score), 0) >= 70 THEN 'B' WHEN ROUND(AVG(final_score), 0) >= 60 THEN 'C' ELSE 'D' END AS overall_level,
    '稳定' AS score_trend,
    COUNT(CASE WHEN improvement_plan IS NOT NULL AND improvement_plan != '' THEN 1 END) AS improvement_count,
    CURRENT_TIMESTAMP AS etl_time
FROM fact_performance
WHERE year = 2024
GROUP BY emp_id, emp_no, emp_name, department, position, year;

-- 4. 生成培训课程统计数据
INSERT INTO TABLE agg_course_statistics
SELECT 
    c.course_id,
    c.course_name,
    c.course_type,
    CASE c.course_type WHEN 1 THEN '新员工培训' WHEN 2 THEN '技能培训' WHEN 3 THEN '管理培训' WHEN 4 THEN '安全培训' WHEN 5 THEN '其他' END AS course_type_name,
    c.instructor,
    c.duration,
    c.location,
    c.capacity,
    COUNT(t.enrollment_id) AS total_enrollments,
    SUM(CASE WHEN t.approval_status = 1 THEN 1 ELSE 0 END) AS approved_count,
    SUM(CASE WHEN t.attendance_status = 1 THEN 1 ELSE 0 END) AS completed_count,
    ROUND(SUM(CASE WHEN t.attendance_status = 1 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(t.enrollment_id), 0), 2) AS completion_rate,
    ROUND(SUM(CASE WHEN t.attendance_status = 1 THEN 1 ELSE 0 END) * 100.0 / NULLIF(SUM(CASE WHEN t.approval_status = 1 THEN 1 ELSE 0 END), 0), 2) AS attendance_rate,
    ROUND(AVG(t.score), 2) AS avg_score,
    0.85 AS satisfaction_rate,
    ROUND(SUM(CASE WHEN t.score >= 80 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(t.score), 0), 2) AS excellent_rate,
    ROUND(SUM(CASE WHEN t.score >= 60 AND t.score < 80 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(t.score), 0), 2) AS good_rate,
    ROUND(SUM(CASE WHEN t.score >= 60 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(t.score), 0), 2) AS pass_rate,
    ROUND(SUM(CASE WHEN t.score < 60 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(t.score), 0), 2) AS fail_rate,
    MIN(c.start_date) AS first_course_date,
    MAX(c.end_date) AS last_course_date,
    COUNT(CASE WHEN t.feedback IS NOT NULL AND t.feedback != '' THEN 1 END) AS total_feedback,
    CURRENT_TIMESTAMP AS etl_time
FROM training_course c
LEFT JOIN training_enrollment t ON c.course_id = t.course_id
WHERE c.deleted = 0
GROUP BY c.course_id, c.course_name, c.course_type, c.instructor, c.duration, c.location, c.capacity
ORDER BY c.course_id;

-- =====================================================
-- 第四部分: 数据统计
-- =====================================================

SELECT '======================================' AS '';
SELECT 'Hive数据仓库数据插入完成!' AS message;
SELECT '======================================' AS '';

-- 统计各表数据量
SELECT '维度表数据统计:' AS table_type, COUNT(*) AS record_count FROM dim_date
UNION ALL
SELECT '考勤事实表:', COUNT(*) FROM fact_attendance
UNION ALL
SELECT '薪资事实表:', COUNT(*) FROM fact_salary
UNION ALL
SELECT '绩效事实表:', COUNT(*) FROM fact_performance
UNION ALL
SELECT '培训事实表:', COUNT(*) FROM fact_training
UNION ALL
SELECT '部门考勤汇总表:', COUNT(*) FROM agg_dept_monthly_attendance
UNION ALL
SELECT '部门薪资汇总表:', COUNT(*) FROM agg_dept_monthly_salary
UNION ALL
SELECT '员工绩效汇总表:', COUNT(*) FROM agg_employee_yearly_performance
UNION ALL
SELECT '培训课程统计表:', COUNT(*) FROM agg_course_statistics;

SELECT '======================================' AS '';
SELECT 'Hive数据仓库初始化完成!' AS message;
SELECT '======================================' AS '';

SELECT CONCAT('总计插入Hive数据: ',
    (SELECT COUNT(*) FROM dim_date) + 
    (SELECT COUNT(*) FROM fact_attendance) + 
    (SELECT COUNT(*) FROM fact_salary) + 
    (SELECT COUNT(*) FROM fact_performance) + 
    (SELECT COUNT(*) FROM fact_training) + 
    (SELECT COUNT(*) FROM agg_dept_monthly_attendance) + 
    (SELECT COUNT(*) FROM agg_dept_monthly_salary) + 
    (SELECT COUNT(*) FROM agg_employee_yearly_performance) + 
    (SELECT COUNT(*) FROM agg_course_statistics),
    ' 条') AS total_records;

-- 显示所有表
SHOW TABLES;
