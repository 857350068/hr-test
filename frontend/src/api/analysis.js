import request from './request'
import axios from 'axios'

// ==================== 组织效能分析 ====================

/**
 * 获取部门效能分析
 */
export function getDepartmentEfficiency(department) {
  return request({
    url: '/analysis/org-efficiency/department',
    method: 'get',
    params: { department }
  })
}

/**
 * 获取组织架构分析
 */
export function getOrganizationStructure() {
  return request({
    url: '/analysis/org-efficiency/structure',
    method: 'get'
  })
}

/**
 * 获取人员配置分析
 */
export function getStaffingAnalysis() {
  return request({
    url: '/analysis/org-efficiency/staffing',
    method: 'get'
  })
}

/**
 * 获取组织健康度
 */
export function getOrganizationHealth(params = {}) {
  return request({
    url: '/analysis/org-efficiency/health',
    method: 'get',
    params
  })
}

// ==================== 人才梯队分析 ====================

/**
 * 获取人才储备分析
 */
export function getTalentReserve(department) {
  return request({
    url: '/analysis/talent-pipeline/reserve',
    method: 'get',
    params: { department }
  })
}

/**
 * 获取继任计划分析
 */
export function getSuccessionPlan() {
  return request({
    url: '/analysis/talent-pipeline/succession',
    method: 'get'
  })
}

/**
 * 获取能力评估分析
 */
export function getCapabilityAssessment() {
  return request({
    url: '/analysis/talent-pipeline/capability',
    method: 'get'
  })
}

/**
 * 获取人才梯队健康度
 */
export function getTalentPipelineHealth() {
  return request({
    url: '/analysis/talent-pipeline/health',
    method: 'get'
  })
}

// ==================== 薪酬福利分析 ====================

/**
 * 获取薪酬结构分析
 */
export function getSalaryStructure() {
  return request({
    url: '/analysis/salary/structure',
    method: 'get'
  })
}

/**
 * 获取薪酬竞争力分析
 */
export function getSalaryCompetitiveness() {
  return request({
    url: '/analysis/salary/competitiveness',
    method: 'get'
  })
}

/**
 * 获取人力成本分析
 */
export function getLaborCostAnalysis() {
  return request({
    url: '/analysis/salary/cost',
    method: 'get'
  })
}

/**
 * 获取薪酬优化建议
 */
export function getSalaryOptimization() {
  return request({
    url: '/analysis/salary/optimization',
    method: 'get'
  })
}

export async function downloadAnalysisExport(params = {}) {
  const token = localStorage.getItem('token')
  const response = await axios({
    url: '/api/analysis/export',
    method: 'get',
    params,
    responseType: 'blob',
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  })
  return response.data
}
