package com.hr.backend.service.impl;

import com.hr.backend.service.DataQueryService;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.*;

/**
 * 数据查询服务实现类
 * <p>
 * 提供高级数据筛选和查询功能实现
 * 支持多条件组合查询、数据对比、趋势分析等
 */
@Service
public class DataQueryServiceImpl implements DataQueryService {

    @Resource
    private JdbcTemplate jdbcTemplate;

    /**
     * 高级查询员工档案数据
     */
    @Override
    public Map<String, Object> advancedQueryEmployeeProfile(Map<String, Object> filters) {
        Map<String, Object> result = new HashMap<>();

        try {
            // 构建SQL查询
            StringBuilder sql = new StringBuilder(
                    "SELECT ep.*, dc.name as category_name " +
                            "FROM employee_profile ep " +
                            "LEFT JOIN hr_data_category dc ON ep.category_id = dc.id " +
                            "WHERE ep.is_deleted = 0");

            List<Object> params = new ArrayList<>();

            // 应用筛选条件
            if (filters != null && !filters.isEmpty()) {
                // 部门筛选
                if (filters.containsKey("deptId")) {
                    sql.append(" AND ep.dept_id = ?");
                    params.add(filters.get("deptId"));
                }

                // 部门名称筛选
                if (filters.containsKey("deptName")) {
                    sql.append(" AND ep.dept_name LIKE ?");
                    params.add("%" + filters.get("deptName") + "%");
                }

                // 岗位筛选
                if (filters.containsKey("job")) {
                    sql.append(" AND ep.job LIKE ?");
                    params.add("%" + filters.get("job") + "%");
                }

                // 时间周期筛选
                if (filters.containsKey("period")) {
                    sql.append(" AND ep.period = ?");
                    params.add(filters.get("period"));
                }

                // 时间周期范围筛选
                if (filters.containsKey("periodStart") && filters.containsKey("periodEnd")) {
                    sql.append(" AND ep.period BETWEEN ? AND ?");
                    params.add(filters.get("periodStart"));
                    params.add(filters.get("periodEnd"));
                }

                // 数据分类筛选
                if (filters.containsKey("categoryId")) {
                    sql.append(" AND ep.category_id = ?");
                    params.add(filters.get("categoryId"));
                }

                // 员工编号筛选
                if (filters.containsKey("employeeNo")) {
                    sql.append(" AND ep.employee_no LIKE ?");
                    params.add("%" + filters.get("employeeNo") + "%");
                }

                // 姓名筛选
                if (filters.containsKey("name")) {
                    sql.append(" AND ep.name LIKE ?");
                    params.add("%" + filters.get("name") + "%");
                }

                // 指标值范围筛选
                if (filters.containsKey("valueMin") && filters.containsKey("valueMax")) {
                    sql.append(" AND ep.value BETWEEN ? AND ?");
                    params.add(filters.get("valueMin"));
                    params.add(filters.get("valueMax"));
                }

                // 指标值大于等于
                if (filters.containsKey("valueMin")) {
                    sql.append(" AND ep.value >= ?");
                    params.add(filters.get("valueMin"));
                }

                // 指标值小于等于
                if (filters.containsKey("valueMax")) {
                    sql.append(" AND ep.value <= ?");
                    params.add(filters.get("valueMax"));
                }
            }

            // 排序
            String sortBy = (String) filters.getOrDefault("sortBy", "create_time");
            String sortOrder = (String) filters.getOrDefault("sortOrder", "DESC");
            sql.append(" ORDER BY ").append(sortBy).append(" ").append(sortOrder);

            // 分页
            Integer page = (Integer) filters.getOrDefault("page", 1);
            Integer pageSize = (Integer) filters.getOrDefault("pageSize", 20);
            int offset = (page - 1) * pageSize;
            sql.append(" LIMIT ? OFFSET ?");
            params.add(pageSize);
            params.add(offset);

            // 执行查询
            List<Map<String, Object>> data = jdbcTemplate.queryForList(sql.toString(), params.toArray());

            // 查询总数
            String countSql = sql.toString().replaceAll("SELECT.*?FROM", "SELECT COUNT(*) FROM")
                    .replaceAll("ORDER BY.*LIMIT.*", "");
            Long total = jdbcTemplate.queryForObject(countSql, Long.class, params.subList(0, params.size() - 2).toArray());

            // 构建结果
            result.put("success", true);
            result.put("data", data);
            result.put("total", total);
            result.put("page", page);
            result.put("pageSize", pageSize);
            result.put("totalPages", (total + pageSize - 1) / pageSize);

        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "查询失败：" + e.getMessage());
        }

