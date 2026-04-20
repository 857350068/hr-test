-- ============================================================================
-- Hive 大规模补数脚本（兼容版）
-- 规模：480 员工 + 2个月薪资事实 + 2个季度绩效事实 + 聚合
-- 说明：依赖 insert_data.sql 已建好的表结构
-- ============================================================================

USE hr_datacenter_dw;
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

-- 1) 员工维度扩容（480）
WITH nums AS (
    SELECT posexplode(split(space(479), ' ')) AS (idx, x)
)
INSERT OVERWRITE TABLE dim_employee PARTITION (dt='20260420')
SELECT
    CAST(idx + 1 AS BIGINT),
    CONCAT('HEMP', LPAD(CAST(idx + 1 AS STRING), 5, '0')),
    CONCAT(
        CASE pmod(idx + 7, 30)
            WHEN 0 THEN '王' WHEN 1 THEN '李' WHEN 2 THEN '张' WHEN 3 THEN '刘' WHEN 4 THEN '陈'
            WHEN 5 THEN '杨' WHEN 6 THEN '赵' WHEN 7 THEN '黄' WHEN 8 THEN '周' WHEN 9 THEN '吴'
            WHEN 10 THEN '徐' WHEN 11 THEN '孙' WHEN 12 THEN '马' WHEN 13 THEN '朱' WHEN 14 THEN '胡'
            WHEN 15 THEN '郭' WHEN 16 THEN '何' WHEN 17 THEN '高' WHEN 18 THEN '林' WHEN 19 THEN '罗'
            WHEN 20 THEN '郑' WHEN 21 THEN '梁' WHEN 22 THEN '谢' WHEN 23 THEN '宋' WHEN 24 THEN '唐'
            WHEN 25 THEN '韩' WHEN 26 THEN '冯' WHEN 27 THEN '于' WHEN 28 THEN '董' ELSE '萧'
        END,
        CASE pmod(idx + 11, 40)
            WHEN 0 THEN '伟' WHEN 1 THEN '芳' WHEN 2 THEN '娜' WHEN 3 THEN '敏' WHEN 4 THEN '磊'
            WHEN 5 THEN '静' WHEN 6 THEN '洋' WHEN 7 THEN '强' WHEN 8 THEN '涛' WHEN 9 THEN '杰'
            WHEN 10 THEN '琳' WHEN 11 THEN '雪' WHEN 12 THEN '博' WHEN 13 THEN '晨' WHEN 14 THEN '宇'
            WHEN 15 THEN '轩' WHEN 16 THEN '雨桐' WHEN 17 THEN '子涵' WHEN 18 THEN '思远' WHEN 19 THEN '佳宁'
            WHEN 20 THEN '浩然' WHEN 21 THEN '梦瑶' WHEN 22 THEN '文博' WHEN 23 THEN '欣怡' WHEN 24 THEN '梓轩'
            WHEN 25 THEN '雅婷' WHEN 26 THEN '俊豪' WHEN 27 THEN '明轩' WHEN 28 THEN '嘉怡' WHEN 29 THEN '天宇'
            WHEN 30 THEN '晓彤' WHEN 31 THEN '诗涵' WHEN 32 THEN '瑞泽' WHEN 33 THEN '心怡' WHEN 34 THEN '乐天'
            WHEN 35 THEN '亦凡' WHEN 36 THEN '俊杰' WHEN 37 THEN '雨晨' WHEN 38 THEN '家豪' ELSE '若曦'
        END
    ),
    CAST(pmod(idx, 2) AS INT),
    CASE WHEN pmod(idx, 2) = 1 THEN '男' ELSE '女' END,
    CAST(date_add('1985-01-01', pmod(idx * 17, 12000)) AS DATE),
    CAST(floor(datediff(current_date, date_add('1985-01-01', pmod(idx * 17, 12000))) / 365) AS INT),
    CONCAT('320101', date_format(date_add('1985-01-01', pmod(idx * 17, 12000)), 'yyyyMMdd'), LPAD(CAST(idx + 3000 AS STRING), 4, '0')),
    CONCAT('17', LPAD(CAST(idx + 500000000 AS STRING), 9, '0')),
    CONCAT('hive.large.', CAST(idx + 1 AS STRING), '@hr.local'),
    CASE pmod(idx, 10) WHEN 0 THEN '技术部' WHEN 1 THEN '研发部' WHEN 2 THEN '市场部' WHEN 3 THEN '人力资源部' WHEN 4 THEN '财务部' WHEN 5 THEN '运营部' WHEN 6 THEN '客服部' WHEN 7 THEN '行政部' WHEN 8 THEN '法务部' ELSE '供应链部' END,
    CASE pmod(idx, 12) WHEN 0 THEN '高级工程师' WHEN 1 THEN '开发工程师' WHEN 2 THEN '测试工程师' WHEN 3 THEN '产品经理' WHEN 4 THEN '数据分析师' WHEN 5 THEN '运营专员' WHEN 6 THEN '招聘专员' WHEN 7 THEN '会计' WHEN 8 THEN '销售经理' WHEN 9 THEN '客服专员' WHEN 10 THEN '法务专员' ELSE '采购专员' END,
    CAST(7600 + pmod(idx, 22) * 820 + pmod(idx, 9) * 140 AS DECIMAL(10,2)),
    CAST(date_add('2013-01-01', pmod(idx * 19, 4200)) AS DATE),
    CASE WHEN pmod(idx, 25) = 0 THEN CAST(date_add('2023-01-01', pmod(idx, 350)) AS DATE) ELSE NULL END,
    CAST(floor(datediff(current_date, date_add('2013-01-01', pmod(idx * 19, 4200))) / 365) AS INT),
    CAST(CASE WHEN pmod(idx, 25) = 0 THEN 0 WHEN pmod(idx, 13) = 0 THEN 2 ELSE 1 END AS INT),
    CASE WHEN pmod(idx, 25) = 0 THEN '离职' WHEN pmod(idx, 13) = 0 THEN '试用' ELSE '在职' END,
    CASE pmod(idx, 6) WHEN 0 THEN '本科' WHEN 1 THEN '硕士' WHEN 2 THEN '本科' WHEN 3 THEN '大专' WHEN 4 THEN '博士' ELSE '本科' END,
    CAST(CASE pmod(idx, 6) WHEN 0 THEN 3 WHEN 1 THEN 4 WHEN 2 THEN 3 WHEN 3 THEN 2 WHEN 4 THEN 5 ELSE 3 END AS INT),
    current_timestamp(),
    current_timestamp(),
    current_timestamp(),
    current_timestamp()
