-- ============================================================================
-- 人力资源数据中心系统 - Hive数据仓库数据插入脚本【修复版】
-- 版本: 1.1
-- 说明: 50名员工，单月数据，无语法错误，可直接运行
-- ============================================================================
USE hr_datacenter_dw;

-- ============================================================================
-- 1. 员工维度表 (dim_employee) 数据插入 - 50名员工
-- ============================================================================
INSERT OVERWRITE TABLE dim_employee PARTITION (dt='20240120')
VALUES
(1, 'EMP001', '张伟', 1, '男', '1990-05-15', 33, '110101199005151234', '13800138001', 'zhangwei@hrdatacenter.com', '技术部', '高级软件工程师', 22000.00, '2018-03-15', NULL, 5, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'EMP002', '李娜', 0, '女', '1992-08-22', 31, '110101199208221234', '13800138002', 'lina@hrdatacenter.com', '技术部', '前端开发工程师', 16000.00, '2019-06-10', NULL, 4, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 'EMP003', '王芳', 0, '女', '1991-11-08', 32, '110101199111081234', '13800138003', 'wangfang@hrdatacenter.com', '技术部', '后端开发工程师', 18000.00, '2018-09-20', NULL, 5, 1, '在职', '硕士', 4, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, 'EMP004', '刘强', 1, '男', '1988-03-25', 35, '110101198803251234', '13800138004', 'liuqiang@hrdatacenter.com', '技术部', '架构师', 28000.00, '2016-05-18', NULL, 7, 1, '在职', '硕士', 4, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(5, 'EMP005', '陈静', 0, '女', '1993-07-12', 30, '110101199307121234', '13800138005', 'chenjing@hrdatacenter.com', '技术部', '测试工程师', 14000.00, '2020-02-28', NULL, 3, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(6, 'EMP006', '杨洋', 1, '男', '1989-09-30', 34, '110101198909301234', '13800138006', 'yangyang@hrdatacenter.com', '技术部', '产品经理', 19000.00, '2017-08-12', NULL, 6, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(7, 'EMP007', '赵敏', 0, '女', '1994-01-18', 29, '110101199401181234', '13800138007', 'zhaomin@hrdatacenter.com', '技术部', 'UI设计师', 13000.00, '2021-03-22', NULL, 2, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(8, 'EMP008', '孙丽', 0, '女', '1990-12-05', 33, '110101199012051234', '13800138008', 'sunli@hrdatacenter.com', '技术部', '运维工程师', 15000.00, '2019-04-15', NULL, 4, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(9, 'EMP009', '周杰', 1, '男', '1992-04-28', 31, '110101199204281234', '13800138009', 'zhoujie@hrdatacenter.com', '技术部', '数据分析师', 17000.00, '2018-11-08', NULL, 5, 1, '在职', '硕士', 4, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(10, 'EMP010', '吴刚', 1, '男', '1987-06-14', 36, '110101198706141234', '13800138010', 'wugang@hrdatacenter.com', '技术部', '技术总监', 32000.00, '2015-02-20', NULL, 8, 1, '在职', '硕士', 4, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(11, 'EMP011', '郑华', 1, '男', '1993-10-09', 30, '110101199310091234', '13800138011', 'zhenghua@hrdatacenter.com', '技术部', '初级开发工程师', 12000.00, '2022-01-10', NULL, 2, 2, '试用', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(12, 'EMP012', '冯雪', 0, '女', '1994-03-22', 29, '110101199403221234', '13800138012', 'fengxue@hrdatacenter.com', '技术部', '初级开发工程师', 11500.00, '2022-07-15', NULL, 1, 2, '试用', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(13, 'EMP013', '陈磊', 1, '男', '1991-08-17', 32, '110101199108171234', '13800138013', 'chenlei@hrdatacenter.com', '技术部', '中级开发工程师', 15500.00, '2020-05-20', NULL, 3, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(14, 'EMP014', '魏婷婷', 0, '女', '1989-02-11', 34, '110101198902111234', '13800138014', 'weitingting@hrdatacenter.com', '人力资源部', '人力资源经理', 18000.00, '2017-06-01', NULL, 6, 1, '在职', '硕士', 4, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(15, 'EMP015', '蒋浩', 1, '男', '1992-05-28', 31, '110101199205281234', '13800138015', 'jianghao@hrdatacenter.com', '人力资源部', '招聘专员', 11000.00, '2020-09-10', NULL, 3, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(16, 'EMP016', '沈佳', 0, '女', '1993-12-19', 30, '110101199312191234', '13800138016', 'shenjia@hrdatacenter.com', '人力资源部', '薪酬专员', 12000.00, '2021-04-05', NULL, 2, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(17, 'EMP017', '韩伟', 1, '男', '1990-07-08', 33, '110101199007081234', '13800138017', 'hanwei@hrdatacenter.com', '人力资源部', '培训专员', 10500.00, '2020-11-20', NULL, 3, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(18, 'EMP018', '杨晓燕', 0, '女', '1994-04-03', 29, '110101199404031234', '13800138018', 'yangxiaoyan@hrdatacenter.com', '人力资源部', '人事助理', 9000.00, '2022-03-15', NULL, 1, 2, '试用', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(19, 'EMP019', '朱明', 1, '男', '1988-09-26', 35, '110101198809261234', '13800138019', 'zhuming@hrdatacenter.com', '财务部', '财务经理', 20000.00, '2016-08-15', NULL, 7, 1, '在职', '硕士', 4, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(20, 'EMP020', '秦丽', 0, '女', '1991-01-14', 32, '110101199101141234', '13800138020', 'qinli@hrdatacenter.com', '财务部', '会计', 13000.00, '2019-02-28', NULL, 4, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(21, 'EMP021', '许强', 1, '男', '1992-06-22', 31, '110101199206221234', '13800138021', 'xuqiang@hrdatacenter.com', '财务部', '出纳', 10000.00, '2020-08-10', NULL, 3, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(22, 'EMP022', '何芳', 0, '女', '1993-11-09', 30, '110101199311091234', '13800138022', 'hefang@hrdatacenter.com', '财务部', '成本会计', 14000.00, '2019-12-15', NULL, 4, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(23, 'EMP023', '吕伟', 1, '男', '1990-03-31', 33, '110101199003311234', '13800138023', 'lvwei@hrdatacenter.com', '财务部', '税务专员', 12000.00, '2020-05-20', NULL, 3, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(24, 'EMP024', '施娜', 0, '女', '1989-07-18', 34, '110101198907181234', '13800138024', 'shina@hrdatacenter.com', '市场部', '市场经理', 22000.00, '2017-04-20', NULL, 6, 1, '在职', '硕士', 4, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(25, 'EMP025', '张涛', 1, '男', '1991-10-25', 32, '110101199110251234', '13800138025', 'zhangtao@hrdatacenter.com', '市场部', '销售经理', 19000.00, '2018-06-15', NULL, 5, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(26, 'EMP026', '孔杰', 1, '男', '1992-02-14', 31, '110101199202141234', '13800138026', 'kongjie@hrdatacenter.com', '市场部', '销售代表', 11000.00, '2020-09-01', NULL, 3, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(27, 'EMP027', '曹丽', 0, '女', '1993-05-30', 30, '110101199305301234', '13800138027', 'caoli@hrdatacenter.com', '市场部', '销售代表', 10500.00, '2021-01-20', NULL, 2, 2, '试用', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(28, 'EMP028', '严伟', 1, '男', '1990-08-07', 33, '110101199008071234', '13800138028', 'yanwei@hrdatacenter.com', '市场部', '销售代表', 10800.00, '2020-11-10', NULL, 3, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(29, 'EMP029', '华雪', 0, '女', '1994-01-22', 29, '110101199401221234', '13800138029', 'huaxue@hrdatacenter.com', '市场部', '市场专员', 9500.00, '2022-04-18', NULL, 1, 2, '试用', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(30, 'EMP030', '金明', 1, '男', '1991-12-11', 32, '110101199112111234', '13800138030', 'jinming@hrdatacenter.com', '市场部', '品牌专员', 11500.00, '2020-07-25', NULL, 3, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(31, 'EMP031', '魏强', 1, '男', '1988-04-15', 35, '110101198804151234', '13800138031', 'weiqiang@hrdatacenter.com', '运营部', '运营总监', 25000.00, '2016-10-08', NULL, 7, 1, '在职', '硕士', 4, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(32, 'EMP032', '陶丽', 0, '女', '1990-06-28', 33, '110101199006281234', '13800138032', 'taoli@hrdatacenter.com', '运营部', '产品运营', 14000.00, '2019-03-12', NULL, 4, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(33, 'EMP033', '姜娜', 0, '女', '1992-09-17', 31, '110101199209171234', '13800138033', 'jiangna@hrdatacenter.com', '运营部', '用户运营', 13000.00, '2019-08-20', NULL, 4, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(34, 'EMP034', '戚伟', 1, '男', '1993-02-05', 30, '110101199302051234', '13800138034', 'qiwei@hrdatacenter.com', '运营部', '内容运营', 12500.00, '2020-05-15', NULL, 3, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(35, 'EMP035', '谢芳', 0, '女', '1991-11-23', 32, '110101199111231234', '13800138035', 'xiefang@hrdatacenter.com', '运营部', '活动策划', 12000.00, '2020-10-08', NULL, 3, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(36, 'EMP036', '邹华', 1, '男', '1989-03-19', 34, '110101198903191234', '13800138036', 'zouhua@hrdatacenter.com', '客服部', '客服经理', 16000.00, '2017-09-05', NULL, 6, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(37, 'EMP037', '喻明', 1, '男', '1992-07-02', 31, '110101199207021234', '13800138037', 'yuming@hrdatacenter.com', '客服部', '客服主管', 13000.00, '2019-04-18', NULL, 4, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(38, 'EMP038', '柏丽', 0, '女', '1993-10-14', 30, '110101199310141234', '13800138038', 'baili@hrdatacenter.com', '客服部', '客服专员', 9000.00, '2021-06-10', NULL, 2, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(39, 'EMP039', '窦伟', 1, '男', '1994-05-28', 29, '110101199405281234', '13800138039', 'douwei@hrdatacenter.com', '客服部', '客服专员', 8800.00, '2022-02-20', NULL, 1, 2, '试用', '大专', 2, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(40, 'EMP040', '章雪', 0, '女', '1990-08-31', 33, '110101199008311234', '13800138040', 'zhangxue@hrdatacenter.com', '客服部', '客服专员', 9200.00, '2020-12-15', NULL, 3, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(41, 'EMP041', '云强', 1, '男', '1987-12-07', 36, '110101198712071234', '13800138041', 'yunqiang@hrdatacenter.com', '行政部', '行政经理', 17000.00, '2016-05-22', NULL, 7, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(42, 'EMP042', '苏丽', 0, '女', '1991-04-16', 32, '110101199104161234', '13800138042', 'suli@hrdatacenter.com', '行政部', '行政专员', 10000.00, '2020-01-08', NULL, 4, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(43, 'EMP043', '潘伟', 1, '男', '1992-09-25', 31, '110101199209251234', '13800138043', 'panwei@hrdatacenter.com', '行政部', '后勤专员', 9500.00, '2020-07-30', NULL, 3, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(44, 'EMP044', '葛芳', 0, '女', '1993-02-12', 30, '110101199302121234', '13800138044', 'gefang@hrdatacenter.com', '行政部', '前台接待', 8500.00, '2021-09-15', NULL, 2, 1, '在职', '大专', 2, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(45, 'EMP045', '范明', 1, '男', '1994-06-08', 29, '110101199406081234', '13800138045', 'fanming@hrdatacenter.com', '行政部', '司机', 8000.00, '2022-05-10', NULL, 1, 1, '在职', '高中', 1, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(46, 'EMP046', '彭雪', 0, '女', '1988-10-21', 35, '110101198810211234', '13800138046', 'pengxue@hrdatacenter.com', '研发部', '研发总监', 27000.00, '2016-07-15', NULL, 7, 1, '在职', '博士', 5, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(47, 'EMP047', '鲁伟', 1, '男', '1990-01-09', 33, '110101199001091234', '13800138047', 'luwei@hrdatacenter.com', '研发部', '算法工程师', 21000.00, '2018-02-28', NULL, 5, 1, '在职', '硕士', 4, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(48, 'EMP048', '韦丽', 0, '女', '1991-05-18', 32, '110101199105181234', '13800138048', 'weili@hrdatacenter.com', '研发部', '机器学习工程师', 20000.00, '2018-08-10', NULL, 5, 1, '在职', '硕士', 4, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(49, 'EMP049', '昌华', 1, '男', '1992-08-05', 31, '110101199208051234', '13800138049', 'changhua@hrdatacenter.com', '研发部', '大数据工程师', 18500.00, '2019-03-22', NULL, 4, 1, '在职', '本科', 3, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(50, 'EMP050', '马芳', 0, '女', '1993-11-30', 30, '110101199311301234', '13800138050', 'mafang@hrdatacenter.com', '研发部', '数据工程师', 16500.00, '2019-10-15', NULL, 4, 1, '在职', '硕士', 4, '2024-01-01 10:00:00', '2024-01-19 15:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ============================================================================
-- 2. 考勤事实表 (fact_attendance) 数据插入 - 2024年1月数据
-- ============================================================================
INSERT OVERWRITE TABLE fact_attendance PARTITION (year='2024', month='01')
SELECT
    a.attendance_id,
    a.emp_id,
    e.emp_no,
    e.emp_name,
    e.department,
    a.attendance_date,
    CAST(YEAR(a.attendance_date) * 10000 + MONTH(a.attendance_date) * 100 + DAY(a.attendance_date) AS INT) AS date_key,
    a.clock_in_time,
    a.clock_out_time,
    a.attendance_type,
    CASE a.attendance_type
        WHEN 0 THEN '正常' WHEN 1 THEN '迟到' WHEN 2 THEN '早退' WHEN 3 THEN '旷工' WHEN 4 THEN '请假' WHEN 5 THEN '加班' ELSE '未知'
    END AS attendance_type_name,
    a.attendance_status,
    CASE a.attendance_status
        WHEN 0 THEN '未打卡' WHEN 1 THEN '已打卡' WHEN 2 THEN '请假' WHEN 3 THEN '加班' ELSE '未知'
    END AS attendance_status_name,
    a.work_duration,
    ROUND(a.work_duration / 60.0, 2) AS work_hours,
    (a.attendance_type = 1) AS is_late,
    (a.attendance_type = 2) AS is_early_leave,
    (a.attendance_type = 3) AS is_absent,
    (a.attendance_type = 5) AS is_overtime,
    a.remark,
    a.create_time,
    a.update_time,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (
    SELECT 1 AS attendance_id, 1 AS emp_id, '2024-01-02' AS attendance_date, '08:55:00' AS clock_in_time, '18:05:00' AS clock_out_time, 0 AS attendance_type, 1 AS attendance_status, 550 AS work_duration, NULL AS remark, '2024-01-02 18:10:00' AS create_time, '2024-01-02 18:10:00' AS update_time
    UNION ALL SELECT 2, 1, '2024-01-03', '08:50:00', '18:10:00', 0, 1, 560, NULL, '2024-01-03 18:15:00', '2024-01-03 18:15:00'
    UNION ALL SELECT 3, 1, '2024-01-04', '08:58:00', '18:00:00', 0, 1, 542, NULL, '2024-01-04 18:05:00', '2024-01-04 18:05:00'
    UNION ALL SELECT 4, 1, '2024-01-05', '09:02:00', '18:15:00', 1, 1, 553, '迟到2分钟', '2024-01-05 18:20:00', '2024-01-05 18:20:00'
    UNION ALL SELECT 5, 1, '2024-01-08', '08:45:00', '18:20:00', 0, 1, 575, NULL, '2024-01-08 18:25:00', '2024-01-08 18:25:00'
    UNION ALL SELECT 6, 1, '2024-01-09', '08:52:00', '18:00:00', 0, 1, 528, NULL, '2024-01-09 18:05:00', '2024-01-09 18:05:00'
    UNION ALL SELECT 7, 1, '2024-01-10', '08:55:00', '18:05:00', 0, 1, 550, NULL, '2024-01-10 18:10:00', '2024-01-10 18:10:00'
    UNION ALL SELECT 8, 1, '2024-01-11', '08:48:00', '18:10:00', 0, 1, 562, NULL, '2024-01-11 18:15:00', '2024-01-11 18:15:00'
    UNION ALL SELECT 9, 1, '2024-01-12', '08:50:00', '18:00:00', 0, 1, 550, NULL, '2024-01-12 18:05:00', '2024-01-12 18:05:00'
    UNION ALL SELECT 10, 1, '2024-01-15', '08:55:00', '18:05:00', 0, 1, 550, NULL, '2024-01-15 18:10:00', '2024-01-15 18:10:00'
) a
JOIN dim_employee e ON a.emp_id = e.emp_id AND e.dt = '20240120';

-- ============================================================================
-- 3. 绩效事实表 (fact_performance) 数据插入
-- ============================================================================
INSERT OVERWRITE TABLE fact_performance PARTITION (year='2024', quarter='01')
SELECT
    pe.evaluation_id, pe.emp_id, e.emp_no, e.emp_name, e.department, e.position,
    pe.year, CONCAT(pe.year, '-Q', pe.quarter) AS year_quarter,
    pe.period_type, CASE pe.period_type WHEN 1 THEN '年度' WHEN 2 THEN '季度' WHEN 3 THEN '月度' ELSE '未知' END AS period_type_name,
    pe.quarter, pe.month, pe.self_score, pe.self_comment, pe.supervisor_score, pe.supervisor_comment,
    pe.final_score, pe.performance_level,
    CASE pe.performance_level WHEN 'S' THEN 5 WHEN 'A' THEN 4 WHEN 'B' THEN 3 WHEN 'C' THEN 2 WHEN 'D' THEN 1 ELSE 0 END AS performance_score,
    pe.improvement_plan, pe.interview_date, pe.evaluation_status,
    CASE pe.evaluation_status WHEN 0 THEN '未评估' WHEN 1 THEN '已自评' WHEN 2 THEN '已评价' WHEN 3 THEN '已完成' ELSE '未知' END AS evaluation_status_name,
    pe.create_time, pe.update_time, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (
    SELECT 1 AS evaluation_id, 1 AS emp_id, 2024 AS year, 2 AS period_type, 1 AS quarter, NULL AS month, 92.5 AS self_score, '系统架构优化' AS self_comment, 93.0 AS supervisor_score, '表现优秀' AS supervisor_comment, 92.8 AS final_score, 'A' AS performance_level, '加强技术创新' AS improvement_plan, '2024-01-20 14:00:00' AS interview_date, 3 AS evaluation_status, '2024-01-20 16:00:00' AS create_time, '2024-01-20 16:00:00' AS update_time
    UNION ALL SELECT 2, 2, 2024, 2, 1, NULL, 88.0, '前端升级', 89.5, '工作认真', 88.8, 'A', '提升技术', '2024-01-18 10:30:00', 3, '2024-01-18 12:00:00', '2024-01-18 12:00:00'
) pe
JOIN dim_employee e ON pe.emp_id = e.emp_id AND e.dt = '20240120';

-- ============================================================================
-- 4. 薪资事实表 (fact_salary) 数据插入
-- ============================================================================
INSERT OVERWRITE TABLE fact_salary PARTITION (year='2024', month='01')
SELECT
    sp.payment_id, sp.emp_id, e.emp_no, e.emp_name, e.department, e.position,
    sp.year, CONCAT(sp.year, '-', LPAD(sp.month, 2, '0')) AS year_month, sp.month,
    sp.basic_salary, sp.performance_salary, sp.position_allowance, sp.transport_allowance,
    sp.communication_allowance, sp.meal_allowance, sp.other_allowance, sp.overtime_pay,
    sp.total_gross_salary, sp.social_insurance, sp.housing_fund, sp.income_tax, sp.other_deduction,
    sp.social_insurance + sp.housing_fund + sp.income_tax + COALESCE(sp.other_deduction, 0) AS total_deduction,
    sp.total_net_salary, sp.payment_status,
    CASE sp.payment_status WHEN 0 THEN '未发放' WHEN 1 THEN '已发放' ELSE '未知' END AS payment_status_name,
    sp.payment_date, sp.remark, sp.create_time, sp.update_time, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (
    SELECT 1 AS payment_id, 1 AS emp_id, 2024 AS year, 1 AS month, 22000.00 AS basic_salary, 4400.00 AS performance_salary, 2000.00 AS position_allowance, 800.00 AS transport_allowance, 300.00 AS communication_allowance, 500.00 AS meal_allowance, 0.00 AS other_allowance, 1500.00 AS overtime_pay, 31500.00 AS total_gross_salary, 2640.00 AS social_insurance, 2640.00 AS housing_fund, 890.00 AS income_tax, 0.00 AS other_deduction, 25330.00 AS total_net_salary, 1 AS payment_status, '2024-01-10 10:00:00' AS payment_date, '2024年1月薪资' AS remark, '2024-01-10 10:00:00' AS create_time, '2024-01-10 10:00:00' AS update_time
) sp
JOIN dim_employee e ON sp.emp_id = e.emp_id AND e.dt = '20240120';

-- ============================================================================
-- 5. 聚合表数据插入（已修复分组错误）
-- ============================================================================
-- 员工月度考勤汇总
INSERT OVERWRITE TABLE agg_employee_monthly_attendance PARTITION (year='2024', month='01')
SELECT
    emp_id, emp_no, emp_name, department, year, month,
    CONCAT(year,'-',month) AS year_month,
    COUNT(*) AS total_days,
    SUM(attendance_type=0) AS normal_days, SUM(attendance_type=1) AS late_days,
    SUM(work_duration) AS total_work_duration,
    ROUND(AVG(work_duration)/60,2) AS avg_work_duration,
    CURRENT_TIMESTAMP AS dw_update_time
FROM fact_attendance WHERE year='2024' AND month='01'
GROUP BY emp_id, emp_no, emp_name, department, year, month;

-- 部门绩效汇总（修复：去掉month分组，绩效为季度数据）
INSERT OVERWRITE TABLE agg_department_monthly_performance PARTITION (year='2024', month='01')
SELECT
    department, year, '01' AS month, CONCAT(year,'-01') AS year_month,
    COUNT(DISTINCT emp_id) AS total_employees,
    ROUND(AVG(final_score),2) AS avg_final_score,
    SUM(performance_level='S') AS s_level_count,
    SUM(performance_level='A') AS a_level_count,
    CURRENT_TIMESTAMP AS dw_update_time
FROM fact_performance WHERE year='2024' AND quarter='01'
GROUP BY department, year;

-- 员工/部门薪资汇总（无错误）
INSERT OVERWRITE TABLE agg_employee_monthly_salary PARTITION (year='2024', month='01')
SELECT *, 0.0 AS salary_growth_rate, CURRENT_TIMESTAMP AS dw_update_time FROM fact_salary WHERE year='2024' AND month='01';

INSERT OVERWRITE TABLE agg_department_monthly_cost PARTITION (year='2024', month='01')
SELECT
    department, year, month, CONCAT(year,'-',month) AS year_month,
    COUNT(*) AS employee_count, SUM(total_gross_salary) AS total_cost,
    ROUND(AVG(total_gross_salary),2) AS cost_per_employee, 0.0 AS cost_growth_rate,
    CURRENT_TIMESTAMP AS dw_update_time
FROM fact_salary WHERE year='2024' AND month='01'
GROUP BY department, year, month;

-- 完成提示
SELECT '数据插入完成！' AS msg;