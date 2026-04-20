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
