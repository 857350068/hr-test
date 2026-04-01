package com.hr.backend.controller;

import com.hr.backend.common.Response;
import com.hr.backend.service.DataQueryService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;

/**
 * 数据查询控制器
 * <p>
 * 提供高级数据筛选和查询功能的API接口
 * 支持多条件组合查询、数据对比、趋势分析等
 */
@RestController
@RequestMapping("/api/query")
public class DataQueryController {

    @Resource
    private DataQueryService dataQueryService;

    /**
     * 高级查询员工档案数据
     *
     * @param filters 筛选条件（JSON格式）
     * @return 查询结果
     */
    @PostMapping("/employee-profile/advanced")
    public Response<Map<String, Object>> advancedQueryEmployeeProfile(@RequestBody Map<String, Object> filters) {
        try {
            Map<String, Object> result = dataQueryService.advancedQueryEmployeeProfile(filters);
            return Response.success(result);
        } catch (Exception e) {
            return Response.error(500, "查询失败：" + e.getMessage());
        }
    }

    /**
     * 查询分析数据对比
     *
     * @param categoryId 数据分类ID
     * @param period1    时间周期1
     * @param period2    时间周期2
     * @return 对比结果
     */
    @GetMapping("/analysis-data/compare")
    public Response<Map<String, Object>> compareAnalysisData(
            @RequestParam Long categoryId,
            @RequestParam String period1,
            @RequestParam String period2) {
        try {
            Map<String, Object> result = dataQueryService.compareAnalysisData(categoryId, period1, period2);
            return Response.success(result);
        } catch (Exception e) {
            return Response.error(500, "对比查询失败：" + e.getMessage());
        }
    }

    /**
     * 查询数据趋势分析
     *
     * @param categoryId 数据分类ID
     * @param startDate  开始日期
     * @param endDate    结束日期
     * @return 趋势数据
     */
    @GetMapping("/analysis-data/trend")
    public Response<Map<String, Object>> queryTrendData(
            @RequestParam Long categoryId,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        try {
            Map<String, Object> result = dataQueryService.queryTrendData(categoryId, startDate, endDate);
            return Response.success(result);
        } catch (Exception e) {
            return Response.error(500, "趋势查询失败：" + e.getMessage());
        }
    }

    /**
     * 查询部门排名数据
     *
     * @param categoryId 数据分类ID
     * @param period     时间周期（可选）
     * @param limit      返回数量限制（可选，默认10）
     * @return 排名数据
     */
    @GetMapping("/analysis-data/ranking")
    public Response<Map<String, Object>> queryDepartmentRanking(
            @RequestParam Long categoryId,
            @RequestParam(required = false) String period,
            @RequestParam(required = false, defaultValue = "10") Integer limit) {
        try {
            Map<String, Object> result = dataQueryService.queryDepartmentRanking(categoryId, period, limit);
            return Response.success(result);
        } catch (Exception e) {
            return Response.error(500, "排名查询失败：" + e.getMessage());
        }
    }

    /**
     * 查询员工个人详细数据
     *
     * @param employeeNo 员工编号
     * @return 员工详细数据
     */
    @GetMapping("/employee/{employeeNo}")
    public Response<Map<String, Object>> queryEmployeeDetail(@PathVariable String employeeNo) {
        try {
            Map<String, Object> result = dataQueryService.queryEmployeeDetail(employeeNo);
            return Response.success(result);
        } catch (Exception e) {
            return Response.error(500, "员工详情查询失败：" + e.getMessage());
        }
    }

    /**
     * 查询多维度数据汇总
     *
     * @param categoryIds 数据分类ID列表（逗号分隔）
     * @param period      时间周期（可选）
     * @return 汇总数据
     */
    @GetMapping("/analysis-data/summary")
    public Response<Map<String, Object>> queryMultiDimensionSummary(
            @RequestParam String categoryIds,
            @RequestParam(required = false) String period) {
        try {
            List<Long> categoryIdList = new java.util.ArrayList<>();
            String[] ids = categoryIds.split(",");
            for (String id : ids) {
                categoryIdList.add(Long.parseLong(id.trim()));
            }

            Map<String, Object> result = dataQueryService.queryMultiDimensionSummary(categoryIdList, period);
            return Response.success(result);
        } catch (Exception e) {
            return Response.error(500, "汇总查询失败：" + e.getMessage());
        }
    }

    /**
     * 查询数据统计摘要
     *
     * @param categoryId 数据分类ID
     * @param period     时间周期（可选）
     * @return 统计摘要
     */
    @GetMapping("/analysis-data/summary-stats")
    public Response<Map<String, Object>> queryDataSummary(
            @RequestParam Long categoryId,
            @RequestParam(required = false) String period) {
        try {
            Map<String, Object> result = dataQueryService.queryDataSummary(categoryId, period);
            return Response.success(result);
        } catch (Exception e) {
            return Response.error(500, "统计摘要查询失败：" + e.getMessage());
        }
    }

    /**
     * 搜索数据（全文搜索）
     *
     * @param keyword    搜索关键词
     * @param categoryId 数据分类ID（可选）
     * @param period     时间周期（可选）
     * @return 搜索结果
     */
    @GetMapping("/search")
    public Response<Map<String, Object>> searchData(
            @RequestParam String keyword,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String period) {
        try {
            Map<String, Object> result = dataQueryService.searchData(keyword, categoryId, period);
            return Response.success(result);
        } catch (Exception e) {
            return Response.error(500, "搜索失败：" + e.getMessage());
        }
    }

    /**
     * 获取数据筛选条件选项
     *
     * @param filterType 筛选类型（dept/job/period/category）
     * @return 筛选选项
     */
    @GetMapping("/filter-options/{filterType}")
    public Response<Map<String, Object>> getFilterOptions(@PathVariable String filterType) {
        try {
            Map<String, Object> result = dataQueryService.getFilterOptions(filterType);
            return Response.success(result);
        } catch (Exception e) {
            return Response.error(500, "获取筛选选项失败：" + e.getMessage());
        }
    }

    /**
     * 获取所有可用的筛选类型
     *
     * @return 筛选类型列表
     */
    @GetMapping("/filter-types")
    public Response<List<Map<String, String>>> getFilterTypes() {
        List<Map<String, String>> filterTypes = new java.util.ArrayList<>();

        Map<String, String> dept = new java.util.HashMap<>();
        dept.put("code", "dept");
        dept.put("name", "部门筛选");
        dept.put("description", "按部门筛选数据");
        filterTypes.add(dept);

        Map<String, String> job = new java.util.HashMap<>();
        job.put("code", "job");
        job.put("name", "岗位筛选");
        job.put("description", "按岗位筛选数据");
        filterTypes.add(job);

        Map<String, String> period = new java.util.HashMap<>();
        period.put("code", "period");
        period.put("name", "时间周期筛选");
        period.put("description", "按时间周期筛选数据");
        filterTypes.add(period);

        Map<String, String> category = new java.util.HashMap<>();
        category.put("code", "category");
        category.put("name", "数据分类筛选");
        category.put("description", "按数据分类筛选数据");
        filterTypes.add(category);

        return Response.success(filterTypes);
    }
}
