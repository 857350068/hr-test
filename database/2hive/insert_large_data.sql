-- ============================================================================
-- 人力资源数据中心系统 - Hive大数据量数据插入脚本
-- 版本: 2.0
-- 创建时间: 2024-01-20
-- 说明: 包含大量真实业务数据，支持大数据分析和OLAP查询
-- 数据规模: 500名员工，2年历史数据，约50万+条记录
-- ============================================================================

USE hr_datacenter_dw;

-- 设置Hive参数
SET hive.exec.dynamic.mode=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
-- 1. 开启动态分区（必须）
set hive.exec.dynamic.partition=true;
-- 2. 非严格模式（允许所有分区都是动态分区，必须）
set hive.exec.dynamic.partition.mode=nonstrict;
-- 3. 开启本地模式（小数据不跑MapReduce，解决插入失败/卡顿）
set hive.exec.mode.local.auto=true;
-- 可选：动态分区优化参数（大数据量插入时添加）
set hive.exec.max.dynamic.partitions=1000;
set hive.exec.max.dynamic.partitions.pernode=100;
SET hive.exec.compress.output=true;
SET mapred.output.compression.codec=org.apache.hadoop.io.compress.SnappyCodec;

-- ============================================================================
-- 1. 员工维度表 (dim_employee) - 500名员工数据
-- ============================================================================

-- 使用临时表生成员工数据
DROP TABLE IF EXISTS temp_employee;
CREATE TEMPORARY TABLE temp_employee (
    emp_id BIGINT,
    emp_no STRING,
    emp_name STRING,
    gender INT,
    gender_name STRING,
    birth_date STRING,
    age INT,
    id_card STRING,
    phone STRING,
    email STRING,
    department STRING,
    position STRING,
    current_salary DECIMAL(10,2),
    hire_date STRING,
    resign_date STRING,
    work_years INT,
    status INT,
    status_name STRING,
    education STRING,
    education_level INT
);

-- 生成500名员工数据
INSERT INTO TABLE temp_employee
SELECT 
    employee.emp_id,
    employee.emp_no,
    employee.emp_name,
    employee.gender,
    CASE WHEN employee.gender = 1 THEN '男' ELSE '女' END AS gender_name,
    employee.birth_date,
    FLOOR(DATEDIFF(CURRENT_DATE, employee.birth_date) / 365) AS age,
    employee.id_card,
    employee.phone,
    employee.email,
    employee.department,
    employee.position,
    employee.salary AS current_salary,
    employee.hire_date,
    employee.resign_date,
    FLOOR(DATEDIFF(CURRENT_DATE, employee.hire_date) / 365) AS work_years,
    employee.status,
    CASE employee.status
        WHEN 0 THEN '离职'
        WHEN 1 THEN '在职'
        WHEN 2 THEN '试用'
        ELSE '未知'
    END AS status_name,
    employee.education,
    CASE employee.education
        WHEN '高中' THEN 1
        WHEN '大专' THEN 2
        WHEN '本科' THEN 3
        WHEN '硕士' THEN 4
        WHEN '博士' THEN 5
        ELSE 0
    END AS education_level
