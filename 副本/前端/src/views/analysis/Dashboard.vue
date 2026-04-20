<template>
    <div class="analysis-dashboard">
        <h2>数据分析看板</h2>
        <el-card style="margin-bottom: 20px">
            <el-form :inline="true" :model="filters">
                <el-form-item label="部门">
                    <el-input v-model="filters.department" placeholder="部门筛选" clearable />
                </el-form-item>
                <el-form-item label="岗位">
                    <el-input v-model="filters.position" placeholder="岗位筛选" clearable />
                </el-form-item>
                <el-form-item label="统计周期">
                    <el-select v-model="filters.period" style="width: 140px">
                        <el-option label="月度" value="month" />
                        <el-option label="季度" value="quarter" />
                        <el-option label="年度" value="year" />
                    </el-select>
                </el-form-item>
                <el-form-item label="员工编号">
                    <el-input v-model="filters.empNo" placeholder="员工编号筛选" clearable />
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="exportCurrent">导出当前筛选</el-button>
                </el-form-item>
                <el-form-item>
                    <el-button type="success" @click="exportExcelMultiSheet">导出Excel多Sheet</el-button>
                </el-form-item>
                <el-form-item>
                    <el-button type="warning" @click="favoriteCurrent">收藏当前看板配置</el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <!-- 组织效能概览 -->
        <el-card class="overview-card" style="margin-bottom: 20px">
            <template #header>
                <div class="card-header">
                    <span>组织效能概览</span>
                    <el-button type="primary" size="small" @click="refreshOrgData">刷新</el-button>
                </div>
            </template>
            <el-row :gutter="20">
                <el-col :span="6">
                    <div class="stat-item">
                        <div class="stat-label">组织健康度</div>
                        <div class="stat-value">{{ orgHealth.healthScore || 0 }}分</div>
                        <el-progress :percentage="orgHealth.healthScore || 0" :color="getHealthColor(orgHealth.healthScore)"></el-progress>
                    </div>
                </el-col>
                <el-col :span="6">
                    <div class="stat-item">
                        <div class="stat-label">员工稳定性</div>
                        <div class="stat-value">{{ (orgHealth.stabilityRate || 0).toFixed(1) }}%</div>
                    </div>
                </el-col>
                <el-col :span="6">
                    <div class="stat-item">
                        <div class="stat-label">流失率</div>
                        <div class="stat-value">{{ (orgHealth.turnoverRate || 0).toFixed(1) }}%</div>
                    </div>
                </el-col>
                <el-col :span="6">
                    <div class="stat-item">
                        <div class="stat-label">高学历比例</div>
                        <div class="stat-value">{{ (orgHealth.highEducationRate || 0).toFixed(1) }}%</div>
                    </div>
                </el-col>
            </el-row>
        </el-card>

        <!-- 预警信息 -->
        <el-card class="warning-card" style="margin-bottom: 20px">
            <template #header>
                <div class="card-header">
                    <span>预警信息</span>
                    <el-badge :value="warningCount" type="danger"></el-badge>
                </div>
            </template>
            <el-row :gutter="20">
                <el-col :span="12">
                    <div class="warning-item">
                        <div class="warning-title">员工流失预警</div>
                        <div class="warning-stats">
                            <el-tag type="danger">高风险: {{ turnoverOverview.highRiskCount || 0 }}</el-tag>
                            <el-tag type="warning">中风险: {{ turnoverOverview.mediumRiskCount || 0 }}</el-tag>
                        </div>
                        <div class="warning-rate">整体流失率: {{ (turnoverOverview.overallTurnoverRate || 0).toFixed(1) }}%</div>
                    </div>
                </el-col>
                <el-col :span="12">
                    <div class="warning-item">
                        <div class="warning-title">人才缺口预警</div>
                        <div class="warning-stats">
                            <el-tag type="danger">紧急缺口: {{ talentGapOverview.urgentGapCount || 0 }}</el-tag>
                            <el-tag type="info">总缺口: {{ talentGapOverview.totalGapCount || 0 }}人</el-tag>
                        </div>
                        <div class="warning-rate">缺口岗位: {{ talentGapOverview.totalGapPositions || 0 }}个</div>
                    </div>
                </el-col>
            </el-row>
        </el-card>

        <!-- 数据分析模块入口 -->
        <el-row :gutter="20">
            <el-col :span="8">
                <el-card class="module-card" shadow="hover" @click="goToModule('org-efficiency')">
                    <div class="module-icon" style="background: #409EFF">
                        <el-icon><OfficeBuilding /></el-icon>
                    </div>
                    <div class="module-info">
                        <div class="module-title">组织效能分析</div>
                        <div class="module-desc">部门效能、组织架构、人员配置分析</div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="8">
                <el-card class="module-card" shadow="hover" @click="goToModule('talent-pipeline')">
                    <div class="module-icon" style="background: #67C23A">
                        <el-icon><User /></el-icon>
                    </div>
                    <div class="module-info">
                        <div class="module-title">人才梯队分析</div>
                        <div class="module-desc">人才储备、继任计划、能力评估</div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="8">
                <el-card class="module-card" shadow="hover" @click="goToModule('salary')">
                    <div class="module-icon" style="background: #E6A23C">
                        <el-icon><Money /></el-icon>
                    </div>
                    <div class="module-info">
                        <div class="module-title">薪酬福利分析</div>
                        <div class="module-desc">薪酬结构、竞争力、成本优化</div>
                    </div>
                </el-card>
            </el-col>
        </el-row>

        <el-row :gutter="20" style="margin-top: 20px">
            <el-col :span="8">
                <el-card class="module-card" shadow="hover" @click="goToModule('warning')">
                    <div class="module-icon" style="background: #F56C6C">
                        <el-icon><Warning /></el-icon>
                    </div>
                    <div class="module-info">
                        <div class="module-title">预警分析</div>
                        <div class="module-desc">流失风险、人才缺口明细</div>
                    </div>
                </el-card>
            </el-col>
        </el-row>
    </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { getOrganizationHealth, downloadAnalysisExport } from '@/api/analysis'
