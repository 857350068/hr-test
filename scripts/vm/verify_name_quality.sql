SELECT
    COUNT(1) AS invalid_name_count
FROM hr_datacenter.employee
WHERE deleted = 0
  AND (
    emp_name REGEXP '[0-9]'
    OR emp_name LIKE '员工%'
    OR emp_name LIKE '新增员工%'
    OR emp_name LIKE '测试员工%'
    OR emp_name LIKE 'Hive%'
  );

SELECT emp_no, emp_name
FROM hr_datacenter.employee
WHERE deleted = 0
ORDER BY emp_id DESC
LIMIT 20;
