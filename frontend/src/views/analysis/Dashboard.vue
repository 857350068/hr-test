<template>
    <div class="analysis-dashboard">
        <h2>数据分析看板</h2>

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
    </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { getOrganizationHealth } from '@/api/analysis'
import { getTurnoverWarningOverview, getTalentGapWarningOverview } from '@/api/warning'
import { OfficeBuilding, User, Money } from '@element-plus/icons-vue'

const router = useRouter()

const orgHealth = ref({})
const turnoverOverview = ref({})
const talentGapOverview = ref({})

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