FROM nums;

-- 2) 薪资事实（2026-02）
INSERT OVERWRITE TABLE fact_salary PARTITION (year='2026', month='02')
SELECT
    row_number() OVER (ORDER BY emp_id),
    emp_id, emp_no, emp_name, department, position,
    '2026-02',
    CAST(current_salary * 0.89 AS DECIMAL(10,2)),
    CAST(current_salary * 0.13 AS DECIMAL(10,2)),
    CAST(650 + pmod(emp_id, 9) * 100 AS DECIMAL(10,2)),
    CAST(320 AS DECIMAL(10,2)),
    CAST(220 AS DECIMAL(10,2)),
    CAST(320 AS DECIMAL(10,2)),
    CAST(0 AS DECIMAL(10,2)),
    CAST(pmod(emp_id, 7) * 130 AS DECIMAL(10,2)),
    CAST((current_salary * 0.89) + (current_salary * 0.13) + (650 + pmod(emp_id, 9) * 100) + 320 + 220 + 320 + pmod(emp_id, 7) * 130 AS DECIMAL(10,2)),
    CAST(current_salary * 0.08 AS DECIMAL(10,2)),
    CAST(current_salary * 0.08 AS DECIMAL(10,2)),
    CAST(current_salary * 0.035 AS DECIMAL(10,2)),
    CAST(0 AS DECIMAL(10,2)),
    CAST((current_salary * 0.08) + (current_salary * 0.08) + (current_salary * 0.035) AS DECIMAL(10,2)),
    CAST(((current_salary * 0.89) + (current_salary * 0.13) + (650 + pmod(emp_id, 9) * 100) + 320 + 220 + 320 + pmod(emp_id, 7) * 130) - ((current_salary * 0.08) + (current_salary * 0.08) + (current_salary * 0.035)) AS DECIMAL(10,2)),
    1,
    '已发放',
    current_timestamp(),
    'AUTO_GEN_HIVE_LARGE',
    current_timestamp(),
    current_timestamp(),
    current_timestamp(),
    current_timestamp()