FROM (
    -- 从MySQL同步员工数据（这里模拟生成500名员工）
    SELECT 
        1 AS emp_id, 'EMP001' AS emp_no, '张伟' AS emp_name, 1 AS gender,
        '1990-05-15' AS birth_date, '110101199005151234' AS id_card, '13800138001' AS phone,
        'zhangwei@hrdatacenter.com' AS email, '技术部' AS department, '高级软件工程师' AS position,
        22000.00 AS salary, '2018-03-15' AS hire_date, NULL AS resign_date, 1 AS status,
        '本科' AS education
    UNION ALL
    -- 继续生成更多员工数据...
    SELECT 2, 'EMP002', '李娜', 0, '1992-08-22', '110101199208221234', '13800138002',
        'lina@hrdatacenter.com', '技术部', '前端开发工程师', 16000.00, '2019-06-10', NULL, 1, '本科'
    UNION ALL
    SELECT 3, 'EMP003', '王芳', 0, '1991-11-08', '110101199111081234', '13800138003',
        'wangfang@hrdatacenter.com', '技术部', '后端开发工程师', 18000.00, '2018-09-20', NULL, 1, '硕士'
    UNION ALL
    SELECT 4, 'EMP004', '刘强', 1, '1988-03-25', '110101198803251234', '13800138004',
        'liuqiang@hrdatacenter.com', '技术部', '架构师', 28000.00, '2016-05-18', NULL, 1, '硕士'
    UNION ALL
    SELECT 5, 'EMP005', '陈静', 0, '1993-07-12', '110101199307121234', '13800138005',
        'chenjing@hrdatacenter.com', '技术部', '测试工程师', 14000.00, '2020-02-28', NULL, 1, '本科'
    UNION ALL
    SELECT 6, 'EMP006', '杨洋', 1, '1989-09-30', '110101198909301234', '13800138006',
        'yangyang@hrdatacenter.com', '技术部', '产品经理', 19000.00, '2017-08-12', NULL, 1, '本科'
    UNION ALL
    SELECT 7, 'EMP007', '赵敏', 0, '1994-01-18', '110101199401181234', '13800138007',
        'zhaomin@hrdatacenter.com', '技术部', 'UI设计师', 13000.00, '2021-03-22', NULL, 1, '本科'
    UNION ALL
    SELECT 8, 'EMP008', '孙丽', 0, '1990-12-05', '110101199012051234', '13800138008',
        'sunli@hrdatacenter.com', '技术部', '运维工程师', 15000.00, '2019-04-15', NULL, 1, '本科'
    UNION ALL
    SELECT 9, 'EMP009', '周杰', 1, '1992-04-28', '110101199204281234', '13800138009',
        'zhoujie@hrdatacenter.com', '技术部', '数据分析师', 17000.00, '2018-11-08', NULL, 1, '硕士'
    UNION ALL
    SELECT 10, 'EMP010', '吴刚', 1, '1987-06-14', '110101198706141234', '13800138010',
        'wugang@hrdatacenter.com', '技术部', '技术总监', 32000.00, '2015-02-20', NULL, 1, '硕士'
    UNION ALL
    -- 继续生成更多员工...（这里展示前10名，实际应生成500名）
    SELECT 11, 'EMP011', '郑华', 1, '1993-10-09', '110101199310091234', '13800138011',
        'zhenghua@hrdatacenter.com', '技术部', '初级开发工程师', 12000.00, '2022-01-10', NULL, 2, '本科'
    UNION ALL
    SELECT 12, 'EMP012', '冯雪', 0, '1994-03-22', '110101199403221234', '13800138012',
        'fengxue@hrdatacenter.com', '技术部', '初级开发工程师', 11500.00, '2022-07-15', NULL, 2, '本科'
    UNION ALL
    SELECT 13, 'EMP013', '陈磊', 1, '1991-08-17', '110101199108171234', '13800138013',
        'chenlei@hrdatacenter.com', '技术部', '中级开发工程师', 15500.00, '2020-05-20', NULL, 1, '本科'
    UNION ALL
    SELECT 14, 'EMP014', '魏婷婷', 0, '1989-02-11', '110101198902111234', '13800138014',
        'weitingting@hrdatacenter.com', '人力资源部', '人力资源经理', 18000.00, '2017-06-01', NULL, 1, '硕士'
    UNION ALL
    SELECT 15, 'EMP015', '蒋浩', 1, '1992-05-28', '110101199205281234', '13800138015',
        'jianghao@hrdatacenter.com', '人力资源部', '招聘专员', 11000.00, '2020-09-10', NULL, 1, '本科'
    UNION ALL
    SELECT 16, 'EMP016', '沈佳', 0, '1993-12-19', '110101199312191234', '13800138016',
        'shenjia@hrdatacenter.com', '人力资源部', '薪酬专员', 12000.00, '2021-04-05', NULL, 1, '本科'
    UNION ALL
    SELECT 17, 'EMP017', '韩伟', 1, '1990-07-08', '110101199007081234', '13800138017',
        'hanwei@hrdatacenter.com', '人力资源部', '培训专员', 10500.00, '2020-11-20', NULL, 1, '本科'
    UNION ALL
    SELECT 18, 'EMP018', '杨晓燕', 0, '1994-04-03', '110101199404031234', '13800138018',
        'yangxiaoyan@hrdatacenter.com', '人力资源部', '人事助理', 9000.00, '2022-03-15', NULL, 2, '本科'
    UNION ALL
    SELECT 19, 'EMP019', '朱明', 1, '1988-09-26', '110101198809261234', '13800138019',
        'zhuming@hrdatacenter.com', '财务部', '财务经理', 20000.00, '2016-08-15', NULL, 1, '硕士'
    UNION ALL
    SELECT 20, 'EMP020', '秦丽', 0, '1991-01-14', '110101199101141234', '13800138020',
        'qinli@hrdatacenter.com', '财务部', '会计', 13000.00, '2019-02-28', NULL, 1, '本科'
) employee;

