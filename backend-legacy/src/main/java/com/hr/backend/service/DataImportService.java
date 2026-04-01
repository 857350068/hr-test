package com.hr.backend.service;

import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

/**
 * 数据导入服务接口
 * <p>
 * 提供Excel文件的数据导入功能
 * 支持员工档案、用户数据等的批量导入
 */
public interface DataImportService {

    /**
     * 导入员工档案数据（Excel格式）
     *
     * @param file Excel文件
     * @return 导入结果，包含成功数量、失败数量、错误信息等
     */
    Map<String, Object> importEmployeeProfiles(MultipartFile file);

    /**
     * 导入用户数据（Excel格式）
     *
     * @param file Excel文件
     * @return 导入结果
     */
    Map<String, Object> importUsers(MultipartFile file);

    /**
     * 导入部门数据（Excel格式）
     *
     * @param file Excel文件
     * @return 导入结果
     */
    Map<String, Object> importDepartments(MultipartFile file);

    /**
     * 导入分析数据（Excel格式）
     *
     * @param file       Excel文件
     * @param categoryId 数据分类ID
     * @return 导入结果
     */
    Map<String, Object> importAnalysisData(MultipartFile file, Long categoryId);

    /**
     * 批量导入多维度数据（Excel格式，多个Sheet）
     *
     * @param file Excel文件
     * @return 导入结果
     */
    Map<String, Object> importMultiDimensionData(MultipartFile file);

    /**
     * 验证导入数据的格式和内容
     *
     * @param file Excel文件
     * @param dataType 数据类型（employee_profile/user/department等）
     * @return 验证结果
     */
    Map<String, Object> validateImportData(MultipartFile file, String dataType);

    /**
     * 获取导入模板（Excel格式）
     *
     * @param dataType 数据类型
     * @return Excel文件的字节数组
     */
    byte[] getImportTemplate(String dataType);
}