FROM dim_employee
WHERE dt = '20260420' AND status = 1;

-- 3) 薪资事实（2026-03）
INSERT OVERWRITE TABLE fact_salary PARTITION (year='2026', month='03')
SELECT
    row_number() OVER (ORDER BY emp_id),
    emp_id, emp_no, emp_name, department, position,
    '2026-03',
    CAST(current_salary * 0.90 AS DECIMAL(10,2)),
    CAST(current_salary * 0.14 AS DECIMAL(10,2)),
    CAST(680 + pmod(emp_id, 10) * 95 AS DECIMAL(10,2)),
    CAST(330 AS DECIMAL(10,2)),
    CAST(230 AS DECIMAL(10,2)),
    CAST(330 AS DECIMAL(10,2)),
    CAST(0 AS DECIMAL(10,2)),
    CAST(pmod(emp_id, 8) * 140 AS DECIMAL(10,2)),
    CAST((current_salary * 0.90) + (current_salary * 0.14) + (680 + pmod(emp_id, 10) * 95) + 330 + 230 + 330 + pmod(emp_id, 8) * 140 AS DECIMAL(10,2)),
    CAST(current_salary * 0.08 AS DECIMAL(10,2)),
    CAST(current_salary * 0.08 AS DECIMAL(10,2)),
    CAST(current_salary * 0.035 AS DECIMAL(10,2)),
    CAST(0 AS DECIMAL(10,2)),
    CAST((current_salary * 0.08) + (current_salary * 0.08) + (current_salary * 0.035) AS DECIMAL(10,2)),
    CAST(((current_salary * 0.90) + (current_salary * 0.14) + (680 + pmod(emp_id, 10) * 95) + 330 + 230 + 330 + pmod(emp_id, 8) * 140) - ((current_salary * 0.08) + (current_salary * 0.08) + (current_salary * 0.035)) AS DECIMAL(10,2)),
    1,
    '已发放',
    current_timestamp(),
    'AUTO_GEN_HIVE_LARGE',
    current_timestamp(),
    current_timestamp(),
    current_timestamp(),
    current_timestamp()
FROM dim_employee
WHERE dt = '20260420' AND status = 1;

-- 4) 绩效事实（2025Q4）
INSERT OVERWRITE TABLE fact_performance PARTITION (year='2025', quarter='04')
SELECT
    row_number() OVER (ORDER BY emp_id),
    emp_id, emp_no, emp_name, department, position,
    '2025-Q4',
    2,
    '季度',
    4,
    NULL,
    CAST(76 + pmod(emp_id, 19) AS DECIMAL(5,2)),
    'AUTO_GEN_HIVE_LARGE自评',
    CAST(77 + pmod(emp_id, 18) AS DECIMAL(5,2)),
    'AUTO_GEN_HIVE_LARGE主管评语',
    CAST(76.5 + pmod(emp_id, 18) AS DECIMAL(5,2)),
    CASE WHEN (76.5 + pmod(emp_id, 18)) >= 92 THEN 'S' WHEN (76.5 + pmod(emp_id, 18)) >= 84 THEN 'A' WHEN (76.5 + pmod(emp_id, 18)) >= 76 THEN 'B' WHEN (76.5 + pmod(emp_id, 18)) >= 68 THEN 'C' ELSE 'D' END,
    CASE WHEN (76.5 + pmod(emp_id, 18)) >= 92 THEN 5 WHEN (76.5 + pmod(emp_id, 18)) >= 84 THEN 4 WHEN (76.5 + pmod(emp_id, 18)) >= 76 THEN 3 WHEN (76.5 + pmod(emp_id, 18)) >= 68 THEN 2 ELSE 1 END,
    'AUTO_GEN_HIVE_LARGE改进计划',
    'AUTO_GEN_HIVE_LARGE面谈记录',
    current_timestamp(),
    3,
    '已完成',
    current_timestamp(),
    current_timestamp(),
    current_timestamp(),
    current_timestamp()
