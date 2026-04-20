package com.hr.datacenter.service.sync;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 数据同步服务
 * 负责将MySQL数据同步到Hive数据仓库
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class DataSyncService {
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Autowired
    @Qualifier("mysqlDataSource")
    private DataSource mysqlDataSource;

    @Autowired
    @Qualifier("hiveDataSource")
    private DataSource hiveDataSource;

    @Value("${data-sync.enabled:true}")
    private boolean syncEnabled;

    /**
     * 同步员工维度数据
     * 每日凌晨2点执行
     */
    @Scheduled(cron = "${data-sync.dimension-sync-cron:0 0 2 * * ?}")
    public void syncEmployeeDimension() {
        if (!syncEnabled) {
            log.info("数据同步已禁用，跳过员工维度同步");
            return;
        }
        
        log.info("开始同步员工维度数据...");
        try {
            JdbcTemplate mysqlJdbc = new JdbcTemplate(mysqlDataSource);
            JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
            
            // 从MySQL查询员工数据
            String mysqlSql = "SELECT emp_id, emp_no, emp_name, gender, birth_date, id_card, " +
                    "phone, email, department, position, salary, hire_date, resign_date, " +
                    "status, education FROM employee WHERE deleted = 0";
            List<Map<String, Object>> employees = mysqlJdbc.queryForList(mysqlSql);
            
            log.info("从MySQL查询到{}条员工数据", employees.size());
            
            String dt = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
            hiveJdbc.execute(String.format("ALTER TABLE dim_employee DROP IF EXISTS PARTITION (dt='%s')", dt));
            executeBatchValues(hiveJdbc, "dim_employee", "dt='" + dt + "'", employees, this::buildEmployeeValues);
            
            log.info("员工维度数据同步完成，共同步{}条记录", employees.size());
        } catch (Exception e) {
            log.error("员工维度数据同步失败", e);
        }
    }

    /**
     * 同步考勤事实数据
     * 每小时执行
     */
    @Scheduled(cron = "${data-sync.fact-sync-cron:0 0 * * * ?}")
    public void syncAttendanceFact() {
        if (!syncEnabled) {
            return;
        }
        
        log.info("开始同步考勤事实数据...");
        try {
            JdbcTemplate mysqlJdbc = new JdbcTemplate(mysqlDataSource);
            JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
            
            // 从MySQL查询考勤数据
            String mysqlSql = "SELECT a.attendance_id, a.emp_id, e.emp_no, e.emp_name, " +
                    "e.department, e.position, a.attendance_date, a.clock_in_time, " +
                    "a.clock_out_time, a.attendance_type, a.attendance_status, " +
                    "a.work_duration FROM attendance a " +
                    "LEFT JOIN employee e ON a.emp_id = e.emp_id " +
                    "WHERE a.deleted = 0";
            List<Map<String, Object>> attendances = mysqlJdbc.queryForList(mysqlSql);
            
            log.info("从MySQL查询到{}条考勤数据", attendances.size());
            
            executePartitionedFactSync(hiveJdbc, attendances, "fact_attendance", this::buildAttendanceValues, this::attendancePartitionSpec);
            
            log.info("考勤事实数据同步完成，共同步{}条记录", attendances.size());
        } catch (Exception e) {
            log.error("考勤事实数据同步失败", e);
        }
    }

    @Scheduled(cron = "${data-sync.performance-sync-cron:0 30 2 * * ?}")
    public void syncPerformanceFact() {
        if (!syncEnabled) {
            return;
        }
        log.info("开始同步绩效事实数据...");
        try {
            JdbcTemplate mysqlJdbc = new JdbcTemplate(mysqlDataSource);
            JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
            String mysqlSql = "SELECT pe.evaluation_id, pe.emp_id, e.emp_no, e.emp_name, e.department, e.position, " +
                    "pe.year, pe.period_type, pe.quarter, pe.month, pe.self_score, pe.self_comment, " +
                    "pe.supervisor_score, pe.supervisor_comment, pe.final_score, pe.performance_level, " +
                    "pe.improvement_plan, pe.interview_record, pe.interview_date, pe.evaluation_status, " +
                    "pe.create_time, pe.update_time " +
                    "FROM performance_evaluation pe LEFT JOIN employee e ON pe.emp_id = e.emp_id " +
                    "WHERE pe.deleted = 0 AND e.deleted = 0";
            executePartitionedFactSync(hiveJdbc, mysqlJdbc.queryForList(mysqlSql), "fact_performance",
                    this::buildPerformanceValues, this::performancePartitionSpec);
            log.info("绩效事实数据同步完成");
        } catch (Exception e) {
            log.error("绩效事实数据同步失败", e);
        }
    }

    @Scheduled(cron = "${data-sync.salary-sync-cron:0 0 4 * * ?}")
    public void syncSalaryFact() {
        if (!syncEnabled) {
            return;
        }
        log.info("开始同步薪资事实数据...");
        try {
            JdbcTemplate mysqlJdbc = new JdbcTemplate(mysqlDataSource);
            JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
            String mysqlSql = "SELECT sp.payment_id, sp.emp_id, e.emp_no, e.emp_name, e.department, e.position, " +
                    "sp.year, sp.month, sp.basic_salary, sp.performance_salary, sp.position_allowance, " +
                    "sp.transport_allowance, sp.communication_allowance, sp.meal_allowance, sp.other_allowance, " +
                    "sp.overtime_pay, sp.total_gross_salary, sp.social_insurance, sp.housing_fund, sp.income_tax, " +
                    "sp.other_deduction, sp.total_net_salary, sp.payment_status, sp.payment_date, sp.remark, " +
                    "sp.create_time, sp.update_time " +
                    "FROM salary_payment sp LEFT JOIN employee e ON sp.emp_id = e.emp_id " +
                    "WHERE sp.deleted = 0 AND e.deleted = 0";
            executePartitionedFactSync(hiveJdbc, mysqlJdbc.queryForList(mysqlSql), "fact_salary",
                    this::buildSalaryValues, this::salaryPartitionSpec);
            log.info("薪资事实数据同步完成");
        } catch (Exception e) {
            log.error("薪资事实数据同步失败", e);
        }
    }

    @Scheduled(cron = "${data-sync.training-sync-cron:0 30 4 * * ?}")
    public void syncTrainingFact() {
        if (!syncEnabled) {
            return;
        }
        log.info("开始同步培训事实数据...");
        try {
            JdbcTemplate mysqlJdbc = new JdbcTemplate(mysqlDataSource);
            JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
            String mysqlSql = "SELECT te.enrollment_id, te.course_id, te.emp_id, e.emp_no, e.emp_name, e.department, e.position, " +
                    "tc.course_name, tc.course_type, tc.course_description, tc.instructor, tc.duration, tc.location, tc.start_date, tc.end_date, " +
                    "te.enrollment_time, te.approval_status, te.approver_id, te.attendance_status, te.score, te.feedback, " +
                    "te.create_time, te.update_time " +
                    "FROM training_enrollment te " +
                    "LEFT JOIN employee e ON te.emp_id = e.emp_id " +
                    "LEFT JOIN training_course tc ON te.course_id = tc.course_id " +
                    "WHERE te.deleted = 0 AND e.deleted = 0 AND tc.deleted = 0";
            executePartitionedFactSync(hiveJdbc, mysqlJdbc.queryForList(mysqlSql), "fact_training",
                    this::buildTrainingValues, this::trainingPartitionSpec);
            log.info("培训事实数据同步完成");
        } catch (Exception e) {
            log.error("培训事实数据同步失败", e);
        }
    }

    /**
     * 同步聚合数据
     * 每日凌晨3点执行
     */
    @Scheduled(cron = "${data-sync.aggregation-sync-cron:0 0 3 * * ?}")
    public void syncAggregationData() {
        if (!syncEnabled) {
            return;
        }
        
        log.info("开始同步聚合数据...");
        try {
            JdbcTemplate hiveJdbc = new JdbcTemplate(hiveDataSource);
            
            String currentYear = String.valueOf(LocalDate.now().getYear());
            String currentMonth = String.format("%02d", LocalDate.now().getMonthValue());
            hiveJdbc.execute(
                    "INSERT OVERWRITE TABLE agg_employee_monthly_attendance PARTITION (year='" + currentYear + "', month='" + currentMonth + "') " +
                            "SELECT emp_id, emp_no, emp_name, department, CAST(year AS INT), CAST(month AS INT), " +
                            "concat(year, '-', lpad(month, 2, '0')) as year_month, COUNT(*) as total_days, " +
                            "SUM(CASE WHEN attendance_type = 0 THEN 1 ELSE 0 END) as normal_days, " +
                            "SUM(CASE WHEN attendance_type = 1 THEN 1 ELSE 0 END) as late_days, " +
                            "SUM(CASE WHEN attendance_type = 2 THEN 1 ELSE 0 END) as early_leave_days, " +
                            "SUM(CASE WHEN attendance_type = 3 THEN 1 ELSE 0 END) as absent_days, " +
                            "SUM(CASE WHEN attendance_type = 4 THEN 1 ELSE 0 END) as leave_days, " +
                            "SUM(CASE WHEN attendance_type = 5 THEN 1 ELSE 0 END) as overtime_days, " +
                            "SUM(work_duration) as total_work_duration, ROUND(AVG(work_hours), 2) as avg_work_duration, " +
                            "ROUND(SUM(CASE WHEN is_late THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as late_rate, " +
                            "ROUND(SUM(CASE WHEN is_absent THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as absent_rate, " +
                            "ROUND(SUM(CASE WHEN is_overtime THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as overtime_rate, " +
                            "CURRENT_TIMESTAMP as dw_update_time " +
                            "FROM fact_attendance WHERE year = '" + currentYear + "' AND month = '" + currentMonth + "' " +
                            "GROUP BY emp_id, emp_no, emp_name, department, year, month");

            hiveJdbc.execute(
                    "INSERT OVERWRITE TABLE agg_employee_monthly_salary PARTITION (year='" + currentYear + "', month='" + currentMonth + "') " +
                            "SELECT emp_id, emp_no, emp_name, department, position, CAST(year AS INT), CAST(month AS INT), year_month, " +
                            "basic_salary, performance_salary, " +
                            "(position_allowance + transport_allowance + communication_allowance + meal_allowance + other_allowance) as total_allowance, " +
                            "overtime_pay, total_gross_salary, " +
                            "(social_insurance + housing_fund + income_tax + other_deduction) as total_deduction, total_net_salary, " +
                            "payment_status, payment_status_name, 0.00 as salary_growth_rate, CURRENT_TIMESTAMP as dw_update_time " +
                            "FROM fact_salary WHERE year = '" + currentYear + "' AND month = '" + currentMonth + "'");

            hiveJdbc.execute(
                    "INSERT OVERWRITE TABLE agg_department_monthly_cost PARTITION (year='" + currentYear + "', month='" + currentMonth + "') " +
                            "SELECT department, CAST(year AS INT), CAST(month AS INT), year_month, COUNT(*) as employee_count, " +
                            "SUM(total_gross_salary) as total_gross_salary, SUM(total_net_salary) as total_net_salary, ROUND(AVG(total_net_salary), 2) as avg_salary, " +
                            "SUM(position_allowance + transport_allowance + communication_allowance + meal_allowance + other_allowance) as total_allowance, " +
                            "SUM(overtime_pay) as total_overtime_pay, SUM(social_insurance) as total_social_insurance, SUM(housing_fund) as total_housing_fund, " +
                            "SUM(income_tax) as total_income_tax, " +
                            "SUM(total_net_salary + social_insurance + housing_fund + overtime_pay) as total_cost, " +
                            "ROUND(AVG(total_net_salary + social_insurance + housing_fund + overtime_pay), 2) as cost_per_employee, " +
                            "0.00 as cost_growth_rate, CURRENT_TIMESTAMP as dw_update_time " +
                            "FROM fact_salary WHERE year = '" + currentYear + "' AND month = '" + currentMonth + "' GROUP BY department, year, month, year_month");
            
            log.info("聚合数据同步完成");
        } catch (Exception e) {
            log.error("聚合数据同步失败", e);
        }
    }

    private void executePartitionedFactSync(JdbcTemplate hiveJdbc,
                                            List<Map<String, Object>> rows,
                                            String tableName,
                                            ValueBuilder valueBuilder,
                                            PartitionBuilder partitionBuilder) {
        Map<String, List<String>> partitionValues = new LinkedHashMap<>();
        for (Map<String, Object> row : rows) {
            String partition = partitionBuilder.build(row);
            partitionValues.computeIfAbsent(partition, key -> new ArrayList<>())
                    .add("(" + valueBuilder.build(row) + ")");
        }
        for (Map.Entry<String, List<String>> entry : partitionValues.entrySet()) {
            hiveJdbc.execute(String.format("ALTER TABLE %s DROP IF EXISTS PARTITION (%s)", tableName, entry.getKey()));
            hiveJdbc.execute(String.format("INSERT INTO TABLE %s PARTITION (%s) VALUES %s",
                    tableName, entry.getKey(), String.join(",", entry.getValue())));
        }
    }

    private void executeBatchValues(JdbcTemplate hiveJdbc,
                                    String tableName,
                                    String partitionSpec,
                                    List<Map<String, Object>> rows,
                                    ValueBuilder valueBuilder) {
        if (rows.isEmpty()) {
            return;
        }
        List<String> values = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            values.add("(" + valueBuilder.build(row) + ")");
        }
        hiveJdbc.execute(String.format("INSERT INTO TABLE %s PARTITION (%s) VALUES %s",
                tableName, partitionSpec, String.join(",", values)));
    }

    private String buildEmployeeValues(Map<String, Object> emp) {
        int gender = asInt(emp.get("gender"));
        String birthDate = date(emp.get("birth_date"));
        String hireDate = date(emp.get("hire_date"));
        String resignDate = date(emp.get("resign_date"));
        int age = birthDate == null ? 0 : Math.max(0, LocalDate.now().getYear() - LocalDate.parse(birthDate).getYear());
        int workYears = hireDate == null ? 0 : Math.max(0, LocalDate.now().getYear() - LocalDate.parse(hireDate).getYear());
        String education = str(emp.get("education"));
        return join(
                num(emp.get("emp_id")),
                quoted(emp.get("emp_no")),
                quoted(emp.get("emp_name")),
                String.valueOf(gender),
                quoted(gender == 1 ? "男" : "女"),
                dateLiteral(birthDate),
                String.valueOf(age),
                quoted(emp.get("id_card")),
                quoted(emp.get("phone")),
                quoted(emp.get("email")),
                quoted(emp.get("department")),
                quoted(emp.get("position")),
                decimal(emp.get("salary")),
                dateLiteral(hireDate),
                dateLiteral(resignDate),
                String.valueOf(workYears),
                String.valueOf(asInt(emp.get("status"))),
                quoted(statusName(asInt(emp.get("status")))),
                quoted(education),
                String.valueOf(educationLevel(education)),
                timestampLiteral(emp.get("create_time")),
                timestampLiteral(emp.get("update_time")),
                "CURRENT_TIMESTAMP",
                "CURRENT_TIMESTAMP"
        );
    }

    private String buildAttendanceValues(Map<String, Object> att) {
        int type = asInt(att.get("attendance_type"));
        int status = asInt(att.get("attendance_status"));
        int duration = asInt(att.get("work_duration"));
        String attDate = date(att.get("attendance_date"));
        return join(
                num(att.get("attendance_id")),
                num(att.get("emp_id")),
                quoted(att.get("emp_no")),
                quoted(att.get("emp_name")),
                quoted(att.get("department")),
                dateLiteral(attDate),
                attDate == null ? "NULL" : String.valueOf(Integer.parseInt(attDate.replace("-", ""))),
                quoted(att.get("clock_in_time")),
                quoted(att.get("clock_out_time")),
                String.valueOf(type),
                quoted(getAttendanceTypeDesc(type)),
                String.valueOf(status),
                quoted(getAttendanceStatusDesc(status)),
                String.valueOf(duration),
                String.valueOf(Math.round((duration / 60.0) * 100.0) / 100.0),
                bool(type == 1),
                bool(type == 2),
                bool(type == 3),
                bool(type == 5),
                quoted(att.get("remark")),
                timestampLiteral(att.get("create_time")),
                timestampLiteral(att.get("update_time")),
                "CURRENT_TIMESTAMP",
                "CURRENT_TIMESTAMP"
        );
    }

    private String buildPerformanceValues(Map<String, Object> row) {
        int year = asInt(row.get("year"));
        int quarter = asInt(row.get("quarter"));
        int month = asInt(row.get("month"));
        String level = str(row.get("performance_level"));
        return join(
                num(row.get("evaluation_id")),
                num(row.get("emp_id")),
                quoted(row.get("emp_no")),
                quoted(row.get("emp_name")),
                quoted(row.get("department")),
                quoted(row.get("position")),
                String.valueOf(year),
                quoted(year + "-Q" + (quarter > 0 ? quarter : 1)),
                String.valueOf(asInt(row.get("period_type"))),
                quoted(periodTypeName(asInt(row.get("period_type")))),
                String.valueOf(quarter),
                String.valueOf(month),
                decimal(row.get("self_score")),
                quoted(row.get("self_comment")),
                decimal(row.get("supervisor_score")),
                quoted(row.get("supervisor_comment")),
                decimal(row.get("final_score")),
                quoted(level),
                String.valueOf(levelScore(level)),
                quoted(row.get("improvement_plan")),
                quoted(row.get("interview_record")),
                timestampLiteral(row.get("interview_date")),
                String.valueOf(asInt(row.get("evaluation_status"))),
                quoted(evaluationStatusName(asInt(row.get("evaluation_status")))),
                timestampLiteral(row.get("create_time")),
                timestampLiteral(row.get("update_time")),
                "CURRENT_TIMESTAMP",
                "CURRENT_TIMESTAMP"
        );
    }

    private String buildSalaryValues(Map<String, Object> row) {
        int year = asInt(row.get("year"));
        int month = asInt(row.get("month"));
        double social = asDouble(row.get("social_insurance"));
        double housing = asDouble(row.get("housing_fund"));
        double tax = asDouble(row.get("income_tax"));
        double other = asDouble(row.get("other_deduction"));
        return join(
                num(row.get("payment_id")),
                num(row.get("emp_id")),
                quoted(row.get("emp_no")),
                quoted(row.get("emp_name")),
                quoted(row.get("department")),
                quoted(row.get("position")),
                String.valueOf(year),
                quoted(String.format("%d-%02d", year, month)),
                String.valueOf(month),
                decimal(row.get("basic_salary")),
                decimal(row.get("performance_salary")),
                decimal(row.get("position_allowance")),
                decimal(row.get("transport_allowance")),
                decimal(row.get("communication_allowance")),
                decimal(row.get("meal_allowance")),
                decimal(row.get("other_allowance")),
                decimal(row.get("overtime_pay")),
                decimal(row.get("total_gross_salary")),
                decimal(row.get("social_insurance")),
                decimal(row.get("housing_fund")),
                decimal(row.get("income_tax")),
                decimal(row.get("other_deduction")),
                String.valueOf(Math.round((social + housing + tax + other) * 100.0) / 100.0),
                decimal(row.get("total_net_salary")),
                String.valueOf(asInt(row.get("payment_status"))),
                quoted(asInt(row.get("payment_status")) == 1 ? "已发放" : "未发放"),
                timestampLiteral(row.get("payment_date")),
                quoted(row.get("remark")),
                timestampLiteral(row.get("create_time")),
                timestampLiteral(row.get("update_time")),
                "CURRENT_TIMESTAMP",
                "CURRENT_TIMESTAMP"
        );
    }

    private String buildTrainingValues(Map<String, Object> row) {
        int score = asInt(row.get("score"));
        return join(
                num(row.get("enrollment_id")),
                num(row.get("course_id")),
                num(row.get("emp_id")),
                quoted(row.get("emp_no")),
                quoted(row.get("emp_name")),
                quoted(row.get("department")),
                quoted(row.get("position")),
                quoted(row.get("course_name")),
                String.valueOf(asInt(row.get("course_type"))),
                quoted(courseTypeName(asInt(row.get("course_type")))),
                quoted(row.get("course_description")),
                quoted(row.get("instructor")),
                String.valueOf(asInt(row.get("duration"))),
                quoted(row.get("location")),
                timestampLiteral(row.get("start_date")),
                timestampLiteral(row.get("end_date")),
                timestampLiteral(row.get("enrollment_time")),
                String.valueOf(asInt(row.get("approval_status"))),
                quoted(approvalStatusName(asInt(row.get("approval_status")))),
                num(row.get("approver_id")),
                String.valueOf(asInt(row.get("attendance_status"))),
                quoted(attendanceStatusName(asInt(row.get("attendance_status")))),
                score == 0 && row.get("score") == null ? "NULL" : String.valueOf(score),
                quoted(scoreLevel(score)),
                quoted(row.get("feedback")),
                timestampLiteral(row.get("create_time")),
                timestampLiteral(row.get("update_time")),
                "CURRENT_TIMESTAMP",
                "CURRENT_TIMESTAMP"
        );
    }

    private String attendancePartitionSpec(Map<String, Object> row) {
        String value = date(row.get("attendance_date"));
        LocalDate d = value == null ? LocalDate.now() : LocalDate.parse(value);
        return "year='" + d.getYear() + "', month='" + String.format("%02d", d.getMonthValue()) + "'";
    }

    private String performancePartitionSpec(Map<String, Object> row) {
        return "year='" + asInt(row.get("year")) + "', quarter='" + asInt(row.get("quarter")) + "'";
    }

    private String salaryPartitionSpec(Map<String, Object> row) {
        return "year='" + asInt(row.get("year")) + "', month='" + String.format("%02d", asInt(row.get("month"))) + "'";
    }

    private String trainingPartitionSpec(Map<String, Object> row) {
        Object startDate = row.get("start_date");
        LocalDateTime dt = startDate instanceof Timestamp ? ((Timestamp) startDate).toLocalDateTime() : LocalDateTime.now();
        return "year='" + dt.getYear() + "'";
    }

    private String join(String... values) {
        return String.join(",", values);
    }

    private String quoted(Object value) {
        if (value == null) {
            return "NULL";
        }
        String text = String.valueOf(value).replace("\\", "\\\\").replace("'", "\\'");
        return "'" + text + "'";
    }

    private String str(Object value) {
        return value == null ? "" : String.valueOf(value);
    }

    private String num(Object value) {
        return value == null ? "NULL" : String.valueOf(value);
    }

    private String decimal(Object value) {
        return value == null ? "NULL" : String.valueOf(Math.round(asDouble(value) * 100.0) / 100.0);
    }

    private String bool(boolean value) {
        return value ? "true" : "false";
    }

    private String dateLiteral(String date) {
        return date == null ? "NULL" : "'" + date + "'";
    }

    private String timestampLiteral(Object value) {
        if (value == null) {
            return "CURRENT_TIMESTAMP";
        }
        if (value instanceof Timestamp) {
            return "'" + ((Timestamp) value).toLocalDateTime().toString().replace('T', ' ') + "'";
        }
        return quoted(value);
    }

    private String date(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof java.sql.Date) {
            return ((java.sql.Date) value).toLocalDate().format(DATE_FMT);
        }
        if (value instanceof Timestamp) {
            return ((Timestamp) value).toLocalDateTime().toLocalDate().format(DATE_FMT);
        }
        return String.valueOf(value);
    }

    private int asInt(Object value) {
        return value instanceof Number ? ((Number) value).intValue() : 0;
    }

    private double asDouble(Object value) {
        return value instanceof Number ? ((Number) value).doubleValue() : 0D;
    }

    private String getAttendanceTypeDesc(Integer type) {
        switch (type) {
            case 0: return "正常";
            case 1: return "迟到";
            case 2: return "早退";
            case 3: return "旷工";
            case 4: return "请假";
            case 5: return "加班";
            default: return "未知";
        }
    }

    private String getAttendanceStatusDesc(Integer status) {
        switch (status) {
            case 0: return "未打卡";
            case 1: return "已打卡";
            case 2: return "请假";
            case 3: return "加班";
            default: return "未知";
        }
    }

    private String statusName(int status) {
        switch (status) {
            case 0: return "离职";
            case 1: return "在职";
            case 2: return "试用";
            default: return "未知";
        }
    }

    private int educationLevel(String education) {
        if ("高中".equals(education)) return 1;
        if ("大专".equals(education)) return 2;
        if ("本科".equals(education)) return 3;
        if ("硕士".equals(education)) return 4;
        if ("博士".equals(education)) return 5;
        return 0;
    }

    private String periodTypeName(int periodType) {
        switch (periodType) {
            case 1: return "年度";
            case 2: return "季度";
            case 3: return "月度";
            default: return "未知";
        }
    }

    private int levelScore(String level) {
        if ("S".equalsIgnoreCase(level)) return 5;
        if ("A".equalsIgnoreCase(level)) return 4;
        if ("B".equalsIgnoreCase(level)) return 3;
        if ("C".equalsIgnoreCase(level)) return 2;
        if ("D".equalsIgnoreCase(level)) return 1;
        return 0;
    }

    private String evaluationStatusName(int status) {
        switch (status) {
            case 0: return "未评估";
            case 1: return "已自评";
            case 2: return "已评价";
            case 3: return "已完成";
            default: return "未知";
        }
    }

    private String courseTypeName(int type) {
        switch (type) {
            case 1: return "新员工培训";
            case 2: return "技能培训";
            case 3: return "管理培训";
            case 4: return "安全培训";
            case 5: return "其他";
            default: return "未知";
        }
    }

    private String approvalStatusName(int status) {
        switch (status) {
            case 0: return "待审核";
            case 1: return "已通过";
            case 2: return "已拒绝";
            default: return "未知";
        }
    }

    private String attendanceStatusName(int status) {
        switch (status) {
            case 0: return "未出勤";
            case 1: return "已出勤";
            case 2: return "请假";
            default: return "未知";
        }
    }

    private String scoreLevel(int score) {
        if (score >= 90) return "A";
        if (score >= 80) return "B";
        if (score >= 60) return "C";
        if (score > 0) return "D";
        return "未评分";
    }

    @FunctionalInterface
    private interface ValueBuilder {
        String build(Map<String, Object> row);
    }

    @FunctionalInterface
    private interface PartitionBuilder {
        String build(Map<String, Object> row);
    }
}
