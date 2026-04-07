package com.hr.datacenter.service.sync;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
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
            
            // 清空Hive维度表
            hiveJdbc.execute("TRUNCATE TABLE dim_employee");
            
            // 插入数据到Hive
            for (Map<String, Object> emp : employees) {
                String insertSql = buildEmployeeInsertSql(emp);
                hiveJdbc.execute(insertSql);
            }
            
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
            
            // 插入数据到Hive事实表
            for (Map<String, Object> att : attendances) {
                String insertSql = buildAttendanceInsertSql(att);
                hiveJdbc.execute(insertSql);
            }
            
            log.info("考勤事实数据同步完成，共同步{}条记录", attendances.size());
        } catch (Exception e) {
            log.error("考勤事实数据同步失败", e);
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
            
            // 执行聚合计算
            String aggSql = "INSERT OVERWRITE TABLE agg_employee_stats " +
                    "SELECT department, position, COUNT(*) as emp_count, " +
                    "AVG(salary) as avg_salary, SUM(salary) as total_salary, " +
                    "CURRENT_TIMESTAMP as update_time " +
                    "FROM dim_employee " +
                    "GROUP BY department, position";
            
            hiveJdbc.execute(aggSql);
            
            log.info("聚合数据同步完成");
        } catch (Exception e) {
            log.error("聚合数据同步失败", e);
        }
    }

    /**
     * 构建员工插入SQL
     */
    private String buildEmployeeInsertSql(Map<String, Object> emp) {
        return String.format(
                "INSERT INTO dim_employee VALUES (%s, '%s', '%s', '%s', '%s', '%s', " +
                "'%s', '%s', '%s', '%s', %s, '%s', '%s', %s, '%s', CURRENT_TIMESTAMP)",
                emp.get("emp_id"), emp.get("emp_no"), emp.get("emp_name"),
                emp.get("gender"), emp.get("birth_date"), emp.get("id_card"),
                emp.get("phone"), emp.get("email"), emp.get("department"),
                emp.get("position"), emp.get("salary"), emp.get("hire_date"),
                emp.get("resign_date") != null ? emp.get("resign_date") : "",
                emp.get("status"), emp.get("education")
        );
    }

    /**
     * 构建考勤插入SQL
     */
    private String buildAttendanceInsertSql(Map<String, Object> att) {
        return String.format(
                "INSERT INTO fact_attendance VALUES (%s, %s, '%s', '%s', '%s', '%s', " +
                "'%s', '%s', %s, '%s', %s, %s, YEAR('%s'), MONTH('%s'), CURRENT_TIMESTAMP)",
                att.get("attendance_id"), att.get("emp_id"), att.get("emp_no"),
                att.get("emp_name"), att.get("department"), att.get("position"),
                att.get("attendance_date"), att.get("clock_in_time"),
                att.get("clock_out_time"), att.get("attendance_type"),
                getAttendanceTypeDesc((Integer) att.get("attendance_type")),
                att.get("attendance_status"), att.get("work_duration"),
                att.get("attendance_date"), att.get("attendance_date")
        );
    }

    /**
     * 获取考勤类型描述
     */
    private String getAttendanceTypeDesc(Integer type) {
        if (type == null) return "未知";
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
}