FROM dim_employee
WHERE dt = '20260420' AND status IN (1, 2);

-- 5) 绩效事实（2026Q1）
INSERT OVERWRITE TABLE fact_performance PARTITION (year='2026', quarter='01')
SELECT
    row_number() OVER (ORDER BY emp_id),
    emp_id, emp_no, emp_name, department, position,
    '2026-Q1',
    2,
    '季度',
    1,
    NULL,
    CAST(77 + pmod(emp_id, 19) AS DECIMAL(5,2)),
    'AUTO_GEN_HIVE_LARGE自评',
    CAST(78 + pmod(emp_id, 18) AS DECIMAL(5,2)),
    'AUTO_GEN_HIVE_LARGE主管评语',
    CAST(77.5 + pmod(emp_id, 18) AS DECIMAL(5,2)),
    CASE WHEN (77.5 + pmod(emp_id, 18)) >= 92 THEN 'S' WHEN (77.5 + pmod(emp_id, 18)) >= 84 THEN 'A' WHEN (77.5 + pmod(emp_id, 18)) >= 76 THEN 'B' WHEN (77.5 + pmod(emp_id, 18)) >= 68 THEN 'C' ELSE 'D' END,
    CASE WHEN (77.5 + pmod(emp_id, 18)) >= 92 THEN 5 WHEN (77.5 + pmod(emp_id, 18)) >= 84 THEN 4 WHEN (77.5 + pmod(emp_id, 18)) >= 76 THEN 3 WHEN (77.5 + pmod(emp_id, 18)) >= 68 THEN 2 ELSE 1 END,
    'AUTO_GEN_HIVE_LARGE改进计划',
    'AUTO_GEN_HIVE_LARGE面谈记录',
    current_timestamp(),
    3,
    '已完成',
    current_timestamp(),
    current_timestamp(),
    current_timestamp(),
    current_timestamp()
FROM dim_employee
WHERE dt = '20260420' AND status IN (1, 2);

-- 6) 聚合（2026-03）
INSERT OVERWRITE TABLE agg_employee_monthly_salary PARTITION (year='2026', month='03')
SELECT
    emp_id, emp_no, emp_name, department, position, year_month,
    basic_salary, performance_salary,
    CAST(position_allowance + transport_allowance + communication_allowance + meal_allowance + coalesce(other_allowance, 0) AS DECIMAL(10,2)),
    overtime_pay, total_gross_salary, total_deduction, total_net_salary,
    payment_status, payment_status_name,
    CAST(0.00 AS DECIMAL(5,2)),
    current_timestamp()
FROM fact_salary
WHERE year = '2026' AND month = '03';

INSERT OVERWRITE TABLE agg_department_monthly_cost PARTITION (year='2026', month='03')
SELECT
    department,
    '2026-03',
    CAST(COUNT(*) AS INT),
    CAST(SUM(total_gross_salary) AS DECIMAL(15,2)),
    CAST(SUM(total_net_salary) AS DECIMAL(15,2)),
    CAST(AVG(total_net_salary) AS DECIMAL(10,2)),
    CAST(SUM(position_allowance + transport_allowance + communication_allowance + meal_allowance + coalesce(other_allowance, 0)) AS DECIMAL(15,2)),
    CAST(SUM(overtime_pay) AS DECIMAL(15,2)),
    CAST(SUM(social_insurance) AS DECIMAL(15,2)),
    CAST(SUM(housing_fund) AS DECIMAL(15,2)),
    CAST(SUM(income_tax) AS DECIMAL(15,2)),
    CAST(SUM(total_gross_salary) AS DECIMAL(15,2)),
    CAST(AVG(total_gross_salary) AS DECIMAL(10,2)),
    CAST(0.00 AS DECIMAL(5,2)),
    current_timestamp()
FROM fact_salary
WHERE year = '2026' AND month = '03'
GROUP BY department;

SELECT 'Hive大规模补数完成' AS status;