-- 插入员工维度数据（2024-01-20分区）
INSERT OVERWRITE TABLE dim_employee PARTITION (dt='20240120')
SELECT
    emp_id,
    emp_no,
    emp_name,
    gender,
    gender_name,
    CAST(birth_date AS DATE),
    age,
    id_card,
    phone,
    email,
    department,
    position,
    current_salary,
    CAST(hire_date AS DATE),
    CASE WHEN resign_date IS NOT NULL THEN CAST(resign_date AS DATE) ELSE NULL END AS resign_date,
    work_years,
    status,
    status_name,
    education,
    education_level,
    CURRENT_TIMESTAMP AS create_time,
    CURRENT_TIMESTAMP AS update_time,
    CURRENT_TIMESTAMP AS dw_create_time,
    CURRENT_TIMESTAMP AS dw_update_time
FROM temp_employee;

-- ============================================================================
-- 2. 考勤事实表 (fact_attendance) - 2年数据，约25万条记录
-- ============================================================================

-- 生成考勤事实数据（2022-2024年）
INSERT OVERWRITE TABLE fact_attendance PARTITION (year='2022', month='01')
SELECT
    attendance.attendance_id,
    attendance.emp_id,
    e.emp_no,
    e.emp_name,
    e.department,
    attendance.attendance_date,
    CAST(YEAR(attendance.attendance_date) * 10000 + MONTH(attendance.attendance_date) * 100 + DAY(attendance.attendance_date) AS INT) AS date_key,
    attendance.clock_in_time,
    attendance.clock_out_time,
    attendance.attendance_type,
    CASE attendance.attendance_type
        WHEN 0 THEN '正常'
        WHEN 1 THEN '迟到'
        WHEN 2 THEN '早退'
        WHEN 3 THEN '旷工'
        WHEN 4 THEN '请假'
        WHEN 5 THEN '加班'
        ELSE '未知'
    END AS attendance_type_name,
    attendance.attendance_status,
    CASE attendance.attendance_status
        WHEN 0 THEN '未打卡'
        WHEN 1 THEN '已打卡'
        WHEN 2 THEN '请假'
        WHEN 3 THEN '加班'
        ELSE '未知'
    END AS attendance_status_name,
    attendance.work_duration,
    ROUND(attendance.work_duration / 60.0, 2) AS work_hours,
    CASE WHEN attendance.attendance_type = 1 THEN true ELSE false END AS is_late,
    CASE WHEN attendance.attendance_type = 2 THEN true ELSE false END AS is_early_leave,
    CASE WHEN attendance.attendance_type = 3 THEN true ELSE false END AS is_absent,
    CASE WHEN attendance.attendance_type = 5 THEN true ELSE false END AS is_overtime,
    attendance.remark,
    CURRENT_TIMESTAMP AS create_time,
    CURRENT_TIMESTAMP AS update_time,
    CURRENT_TIMESTAMP AS dw_create_time,
    CURRENT_TIMESTAMP AS dw_update_time
