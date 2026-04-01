package com.hr.backend.service;

import java.util.List;
import java.util.Map;

/**
 * 数据导出服务接口
 * <p>
 * 提供Excel和CSV格式的数据导出功能
 * 支持多种数据源的导出，包括分析数据、员工档案等
 */
public interface DataExportService {

    /**
     * 导出员工档案数据为Excel
     *
     * @param filters    筛选条件（部门、岗位、时间等）
     * @return Excel文件的字节数组
     */
    byte[] exportEmployeeProfileToExcel(Map<String, Object> filters);

    /**
     * 导出员工档案数据为CSV
     *
     * @param filters    筛选条件
     * @return CSV文件的字节数组
     */
    byte[] exportEmployeeProfileToCsv(Map<String, Object> filters);

    /**
     * 导出分析数据为Excel
     *
     * @param categoryId 数据分类ID
     * @param period     时间周期
     * @return Excel文件的字节数组
     */
    byte[] exportAnalysisDataToExcel(Long categoryId, String period);

    /**
     * 导出分析数据为CSV
     *
     * @param categoryId 数据分类ID
     * @param period     时间周期
     * @return CSV文件的字节数组
     */
    byte[] exportAnalysisDataToCsv(Long categoryId, String period);

    /**
     * 导出报表模板结果为Excel
     *
     * @param templateId 报表模板ID
     * @param parameters 报表参数
     * @return Excel文件的字节数组
     */
    byte[] exportReportToExcel(Long templateId, Map<String, Object> parameters);

    /**
     * 导出报表模板结果为CSV
     *
     * @param templateId 报表模板ID
     * @param parameters 报表参数
     * @return CSV文件的字节数组
     */
    byte[] exportReportToCsv(Long templateId, Map<String, Object> parameters);

    /**
     * 导出用户数据为Excel
     *
     * @return Excel文件的字节数组
     */
    byte[] exportUsersToExcel();

    /**
     * 导出部门数据为Excel
     *
     * @return Excel文件的字节数组
     */
    byte[] exportDepartmentsToExcel();

    /**
     * 批量导出多维度数据为Excel
     *
     * @param categoryIds 数据分类ID列表
     * @param period      时间周期
     * @return Excel文件的字节数组
     */
    byte[] exportMultiDimensionDataToExcel(List<Long> categoryIds, String period);
}
