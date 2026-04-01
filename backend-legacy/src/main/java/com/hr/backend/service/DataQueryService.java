package com.hr.backend.service;

import java.util.Map;

/**
 * 数据查询服务接口
 * <p>
 * 提供高级数据筛选和查询功能
 * 支持多条件组合查询、数据对比、趋势分析等
 */
public interface DataQueryService {

    /**
     * 高级查询员工档案数据
     *
     * @param filters 筛选条件（支持多条件组合）
     * @return 查询结果
     */
    Map<String, Object> advancedQueryEmployeeProfile(Map<String, Object> filters);

    /**
     * 查询分析数据对比
     *
     * @param categoryId 数据分类ID
     * @param period1    时间周期1
     * @param period2    时间周期2
     * @return 对比结果
     */
    Map<String, Object> compareAnalysisData(Long categoryId, String period1, String period2);

    /**
     * 查询数据趋势分析
     *
     * @param categoryId 数据分类ID
     * @param startDate  开始日期
     * @param endDate    结束日期
     * @return 趋势数据
     */
    Map<String, Object> queryTrendData(Long categoryId, String startDate, String endDate);

    /**
     * 查询部门排名数据
     *
     * @param categoryId 数据分类ID
     * @param period     时间周期
     * @param limit      返回数量限制
     * @return 排名数据
     */
    Map<String, Object> queryDepartmentRanking(Long categoryId, String period, Integer limit);

    /**
     * 查询员工个人详细数据
     *
     * @param employeeNo 员工编号
     * @return 员工详细数据
     */
    Map<String, Object> queryEmployeeDetail(String employeeNo);

    /**
     * 查询多维度数据汇总
     *
     * @param categoryIds 数据分类ID列表
     * @param period      时间周期
     * @return 汇总数据
     */
    Map<String, Object> queryMultiDimensionSummary(java.util.List<Long> categoryIds, String period);

    /**
     * 查询数据统计摘要
     *
     * @param categoryId 数据分类ID
     * @param period     时间周期
     * @return 统计摘要
     */
    Map<String, Object> queryDataSummary(Long categoryId, String period);

    /**
     * 搜索数据（全文搜索）
     *
     * @param keyword    搜索关键词
     * @param categoryId 数据分类ID（可选）
     * @param period     时间周期（可选）
     * @return 搜索结果
     */
    Map<String, Object> searchData(String keyword, Long categoryId, String period);

    /**
     * 获取数据筛选条件选项
     *
     * @param filterType 筛选类型（dept/job/period等）
     * @return 筛选选项
     */
    Map<String, Object> getFilterOptions(String filterType);
}