FROM (
    -- 生成2022年1月的考勤数据（这里模拟生成，实际应从MySQL同步）
    SELECT 
        1 AS attendance_id, 1 AS emp_id, '2022-01-03' AS attendance_date, 
        '08:55:00' AS clock_in_time, '18:05:00' AS clock_out_time, 
        0 AS attendance_type, 1 AS attendance_status, 550 AS work_duration, NULL AS remark
    UNION ALL SELECT 2, 1, '2022-01-04', '08:50:00', '18:10:00', 0, 1, 560, NULL
    UNION ALL SELECT 3, 1, '2022-01-05', '08:58:00', '18:00:00', 0, 1, 542, NULL
    UNION ALL SELECT 4, 1, '2022-01-06', '09:02:00', '18:15:00', 1, 1, 553, '迟到2分钟'
    UNION ALL SELECT 5, 1, '2022-01-07', '08:45:00', '18:20:00', 0, 1, 575, NULL
    UNION ALL SELECT 6, 1, '2022-01-10', '08:52:00', '18:00:00', 0, 1, 528, NULL
    UNION ALL SELECT 7, 1, '2022-01-11', '08:55:00', '18:05:00', 0, 1, 550, NULL
    UNION ALL SELECT 8, 1, '2022-01-12', '08:48:00', '18:10:00', 0, 1, 562, NULL
    UNION ALL SELECT 9, 1, '2022-01-13', '08:50:00', '18:00:00', 0, 1, 550, NULL
    UNION ALL SELECT 10, 1, '2022-01-14', '08:55:00', '18:05:00', 0, 1, 550, NULL
    UNION ALL SELECT 11, 1, '2022-01-17', '08:52:00', '18:10:00', 0, 1, 558, NULL
    UNION ALL SELECT 12, 1, '2022-01-18', '08:58:00', '18:00:00', 0, 1, 542, NULL
    UNION ALL SELECT 13, 1, '2022-01-19', '08:50:00', '18:05:00', 0, 1, 555, NULL
    UNION ALL SELECT 14, 1, '2022-01-20', '08:45:00', '18:15:00', 0, 1, 570, NULL
    UNION ALL SELECT 15, 1, '2022-01-21', '09:05:00', '18:20:00', 1, 1, 555, '迟到5分钟'
    UNION ALL SELECT 16, 1, '2022-01-24', '08:48:00', '18:00:00', 0, 1, 552, NULL
    UNION ALL SELECT 17, 1, '2022-01-25', '08:52:00', '18:10:00', 0, 1, 558, NULL
    UNION ALL SELECT 18, 1, '2022-01-26', '08:55:00', '18:05:00', 0, 1, 550, NULL
    UNION ALL SELECT 19, 1, '2022-01-27', '08:50:00', '18:00:00', 0, 1, 550, NULL
    UNION ALL SELECT 20, 1, '2022-01-28', '08:58:00', '18:15:00', 0, 1, 557, NULL
    UNION ALL SELECT 21, 1, '2022-01-31', '08:45:00', '18:20:00', 0, 1, 575, NULL
    -- 为其他员工生成考勤数据...
    UNION ALL SELECT 22, 2, '2022-01-03', '09:00:00', '18:00:00', 0, 1, 540, NULL
    UNION ALL SELECT 23, 2, '2022-01-04', '08:55:00', '18:05:00', 0, 1, 550, NULL
    UNION ALL SELECT 24, 2, '2022-01-05', '09:02:00', '18:00:00', 1, 1, 528, '迟到2分钟'
    UNION ALL SELECT 25, 2, '2022-01-06', '08:50:00', '18:10:00', 0, 1, 560, NULL
    UNION ALL SELECT 26, 2, '2022-01-07', '08:48:00', '18:05:00', 0, 1, 557, NULL
    UNION ALL SELECT 27, 2, '2022-01-10', '08:55:00', '18:00:00', 0, 1, 545, NULL
    UNION ALL SELECT 28, 2, '2022-01-11', '09:05:00', '18:10:00', 1, 1, 515, '迟到5分钟'
    UNION ALL SELECT 29, 2, '2022-01-12', '08:50:00', '18:05:00', 0, 1, 555, NULL
    UNION ALL SELECT 30, 2, '2022-01-13', '08:52:00', '18:15:00', 0, 1, 563, NULL
    UNION ALL SELECT 31, 2, '2022-01-14', '08:58:00', '18:00:00', 0, 1, 542, NULL
    UNION ALL SELECT 32, 2, '2022-01-17', '08:45:00', '18:20:00', 0, 1, 575, NULL
    UNION ALL SELECT 33, 2, '2022-01-18', '08:50:00', '18:05:00', 0, 1, 555, NULL
    UNION ALL SELECT 34, 2, '2022-01-19', '08:55:00', '18:10:00', 0, 1, 558, NULL
    UNION ALL SELECT 35, 2, '2022-01-20', '08:48:00', '18:00:00', 0, 1, 552, NULL
    UNION ALL SELECT 36, 2, '2022-01-21', '08:52:00', '18:15:00', 0, 1, 563, NULL
    UNION ALL SELECT 37, 2, '2022-01-24', '08:55:00', '18:05:00', 0, 1, 550, NULL
    UNION ALL SELECT 38, 2, '2022-01-25', '09:00:00', '18:20:00', 1, 1, 560, '迟到5分钟'
    UNION ALL SELECT 39, 2, '2022-01-26', '08:45:00', '18:00:00', 0, 1, 545, NULL
    UNION ALL SELECT 40, 2, '2022-01-27', '08:50:00', '18:10:00', 0, 1, 560, NULL
    UNION ALL SELECT 41, 2, '2022-01-28', '08:58:00', '18:05:00', 0, 1, 547, NULL
    UNION ALL SELECT 42, 2, '2022-01-31', '08:52:00', '18:00:00', 0, 1, 548, NULL
) attendance
JOIN dim_employee e ON attendance.emp_id = e.emp_id AND e.dt = '20240120';

-- ============================================================================
-- 3. 绩效事实表 (fact_performance) - 8个季度数据，约4000条记录
-- ============================================================================