        return result;
    }

    /**
     * 查询分析数据对比
     */
    @Override
    public Map<String, Object> compareAnalysisData(Long categoryId, String period1, String period2) {
        Map<String, Object> result = new HashMap<>();

        try {
            // 查询第一个时间周期的数据
            String sql1 = "SELECT dept_id, dept_name, AVG(value) as avg_value, COUNT(*) as count " +
                    "FROM employee_profile WHERE category_id = ? AND period = ? AND is_deleted = 0 " +
                    "GROUP BY dept_id, dept_name ORDER BY avg_value DESC";
            List<Map<String, Object>> data1 = jdbcTemplate.queryForList(sql1, categoryId, period1);

            // 查询第二个时间周期的数据
            String sql2 = "SELECT dept_id, dept_name, AVG(value) as avg_value, COUNT(*) as count " +
                    "FROM employee_profile WHERE category_id = ? AND period = ? AND is_deleted = 0 " +
                    "GROUP BY dept_id, dept_name ORDER BY avg_value DESC";
            List<Map<String, Object>> data2 = jdbcTemplate.queryForList(sql2, categoryId, period2);

            // 构建对比数据
            List<Map<String, Object>> comparison = new ArrayList<>();
            Map<String, Map<String, Object>> data2Map = new HashMap<>();
            for (Map<String, Object> row : data2) {
                data2Map.put(row.get("dept_id").toString(), row);
            }

            for (Map<String, Object> row1 : data1) {
                Map<String, Object> comparisonRow = new HashMap<>();
                String deptId = row1.get("dept_id").toString();

                comparisonRow.put("deptId", deptId);
                comparisonRow.put("deptName", row1.get("dept_name"));
                comparisonRow.put("period1Value", row1.get("avg_value"));
                comparisonRow.put("period1Count", row1.get("count"));

                if (data2Map.containsKey(deptId)) {
                    Map<String, Object> row2 = data2Map.get(deptId);
                    comparisonRow.put("period2Value", row2.get("avg_value"));
                    comparisonRow.put("period2Count", row2.get("count"));

                    // 计算变化率
                    Double value1 = ((Number) row1.get("avg_value")).doubleValue();
                    Double value2 = ((Number) row2.get("avg_value")).doubleValue();
                    Double changeRate = value1 != 0 ? ((value2 - value1) / value1) * 100 : 0;
                    comparisonRow.put("changeRate", changeRate);
                    comparisonRow.put("changeDirection", changeRate > 0 ? "上升" : (changeRate < 0 ? "下降" : "不变"));
                } else {
                    comparisonRow.put("period2Value", null);
                    comparisonRow.put("period2Count", 0);
                    comparisonRow.put("changeRate", null);
                    comparisonRow.put("changeDirection", "无数据");
                }

                comparison.add(comparisonRow);
            }

            result.put("success", true);
            result.put("data", comparison);
            result.put("period1", period1);
            result.put("period2", period2);

        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "对比查询失败：" + e.getMessage());
        }

        return result;
    }

    /**
     * 查询数据趋势分析
     */
    @Override
    public Map<String, Object> queryTrendData(Long categoryId, String startDate, String endDate) {
        Map<String, Object> result = new HashMap<>();

        try {
            // 查询趋势数据
            String sql = "SELECT period, AVG(value) as avg_value, COUNT(*) as count, " +
                    "MIN(value) as min_value, MAX(value) as max_value, " +
                    "STDDEV(value) as std_value " +
                    "FROM employee_profile WHERE category_id = ? AND is_deleted = 0 ";

            List<Object> params = new ArrayList<>();
            params.add(categoryId);

            if (startDate != null && !startDate.isEmpty()) {
                sql += "AND period >= ? ";
                params.add(startDate);
            }

            if (endDate != null && !endDate.isEmpty()) {
                sql += "AND period <= ? ";
                params.add(endDate);
            }

            sql += "GROUP BY period ORDER BY period";

            List<Map<String, Object>> data = jdbcTemplate.queryForList(sql, params.toArray());

            // 计算趋势分析
            if (data.size() > 1) {
                Double firstValue = ((Number) data.get(0).get("avg_value")).doubleValue();
                Double lastValue = ((Number) data.get(data.size() - 1).get("avg_value")).doubleValue();
                Double totalChange = lastValue - firstValue;
                Double averageChange = totalChange / (data.size() - 1);

                result.put("firstValue", firstValue);
                result.put("lastValue", lastValue);
                result.put("totalChange", totalChange);
                result.put("averageChange", averageChange);
                result.put("trendDirection", averageChange > 0 ? "上升" : (averageChange < 0 ? "下降" : "稳定"));
            }

            result.put("success", true);
            result.put("data", data);

        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "趋势查询失败：" + e.getMessage());
        }

        return result;
    }

    /**
     * 查询部门排名数据
     */
    @Override
    public Map<String, Object> queryDepartmentRanking(Long categoryId, String period, Integer limit) {
        Map<String, Object> result = new HashMap<>();

        try {
            if (limit == null || limit <= 0) {
                limit = 10;
            }

            String sql = "SELECT d.name as dept_name, AVG(ep.value) as avg_value, " +
                    "COUNT(ep.id) as employee_count, " +
                    "SUM(CASE WHEN ep.value >= 90 THEN 1 ELSE 0 END) as excellent_count " +
                    "FROM employee_profile ep " +
                    "JOIN hr_department d ON ep.dept_id = d.id " +
                    "WHERE ep.category_id = ? AND ep.is_deleted = 0 ";

            List<Object> params = new ArrayList<>();
            params.add(categoryId);

            if (period != null && !period.isEmpty()) {
                sql += "AND ep.period = ? ";
                params.add(period);
            }

            sql += "GROUP BY d.id, d.name ORDER BY avg_value DESC LIMIT ?";

            params.add(limit);

            List<Map<String, Object>> data = jdbcTemplate.queryForList(sql, params.toArray());

            // 添加排名
            for (int i = 0; i < data.size(); i++) {
                data.get(i).put("rank", i + 1);
            }

            result.put("success", true);
            result.put("data", data);
            result.put("limit", limit);

        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "排名查询失败：" + e.getMessage());
        }

        return result;
    }

    /**
     * 查询员工个人详细数据
     */
    @Override
    public Map<String, Object> queryEmployeeDetail(String employeeNo) {
        Map<String, Object> result = new HashMap<>();

        try {
            // 查询员工基本信息
            String userSql = "SELECT username, name, role, dept_name, phone, email, create_time " +
                    "FROM sys_user WHERE username = ? AND is_deleted = 0";
            Map<String, Object> userInfo = jdbcTemplate.queryForMap(userSql, employeeNo);

            // 查询员工所有分析数据
            String profileSql = "SELECT ep.*, dc.name as category_name " +
                    "FROM employee_profile ep " +
                    "LEFT JOIN hr_data_category dc ON ep.category_id = dc.id " +
                    "WHERE ep.employee_no = ? AND ep.is_deleted = 0 " +
                    "ORDER BY ep.period DESC, ep.category_id";
            List<Map<String, Object>> profileData = jdbcTemplate.queryForList(profileSql, employeeNo);

            // 按分类分组数据
            Map<String, List<Map<String, Object>>> groupedData = new HashMap<>();
            for (Map<String, Object> profile : profileData) {
                String categoryName = (String) profile.get("category_name");
                if (!groupedData.containsKey(categoryName)) {
                    groupedData.put(categoryName, new ArrayList<>());
                }
                groupedData.get(categoryName).add(profile);
            }

            result.put("success", true);
            result.put("userInfo", userInfo);
            result.put("profileData", groupedData);
            result.put("totalRecords", profileData.size());

        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "员工详情查询失败：" + e.getMessage());
        }

        return result;
    }

    /**
     * 查询多维度数据汇总
     */
    @Override
    public Map<String, Object> queryMultiDimensionSummary(List<Long> categoryIds, String period) {
        Map<String, Object> result = new HashMap<>();

        try {
            List<Map<String, Object>> summaryData = new ArrayList<>();

            for (Long categoryId : categoryIds) {
                String sql = "SELECT dc.name as category_name, AVG(ep.value) as avg_value, " +
                        "COUNT(ep.id) as count, " +
                        "MIN(ep.value) as min_value, MAX(ep.value) as max_value " +
                        "FROM employee_profile ep " +
                        "JOIN hr_data_category dc ON ep.category_id = dc.id " +
                        "WHERE ep.category_id = ? AND ep.is_deleted = 0 ";

                List<Object> params = new ArrayList<>();
                params.add(categoryId);

                if (period != null && !period.isEmpty()) {
                    sql += "AND ep.period = ? ";
                    params.add(period);
                }

                sql += "GROUP BY dc.id, dc.name";

                List<Map<String, Object>> categoryData = jdbcTemplate.queryForList(sql, params.toArray());
                summaryData.addAll(categoryData);
            }

            result.put("success", true);
            result.put("data", summaryData);

        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "汇总查询失败：" + e.getMessage());
        }

        return result;
    }

    /**
     * 查询数据统计摘要
     */
    @Override
    public Map<String, Object> queryDataSummary(Long categoryId, String period) {
        Map<String, Object> result = new HashMap<>();

        try {
            String sql = "SELECT " +
                    "COUNT(*) as total_count, " +
                    "AVG(value) as avg_value, " +
                    "MIN(value) as min_value, " +
                    "MAX(value) as max_value, " +
                    "STDDEV(value) as std_value, " +
                    "SUM(CASE WHEN value >= 90 THEN 1 ELSE 0 END) as excellent_count, " +
                    "SUM(CASE WHEN value >= 80 AND value < 90 THEN 1 ELSE 0 END) as good_count, " +
                    "SUM(CASE WHEN value >= 70 AND value < 80 THEN 1 ELSE 0 END) as fair_count, " +
                    "SUM(CASE WHEN value < 70 THEN 1 ELSE 0 END) as poor_count " +
                    "FROM employee_profile WHERE category_id = ? AND is_deleted = 0 ";

            List<Object> params = new ArrayList<>();
            params.add(categoryId);

            if (period != null && !period.isEmpty()) {
                sql += "AND period = ? ";
                params.add(period);
            }

            Map<String, Object> summary = jdbcTemplate.queryForMap(sql, params.toArray());

            // 添加百分比统计
            Long totalCount = ((Number) summary.get("total_count")).longValue();
            if (totalCount > 0) {
                summary.put("excellent_rate", ((Number) summary.get("excellent_count")).doubleValue() / totalCount * 100);
                summary.put("good_rate", ((Number) summary.get("good_count")).doubleValue() / totalCount * 100);
                summary.put("fair_rate", ((Number) summary.get("fair_count")).doubleValue() / totalCount * 100);
                summary.put("poor_rate", ((Number) summary.get("poor_count")).doubleValue() / totalCount * 100);
            }

            result.put("success", true);
            result.put("summary", summary);

        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "统计摘要查询失败：" + e.getMessage());
        }

        return result;
    }

    /**
     * 搜索数据（全文搜索）
     */
    @Override
    public Map<String, Object> searchData(String keyword, Long categoryId, String period) {
        Map<String, Object> result = new HashMap<>();

        try {
            StringBuilder sql = new StringBuilder(
                    "SELECT ep.*, dc.name as category_name " +
                            "FROM employee_profile ep " +
                            "LEFT JOIN hr_data_category dc ON ep.category_id = dc.id " +
                            "WHERE ep.is_deleted = 0 AND (" +
                            "ep.employee_no LIKE ? OR " +
                            "ep.name LIKE ? OR " +
                            "ep.dept_name LIKE ? OR " +
                            "ep.job LIKE ?)");

            List<Object> params = new ArrayList<>();
            String searchPattern = "%" + keyword + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);

            if (categoryId != null) {
                sql.append(" AND ep.category_id = ?");
                params.add(categoryId);
            }

            if (period != null && !period.isEmpty()) {
                sql.append(" AND ep.period = ?");
                params.add(period);
            }

            sql.append(" ORDER BY ep.create_time DESC LIMIT 100");

            List<Map<String, Object>> data = jdbcTemplate.queryForList(sql.toString(), params.toArray());

            result.put("success", true);
            result.put("data", data);
            result.put("total", data.size());
            result.put("keyword", keyword);

        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "搜索失败：" + e.getMessage());
        }

        return result;
    }

    /**
     * 获取数据筛选条件选项
     */
    @Override
    public Map<String, Object> getFilterOptions(String filterType) {
        Map<String, Object> result = new HashMap<>();

        try {
            List<Map<String, Object>> options = new ArrayList<>();

            switch (filterType) {
                case "dept":
                    String deptSql = "SELECT id, name FROM hr_department ORDER BY parent_id, sort_order";
                    options = jdbcTemplate.queryForList(deptSql);
                    break;

                case "job":
                    String jobSql = "SELECT DISTINCT job FROM employee_profile WHERE job IS NOT NULL ORDER BY job";
                    List<String> jobs = jdbcTemplate.queryForList(jobSql, String.class);
                    for (String job : jobs) {
                        Map<String, Object> jobOption = new HashMap<>();
                        jobOption.put("value", job);
                        jobOption.put("label", job);
                        options.add(jobOption);
                    }
                    break;

                case "period":
                    String periodSql = "SELECT DISTINCT period FROM employee_profile ORDER BY period DESC";
                    List<String> periods = jdbcTemplate.queryForList(periodSql, String.class);
                    for (String period : periods) {
                        Map<String, Object> periodOption = new HashMap<>();
                        periodOption.put("value", period);
                        periodOption.put("label", period);
                        options.add(periodOption);
                    }
                    break;

                case "category":
                    String categorySql = "SELECT id, name FROM hr_data_category ORDER BY sort_order";
                    options = jdbcTemplate.queryForList(categorySql);
                    break;

                default:
                    throw new RuntimeException("不支持的筛选类型");
            }

            result.put("success", true);
            result.put("options", options);

        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "获取筛选选项失败：" + e.getMessage());
        }

        return result;
    }
}
