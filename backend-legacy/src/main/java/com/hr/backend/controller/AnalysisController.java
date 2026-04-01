/**
 * ================================================================================
 * 人力资源数据中心系统 - 数据分析控制器
 * ================================================================================
 * 项目名称：HrDataCenter（人力资源数据中心系统）
 * 模块名称：控制器层（controller）
 *
 * 类说明：AnalysisController
 * 本类负责处理数据分析相关的HTTP请求，提供各种人力资源数据分析接口
 *
 * 设计目的：
 * 1. 提供组织效率、人才梯队、薪酬福利等多维度数据分析接口
 * 2. 支持按时间段查询历史数据
 * 3. 返回格式化的分析数据供前端展示
 *
 * 分析维度：
 * 1. 组织效率分析：人均产出、部门效率对比等
 * 2. 人才梯队分析：人才结构、晋升情况等
 * 3. 薪酬福利分析：薪酬分布、福利统计等
 * 4. 绩效管理分析：绩效分布、绩效趋势等
 * 5. 员工流失分析：流失率、流失原因等
 * 6. 培训效果分析：培训投入、培训效果等
 * 7. 人力成本优化：成本结构、成本趋势等
 * 8. 人才发展分析：技能提升、职业发展等
 * ================================================================================
 */
package com.hr.backend.controller;

import com.hr.backend.common.Response;
import com.hr.backend.service.AnalysisService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.Map;

/**
 * 数据分析控制器
 * <p>
 * 使用@RestController注解标记为REST控制器
 * 使用@RequestMapping指定基础路径为/api/analysis
 * 所有接口都需要JWT认证（由SecurityConfig配置）
 */
@RestController
@RequestMapping("/api/analysis")
public class AnalysisController {

    /**
     * 数据分析服务
     * <p>
     * 负责从MySQL和Hive中查询数据，进行统计分析
     */
    @Resource
    private AnalysisService analysisService;

    /**
     * 获取组织效率分析数据
     * <p>
     * 功能：
     * - 分析各部门的人均产出
     * - 对比部门效率
     * - 识别低效部门
     *
     * @param period 时间周期（可选），如"2024-01"、"2024-Q1"等
     * @return 组织效率分析数据，包含各部门效率指标
     */
    @GetMapping("/organization-efficiency")
    public Response<Map<String, Object>> getOrganizationEfficiency(@RequestParam(required = false) String period) {
        return Response.success(analysisService.getOrganizationEfficiencyData(period));
    }

    /**
     * 获取人才梯队分析数据
     * <p>
     * 功能：
     * - 分析人才结构（年龄、学历、职级分布）
     * - 分析人才储备情况
     * - 分析人才晋升趋势
     *
     * @param period 时间周期（可选）
     * @return 人才梯队分析数据
     */
    @GetMapping("/talent-pipeline")
    public Response<Map<String, Object>> getTalentPipeline(@RequestParam(required = false) String period) {
        return Response.success(analysisService.getTalentPipelineData(period));
    }

    /**
     * 获取薪酬福利分析数据
     * <p>
     * 功能：
     * - 分析薪酬分布（各薪资段人数）
     * - 分析各部门薪酬对比
     * - 分析福利使用情况
     *
     * @param period 时间周期（可选）
     * @return 薪酬福利分析数据
     */
    @GetMapping("/compensation-benefit")
    public Response<Map<String, Object>> getCompensationBenefit(@RequestParam(required = false) String period) {
        return Response.success(analysisService.getCompensationBenefitData(period));
    }

    /**
     * 获取绩效管理分析数据
     * <p>
     * 功能：
     * - 分析绩效评分分布
     * - 分析各部门绩效对比
     * - 分析绩效趋势变化
     *
     * @param period 时间周期（可选）
     * @return 绩效管理分析数据
     */
    @GetMapping("/performance-management")
    public Response<Map<String, Object>> getPerformanceManagement(@RequestParam(required = false) String period) {
        return Response.success(analysisService.getPerformanceManagementData(period));
    }

    /**
     * 获取员工流失分析数据
     * <p>
     * 功能：
     * - 计算员工流失率
     * - 分析流失原因分布
     * - 分析流失人员特征
     *
     * @param period 时间周期（可选）
     * @return 员工流失分析数据
     */
    @GetMapping("/employee-turnover")
    public Response<Map<String, Object>> getEmployeeTurnover(@RequestParam(required = false) String period) {
        return Response.success(analysisService.getEmployeeTurnoverData(period));
    }

    /**
     * 获取培训效果分析数据
     * <p>
     * 功能：
     * - 分析培训投入情况
     * - 分析培训覆盖率
     * - 分析培训效果评估
     *
     * @param period 时间周期（可选）
     * @return 培训效果分析数据
     */
    @GetMapping("/training-effect")
    public Response<Map<String, Object>> getTrainingEffect(@RequestParam(required = false) String period) {
        return Response.success(analysisService.getTrainingEffectData(period));
    }

    /**
     * 获取人力成本优化分析数据
     * <p>
     * 功能：
     * - 分析人力成本结构
     * - 分析成本趋势变化
     * - 提供成本优化建议
     *
     * @param period 时间周期（可选）
     * @return 人力成本优化分析数据
     */
    @GetMapping("/human-cost-optimization")
    public Response<Map<String, Object>> getHumanCostOptimization(@RequestParam(required = false) String period) {
        return Response.success(analysisService.getHumanCostOptimizationData(period));
    }

    /**
     * 获取人才发展分析数据
     * <p>
     * 功能：
     * - 分析员工技能提升情况
     * - 分析职业发展路径
     * - 分析继任计划情况
     *
     * @param period 时间周期（可选）
     * @return 人才发展分析数据
     */
    @GetMapping("/talent-development")
    public Response<Map<String, Object>> getTalentDevelopment(@RequestParam(required = false) String period) {
        return Response.success(analysisService.getTalentDevelopmentData(period));
    }
}