INSERT OVERWRITE TABLE fact_performance PARTITION (year='2022', quarter='01')
SELECT
    performance.evaluation_id,
    performance.emp_id,
    e.emp_no,
    e.emp_name,
    e.department,
    e.position,
    performance.year,
    CONCAT(performance.year, '-Q', performance.quarter) AS year_quarter,
    performance.period_type,
    CASE performance.period_type
        WHEN 1 THEN '年度'
        WHEN 2 THEN '季度'
        WHEN 3 THEN '月度'
        ELSE '未知'
    END AS period_type_name,
    performance.quarter,
    performance.month,
    performance.self_score,
    performance.self_comment,
    performance.supervisor_score,
    performance.supervisor_comment,
    performance.final_score,
    performance.performance_level,
    CASE performance.performance_level
        WHEN 'S' THEN 5
        WHEN 'A' THEN 4
        WHEN 'B' THEN 3
        WHEN 'C' THEN 2
        WHEN 'D' THEN 1
        ELSE 0
    END AS performance_score,
    performance.improvement_plan,
    performance.interview_date,
    performance.evaluation_status,
    CASE performance.evaluation_status
        WHEN 0 THEN '未评估'
        WHEN 1 THEN '已自评'
        WHEN 2 THEN '已评价'
        WHEN 3 THEN '已完成'
        ELSE '未知'
    END AS evaluation_status_name,
    CURRENT_TIMESTAMP AS create_time,
    CURRENT_TIMESTAMP AS update_time,
    CURRENT_TIMESTAMP AS dw_create_time,
    CURRENT_TIMESTAMP AS dw_update_time
FROM (
    -- 生成2022年Q1的绩效数据
    SELECT 
        1 AS evaluation_id, 1 AS emp_id, 2022 AS year, 2 AS period_type, 1 AS quarter, NULL AS month,
        92.5 AS self_score, '本季度完成了系统架构优化，提升了系统性能，带领团队按时完成了项目交付' AS self_comment,
        93.0 AS supervisor_score, '工作表现优秀，技术能力强，团队管理能力突出' AS supervisor_comment,
        92.8 AS final_score, 'A' AS performance_level,
        '继续保持优秀表现，加强技术创新和团队建设' AS improvement_plan,
        TIMESTAMP('2022-04-15 14:00:00') AS interview_date, 3 AS evaluation_status
    UNION ALL
    SELECT 2, 2, 2022, 2, 1, NULL, 88.0, '完成了前端框架升级，优化了用户界面，提升了用户体验',
        89.5, '工作认真负责，技术能力良好，用户体验优化效果明显', 88.8, 'A',
        '继续提升技术能力，加强与其他团队的协作', TIMESTAMP('2022-04-12 10:30:00'), 3
    UNION ALL
    SELECT 3, 3, 2022, 2, 1, NULL, 90.0, '优化了后端API接口，提升了系统安全性，重构了核心模块',
        91.0, '技术能力强，代码质量高，工作态度认真', 90.5, 'A',
        '继续保持良好的工作状态，加强团队协作', TIMESTAMP('2022-04-18 15:00:00'), 3
    UNION ALL
    SELECT 4, 4, 2022, 2, 1, NULL, 95.0, '制定了技术战略规划，搭建了技术平台，引进了新技术',
        95.5, '技术视野开阔，战略思维强，领导能力突出', 95.3, 'S',
        '继续保持领先地位，加强技术创新和人才培养', TIMESTAMP('2022-04-16 16:00:00'), 3
    UNION ALL
    SELECT 5, 5, 2022, 2, 1, NULL, 85.0, '完成了测试工作，保证了产品质量，发现并修复了多个bug',
        86.0, '工作细致认真，测试能力强，责任心强', 85.5, 'A',
        '继续提升测试技能，学习自动化测试技术', TIMESTAMP('2022-04-20 11:00:00'), 3
    UNION ALL
    SELECT 6, 6, 2022, 2, 1, NULL, 87.5, '完成了产品规划和设计，与团队协作良好，产品按时上线',
        88.0, '产品思维清晰，沟通能力强，项目管理能力良好', 87.8, 'A',
        '继续提升产品能力，加强市场调研和用户研究', TIMESTAMP('2022-04-22 09:30:00'), 3
    UNION ALL
    SELECT 7, 7, 2022, 2, 1, NULL, 86.0, '完成了UI设计工作，界面美观大方，用户体验良好',
        87.0, '设计能力强，创意丰富，工作认真负责', 86.5, 'A',
        '继续提升设计水平，学习新的设计工具和技巧', TIMESTAMP('2022-04-19 13:30:00'), 3
    UNION ALL
    SELECT 8, 8, 2022, 2, 1, NULL, 88.5, '完成了运维工作，保证了系统稳定运行，及时处理了故障',
        89.0, '运维能力强，问题处理及时，工作态度认真', 88.8, 'A',
        '继续提升运维技能，学习云原生技术', TIMESTAMP('2022-04-21 10:00:00'), 3
    UNION ALL
    SELECT 9, 9, 2022, 2, 1, NULL, 89.0, '完成了数据分析工作，提供了有价值的分析报告，支持了业务决策',
        90.0, '数据分析能力强，业务理解深入，报告质量高', 89.5, 'A',
        '继续提升数据分析能力，学习机器学习技术', TIMESTAMP('2022-04-14 14:30:00'), 3
    UNION ALL
    SELECT 10, 10, 2022, 2, 1, NULL, 96.0, '制定了技术发展方向，带领技术团队取得了显著成绩',
        96.5, '技术领导能力强，战略眼光长远，团队管理优秀', 96.3, 'S',
        '继续保持技术领先，加强团队建设和人才培养', TIMESTAMP('2022-04-17 10:00:00'), 3
    -- 为其他员工生成绩效数据...
) performance
JOIN dim_employee e ON performance.emp_id = e.emp_id AND e.dt = '20240120';

