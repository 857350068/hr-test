package com.hr.backend.service.impl;

import com.hr.backend.service.DashboardService;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.*;

@Service
public class DashboardServiceImpl implements DashboardService {

    @Resource
    private JdbcTemplate jdbcTemplate;

    @Override
    public Map<String, Object> getStatistics() {
        Map<String, Object> stats = new HashMap<>();
        try {
            Long total = jdbcTemplate.queryForObject("SELECT COUNT(DISTINCT employee_no) FROM employee_profile WHERE is_deleted = 0", Long.class);
            stats.put("totalEmployees", total != null ? total : 0);
        } catch (Exception e) {
            stats.put("totalEmployees", 0);
        }
        stats.put("employeeGrowth", 2.5);
        try {
            Double avg = jdbcTemplate.queryForObject("SELECT AVG(value) FROM employee_profile WHERE category_id = 4 AND is_deleted = 0", Double.class);
            stats.put("avgPerformance", avg != null ? String.format("%.1f", avg) : "0");
        } catch (Exception e) {
            stats.put("avgPerformance", "0");
        }
        stats.put("performanceGrowth", 3.2);
        stats.put("totalCost", "¥1,258万");
        stats.put("costGrowth", 1.8);
        stats.put("turnoverRate", 5.2);
        stats.put("turnoverChange", -0.3);
        return stats;
    }

    @Override
    public Map<String, Object> getWarnings() {
        List<Map<String, Object>> list = new ArrayList<>();
        list.add(warningEntry(1, "high", "销售部流失率达到8.5%，超过预警阈值"));
        list.add(warningEntry(2, "medium", "研发部人力成本同比增长12%"));
        list.add(warningEntry(3, "medium", "技术岗位人才缺口15人"));
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        return result;
    }

    private static Map<String, Object> warningEntry(int id, String level, String message) {
        Map<String, Object> m = new HashMap<>();
        m.put("id", id);
        m.put("level", level);
        m.put("message", message);
        return m;
    }
}
