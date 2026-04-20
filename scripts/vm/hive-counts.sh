#!/usr/bin/env bash
set -euo pipefail

export HADOOP_HOME=/data/hadoop
export HADOOP_PREFIX=/data/hadoop
export HIVE_HOME=/opt/hive
export JAVA_HOME=/opt/jdk1.8
export PATH=/opt/jdk1.8/bin:/data/hadoop/bin:/opt/hive/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin

/opt/hive/bin/hive -e "
USE hr_datacenter_dw;
SELECT 'dim_employee_20260420' AS tbl, COUNT(*) AS cnt FROM dim_employee WHERE dt='20260420';
SELECT 'fact_salary_2026_03' AS tbl, COUNT(*) AS cnt FROM fact_salary WHERE year='2026' AND month='03';
SELECT 'fact_salary_2026_02' AS tbl, COUNT(*) AS cnt FROM fact_salary WHERE year='2026' AND month='02';
SELECT 'fact_performance_2026_Q1' AS tbl, COUNT(*) AS cnt FROM fact_performance WHERE year='2026' AND quarter='01';
SELECT 'fact_performance_2025_Q4' AS tbl, COUNT(*) AS cnt FROM fact_performance WHERE year='2025' AND quarter='04';
SELECT 'agg_employee_monthly_salary_2026_03' AS tbl, COUNT(*) AS cnt FROM agg_employee_monthly_salary WHERE year='2026' AND month='03';
SELECT 'agg_department_monthly_cost_2026_03' AS tbl, COUNT(*) AS cnt FROM agg_department_monthly_cost WHERE year='2026' AND month='03';
SHOW PARTITIONS dim_employee;
SHOW PARTITIONS fact_salary;
SHOW PARTITIONS fact_performance;
"