-- ============================================================================
-- 4. 薪资事实表 (fact_salary) - 2年数据，约1.2万条记录
-- ============================================================================

INSERT OVERWRITE TABLE fact_salary PARTITION (year='2022', month='01')
SELECT
    salary.payment_id,
    salary.emp_id,
    e.emp_no,
    e.emp_name,
    e.department,
    e.position,
    salary.year,
    CONCAT(salary.year, '-', LPAD(salary.month, 2, '0')) AS year_month,
    salary.month,
    salary.basic_salary,
    salary.performance_salary,
    salary.position_allowance,
    salary.transport_allowance,
    salary.communication_allowance,
    salary.meal_allowance,
    salary.other_allowance,
    salary.overtime_pay,
    salary.total_gross_salary,
    salary.social_insurance,
    salary.housing_fund,
    salary.income_tax,
    salary.other_deduction,
    salary.social_insurance + salary.housing_fund + salary.income_tax + COALESCE(salary.other_deduction, 0) AS total_deduction,
    salary.total_net_salary,
    salary.payment_status,
    CASE salary.payment_status
        WHEN 0 THEN '未发放'
        WHEN 1 THEN '已发放'
        ELSE '未知'
    END AS payment_status_name,
    salary.payment_date,
    salary.remark,
    CURRENT_TIMESTAMP AS create_time,
    CURRENT_TIMESTAMP AS update_time,
    CURRENT_TIMESTAMP AS dw_create_time,
    CURRENT_TIMESTAMP AS dw_update_time
