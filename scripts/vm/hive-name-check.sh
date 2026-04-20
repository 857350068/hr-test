#!/usr/bin/env bash
set -euo pipefail

export HADOOP_HOME=/data/hadoop
export HADOOP_PREFIX=/data/hadoop
export HIVE_HOME=/opt/hive
export JAVA_HOME=/opt/jdk1.8
export PATH=/opt/jdk1.8/bin:/data/hadoop/bin:/opt/hive/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin

/opt/hive/bin/hive -e "
USE hr_datacenter_dw;

SELECT
  COUNT(1) AS invalid_dim_name_cnt
FROM dim_employee
WHERE dt='20260420'
  AND (
    emp_name RLIKE '[0-9]'
    OR emp_name LIKE '员工%'
    OR emp_name LIKE '新增员工%'
    OR emp_name LIKE '测试员工%'
    OR emp_name LIKE 'Hive%'
  );

SELECT emp_no, emp_name
FROM dim_employee
WHERE dt='20260420'
LIMIT 12;
"