import { getTurnoverWarningOverview, getTalentGapWarningOverview } from '@/api/warning'
import { addFavorite } from '@/api/favorite'
import { exportMultiSheetExcel } from '@/utils/excel'
import { ElMessage } from 'element-plus'
import { OfficeBuilding, User, Money, Warning } from '@element-plus/icons-vue'

const router = useRouter()

const orgHealth = ref({})
const turnoverOverview = ref({})
const talentGapOverview = ref({})
const filters = ref({ department: '', position: '', period: 'month', empNo: '' })

const warningCount = computed(() => {
    return (turnoverOverview.value.highRiskCount || 0) + 
           (turnoverOverview.value.mediumRiskCount || 0) + 
           (talentGapOverview.value.urgentGapCount || 0)
})

onMounted(async () => {
    await loadDashboardData()
})

async function loadDashboardData() {
    try {
        // 加载组织健康度
        const healthRes = await getOrganizationHealth()
        orgHealth.value = healthRes.data
        
        // 加载流失预警概览
        const turnoverRes = await getTurnoverWarningOverview()
        turnoverOverview.value = turnoverRes.data
        
        // 加载人才缺口预警概览
        const gapRes = await getTalentGapWarningOverview()
        talentGapOverview.value = gapRes.data
    } catch (error) {
        console.error('加载看板数据失败:', error)
    }
}

async function refreshOrgData() {
    await loadDashboardData()
}

function getHealthColor(score) {
    if (score >= 80) return '#67C23A'
    if (score >= 60) return '#E6A23C'
    return '#F56C6C'
}

function goToModule(module) {
    router.push(`/analysis/${module}`)
}

async function favoriteCurrent() {
    await addFavorite({
        favoriteType: 'analysis_dashboard',
        targetKey: JSON.stringify(filters.value),
        title: '分析看板筛选',
        content: `周期:${filters.value.period} 部门:${filters.value.department || '全部'}`
    })
    ElMessage.success('已收藏当前看板配置')
}

async function exportCurrent() {
    try {
        const file = await downloadAnalysisExport({
            module: 'dashboard',
            department: filters.value.department || undefined,
            position: filters.value.position || undefined,
            period: filters.value.period || undefined,
            empNo: filters.value.empNo || undefined
        })
        const blobUrl = window.URL.createObjectURL(file)
        const link = document.createElement('a')
        link.href = blobUrl
        link.download = 'analysis_dashboard_export.csv'
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
        window.URL.revokeObjectURL(blobUrl)
        ElMessage.success('导出成功')
    } catch (error) {
        console.error('导出失败:', error)
        ElMessage.error('导出失败')
    }
}

async function exportExcelMultiSheet() {
    try {
        const sheetFilter = [
            {
                筛选项: '部门',
                值: filters.value.department || '全部'
            },
            {
                筛选项: '岗位',
                值: filters.value.position || '全部'
            },
            {
                筛选项: '统计周期',
                值: filters.value.period || 'month'
            },
            {
                筛选项: '员工编号',
                值: filters.value.empNo || '全部'
            }
        ]
        const sheetOrg = [orgHealth.value || {}]
        const sheetWarning = [
            {
                指标: '流失高风险人数',
                数值: turnoverOverview.value.highRiskCount || 0
            },
            {
                指标: '流失中风险人数',
                数值: turnoverOverview.value.mediumRiskCount || 0
            },
            {
                指标: '整体流失率',
                数值: turnoverOverview.value.overallTurnoverRate || 0
            },
            {
                指标: '紧急人才缺口数',
                数值: talentGapOverview.value.urgentGapCount || 0
            },
            {
                指标: '总缺口人数',
                数值: talentGapOverview.value.totalGapCount || 0
            },
            {
                指标: '缺口岗位数',
                数值: talentGapOverview.value.totalGapPositions || 0
            }
        ]
        exportMultiSheetExcel(
            [
                { name: '筛选条件', data: sheetFilter },
                { name: '组织健康', data: sheetOrg },
                { name: '预警概览', data: sheetWarning }
            ],
            '分析看板导出'
        )
        ElMessage.success('Excel多Sheet导出成功')
    } catch (error) {
        console.error('Excel导出失败:', error)
        ElMessage.error('Excel导出失败')
    }
}
</script>

<style scoped>
.analysis-dashboard {
    padding: 20px;
}

h2 {
    margin-bottom: 20px;
    color: #333;
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.stat-item {
    text-align: center;
    padding: 10px;
}

.stat-label {
    font-size: 14px;
    color: #666;
    margin-bottom: 10px;
}

.stat-value {
    font-size: 24px;
    font-weight: bold;
    color: #333;
    margin-bottom: 10px;
}

.warning-item {
    padding: 15px;
    border: 1px solid #EBEEF5;
    border-radius: 4px;
}

.warning-title {
    font-size: 16px;
    font-weight: bold;
    margin-bottom: 10px;
}

.warning-stats {
    margin-bottom: 10px;
}

.warning-stats .el-tag {
    margin-right: 10px;
}

.warning-rate {
    font-size: 14px;
    color: #666;
}

.module-card {
    cursor: pointer;
    padding: 20px;
    display: flex;
    align-items: center;
}

.module-icon {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 30px;
    margin-right: 20px;
}

.module-info {
    flex: 1;
}

.module-title {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 5px;
}

.module-desc {
    font-size: 14px;
    color: #666;
}
</style>