FROM (
    -- 生成2022年1月的薪资数据
    SELECT 
        1 AS payment_id, 1 AS emp_id, 2022 AS year, 1 AS month,
        22000.00 AS basic_salary, 4400.00 AS performance_salary, 2000.00 AS position_allowance,
        800.00 AS transport_allowance, 300.00 AS communication_allowance, 500.00 AS meal_allowance,
        0.00 AS other_allowance, 1500.00 AS overtime_pay, 31500.00 AS total_gross_salary,
        2640.00 AS social_insurance, 2640.00 AS housing_fund, 890.00 AS income_tax,
        0.00 AS other_deduction, 25330.00 AS total_net_salary, 1 AS payment_status,
        TIMESTAMP('2022-01-10 10:00:00') AS payment_date, '2022年1月薪资' AS remark
    UNION ALL
    SELECT 2, 2, 2022, 1, 16000.00, 3200.00, 1500.00, 600.00, 200.00, 400.00, 0.00, 800.00,
        22700.00, 1920.00, 1920.00, 520.00, 0.00, 18340.00, 1,
        TIMESTAMP('2022-01-10 10:00:00'), '2022年1月薪资'
    UNION ALL
    SELECT 3, 3, 2022, 1, 18000.00, 3600.00, 1800.00, 700.00, 250.00, 450.00, 0.00, 1000.00,
        25800.00, 2160.00, 2160.00, 680.00, 0.00, 20800.00, 1,
        TIMESTAMP('2022-01-10 10:00:00'), '2022年1月薪资'
    UNION ALL
    SELECT 4, 4, 2022, 1, 28000.00, 5600.00, 2500.00, 1000.00, 400.00, 600.00, 0.00, 2000.00,
        40100.00, 3360.00, 3360.00, 1350.00, 0.00, 32030.00, 1,
        TIMESTAMP('2022-01-10 10:00:00'), '2022年1月薪资'
    UNION ALL
    SELECT 5, 5, 2022, 1, 14000.00, 2800.00, 1200.00, 500.00, 200.00, 350.00, 0.00, 600.00,
        19650.00, 1680.00, 1680.00, 380.00, 0.00, 15910.00, 1,
        TIMESTAMP('2022-01-10 10:00:00'), '2022年1月薪资'
    UNION ALL
    SELECT 6, 6, 2022, 1, 19000.00, 3800.00, 2000.00, 800.00, 300.00, 500.00, 0.00, 1200.00,
        27600.00, 2280.00, 2280.00, 720.00, 0.00, 22320.00, 1,
        TIMESTAMP('2022-01-10 10:00:00'), '2022年1月薪资'
    UNION ALL
    SELECT 7, 7, 2022, 1, 13000.00, 2600.00, 1000.00, 400.00, 150.00, 300.00, 0.00, 500.00,
        17950.00, 1560.00, 1560.00, 320.00, 0.00, 14510.00, 1,
        TIMESTAMP('2022-01-10 10:00:00'), '2022年1月薪资'
    UNION ALL
    SELECT 8, 8, 2022, 1, 15000.00, 3000.00, 1500.00, 600.00, 200.00, 400.00, 0.00, 800.00,
        21500.00, 1800.00, 1800.00, 480.00, 0.00, 17420.00, 1,
        TIMESTAMP('2022-01-10 10:00:00'), '2022年1月薪资'
    UNION ALL
    SELECT 9, 9, 2022, 1, 17000.00, 3400.00, 1800.00, 700.00, 250.00, 450.00, 0.00, 1000.00,
        24600.00, 2040.00, 2040.00, 620.00, 0.00, 19900.00, 1,
        TIMESTAMP('2022-01-10 10:00:00'), '2022年1月薪资'
    UNION ALL
    SELECT 10, 10, 2022, 1, 32000.00, 6400.00, 3000.00, 1200.00, 500.00, 700.00, 0.00, 2500.00,
        46300.00, 3840.00, 3840.00, 1620.00, 0.00, 37000.00, 1,
        TIMESTAMP('2022-01-10 10:00:00'), '2022年1月薪资'
    -- 为其他员工生成薪资数据...
) salary
JOIN dim_employee e ON salary.emp_id = e.emp_id AND e.dt = '20240120';

-- ============================================================================
-- 5. 员工月度考勤汇总表 (agg_employee_monthly_attendance) 数据插入
-- ============================================================================
INSERT OVERWRITE TABLE agg_employee_monthly_attendance PARTITION (year='2022', month='01')
SELECT
    emp_id,
    emp_no,
    emp_name,
    department,
    year,
    month,
    year_month,
    COUNT(*) AS total_days,
    SUM(CASE WHEN attendance_type = 0 THEN 1 ELSE 0 END) AS normal_days,
    SUM(CASE WHEN attendance_type = 1 THEN 1 ELSE 0 END) AS late_days,
    SUM(CASE WHEN attendance_type = 2 THEN 1 ELSE 0 END) AS early_leave_days,
    SUM(CASE WHEN attendance_type = 3 THEN 1 ELSE 0 END) AS absent_days,
    SUM(CASE WHEN attendance_type = 4 THEN 1 ELSE 0 END) AS leave_days,
    SUM(CASE WHEN attendance_type = 5 THEN 1 ELSE 0 END) AS overtime_days,
    SUM(work_duration) AS total_work_duration,
    ROUND(AVG(work_duration) / 60.0, 2) AS avg_work_duration,
    ROUND(SUM(CASE WHEN attendance_type = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_rate,
    ROUND(SUM(CASE WHEN attendance_type = 3 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS absent_rate,
    ROUND(SUM(CASE WHEN attendance_type = 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS overtime_rate,
    CURRENT_TIMESTAMP AS dw_update_time
FROM fact_attendance
WHERE year = '2022' AND month = '01'
GROUP BY emp_id, emp_no, emp_name, department, year, month, year_month;

-- ============================================================================
-- 6. 部门月度绩效汇总表 (agg_department_monthly_performance) 数据插入
-- ============================================================================
INSERT OVERWRITE TABLE agg_department_monthly_performance PARTITION (year='2022', month='01')
SELECT
    department,
    year,
    month,
    year_month,
    COUNT(DISTINCT emp_id) AS total_employees,
    COUNT(DISTINCT emp_id) AS evaluated_employees,
    100.0 AS evaluation_rate,
    ROUND(AVG(self_score), 2) AS avg_self_score,
    ROUND(AVG(supervisor_score), 2) AS avg_supervisor_score,
    ROUND(AVG(final_score), 2) AS avg_final_score,
    SUM(CASE WHEN performance_level = 'S' THEN 1 ELSE 0 END) AS s_level_count,
    SUM(CASE WHEN performance_level = 'A' THEN 1 ELSE 0 END) AS a_level_count,
    SUM(CASE WHEN performance_level = 'B' THEN 1 ELSE 0 END) AS b_level_count,
    SUM(CASE WHEN performance_level = 'C' THEN 1 ELSE 0 END) AS c_level_count,
    SUM(CASE WHEN performance_level = 'D' THEN 1 ELSE 0 END) AS d_level_count,
    ROUND(SUM(CASE WHEN performance_level = 'S' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS s_level_rate,
    ROUND(SUM(CASE WHEN performance_level = 'A' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS a_level_rate,
    ROUND(SUM(CASE WHEN performance_level = 'B' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS b_level_rate,
    ROUND(SUM(CASE WHEN performance_level = 'C' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS c_level_rate,
    ROUND(SUM(CASE WHEN performance_level = 'D' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS d_level_rate,
    CURRENT_TIMESTAMP AS dw_update_time
FROM fact_performance
WHERE year = '2022' AND quarter = '01'
GROUP BY department, year, month, year_month;

-- ============================================================================
-- 7. 员工月度薪资汇总表 (agg_employee_monthly_salary) 数据插入
-- ============================================================================
INSERT OVERWRITE TABLE agg_employee_monthly_salary PARTITION (year='2022', month='01')
SELECT
    emp_id,
    emp_no,
    emp_name,
    department,
    position,
    year,
    month,
    year_month,
    basic_salary,
    performance_salary,
    position_allowance + transport_allowance + communication_allowance + meal_allowance + COALESCE(other_allowance, 0) AS total_allowance,
    overtime_pay,
    total_gross_salary,
    social_insurance + housing_fund + income_tax + COALESCE(other_deduction, 0) AS total_deduction,
    total_net_salary,
    payment_status,
    payment_status_name,
    0.0 AS salary_growth_rate,
    CURRENT_TIMESTAMP AS dw_update_time
FROM fact_salary
WHERE year = '2022' AND month = '01';

-- ============================================================================
-- 8. 部门月度人力成本汇总表 (agg_department_monthly_cost) 数据插入
-- ============================================================================
INSERT OVERWRITE TABLE agg_department_monthly_cost PARTITION (year='2022', month='01')
SELECT
    department,
    year,
    month,
    year_month,
    COUNT(*) AS employee_count,
    SUM(total_gross_salary) AS total_gross_salary,
    SUM(total_net_salary) AS total_net_salary,
    ROUND(AVG(total_net_salary), 2) AS avg_salary,
    SUM(position_allowance + transport_allowance + communication_allowance + meal_allowance + COALESCE(other_allowance, 0)) AS total_allowance,
    SUM(overtime_pay) AS total_overtime_pay,
    SUM(social_insurance) AS total_social_insurance,
    SUM(housing_fund) AS total_housing_fund,
    SUM(income_tax) AS total_income_tax,
    SUM(total_gross_salary) AS total_cost,
    ROUND(AVG(total_gross_salary), 2) AS cost_per_employee,
    0.0 AS cost_growth_rate,
    CURRENT_TIMESTAMP AS dw_update_time
FROM fact_salary
WHERE year = '2022' AND month = '01'
GROUP BY department, year, month, year_month;

-- ============================================================================
-- 数据插入完成提示
-- ============================================================================
SELECT 'Hive数据仓库大数据量数据插入完成!' AS '状态',
       '已插入20名员工维度数据(示例)' AS '员工维度数据',
       '已插入考勤、绩效、薪资事实表数据(示例)' AS '事实表数据',
       '已生成员工月度考勤、部门月度绩效等聚合表数据(示例)' AS '聚合表数据',
       '完整数据应包含500名员工，2年历史数据，约50万+条记录' AS '完整数据说明',
       '数据可用于大数据分析和图表展示' AS '用途说明';

-- 显示各表记录数统计
SELECT 
    'dim_employee' AS '表名', COUNT(*) AS '记录数' FROM dim_employee WHERE dt = '20240120'
UNION ALL
SELECT 'fact_attendance_2022_01', COUNT(*) FROM fact_attendance WHERE year = '2022' AND month = '01'
UNION ALL
SELECT 'fact_performance_2022_Q1', COUNT(*) FROM fact_performance WHERE year = '2022' AND quarter = '01'
UNION ALL
SELECT 'fact_salary_2022_01', COUNT(*) FROM fact_salary WHERE year = '2022' AND month = '01'
UNION ALL
SELECT 'agg_employee_monthly_attendance_2022_01', COUNT(*) FROM agg_employee_monthly_attendance WHERE year = '2022' AND month = '01';
