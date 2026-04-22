<template>
    <div class="warning-analysis">
        <el-page-header @back="goBack" content="预警分析" style="margin-bottom: 20px" />
        <el-card class="mb">
            <el-form :inline="true" :model="filters">
                <el-form-item label="部门">
                    <el-input v-model="filters.department" placeholder="部门筛选" clearable />
                </el-form-item>
                <el-form-item label="岗位">
                    <el-input v-model="filters.position" placeholder="岗位筛选" clearable />
                </el-form-item>
                <el-form-item label="员工编号">
                    <el-input v-model="filters.empNo" placeholder="员工编号筛选" clearable />
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="applyFilters">应用筛选</el-button>
                </el-form-item>
                <el-form-item>
                    <el-button @click="resetFilters">重置</el-button>
                </el-form-item>
                <el-form-item>
                    <el-button type="success" @click="exportCurrent">导出筛选结果</el-button>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="exportExcelMultiSheet">导出Excel多Sheet</el-button>
                </el-form-item>
                <el-form-item>
                    <el-button type="warning" @click="favoriteCurrent">收藏当前筛选</el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <el-card class="mb">
            <template #header>员工流失风险</template>
            <el-row :gutter="20">
                <el-col :span="12">
                    <h4>风险列表</h4>
                    <el-table :data="turnoverRisk" border size="small" max-height="360" v-loading="loading.risk">
                        <el-table-column type="index" width="50" />
                        <el-table-column
                            v-for="col in riskColumns"
                            :key="col"
                            :prop="col"
                            :label="col"
                            min-width="100"
                            show-overflow-tooltip
                        />
                    </el-table>
                </el-col>
                <el-col :span="12">
                    <h4>部门流失率</h4>
                    <div ref="deptTurnChart" class="chart" />
                </el-col>
            </el-row>
        </el-card>

        <el-card>
            <template #header>人才缺口</template>
            <el-row :gutter="20">
                <el-col :span="12">
                    <h4>缺口分析</h4>
                    <el-table :data="gapAnalysis" border size="small" max-height="360" v-loading="loading.gap">
                        <el-table-column
                            v-for="col in gapColumns"
                            :key="col"
                            :prop="col"
                            :label="col"
                            min-width="100"
                            show-overflow-tooltip
                        />
                    </el-table>
                </el-col>
                <el-col :span="12">
                    <h4>部门人才结构</h4>
                    <el-table :data="gapStructure" border size="small" max-height="360" v-loading="loading.struct">
                        <el-table-column
                            v-for="col in structColumns"
                            :key="col"
                            :prop="col"
                            :label="col"
                            min-width="100"
                            show-overflow-tooltip
                        />
                    </el-table>
                </el-col>
            </el-row>
        </el-card>

        <el-card class="mt">
            <template #header>人力成本超支预警</template>
            <el-table :data="costOverrun" border size="small" max-height="360" v-loading="loading.cost">
                <el-table-column
                    v-for="col in costColumns"
                    :key="col"
                    :prop="col"
                    :label="col"
                    min-width="110"
                    show-overflow-tooltip
                />
            </el-table>
        </el-card>
    </div>
</template>

<script setup>
import { ref, onMounted, nextTick, computed } from 'vue'
import { useRouter } from 'vue-router'
import * as echarts from 'echarts'
import {
    getTurnoverRiskAnalysis,
    getDepartmentTurnoverRate,
    getTalentGapAnalysis,
    getDepartmentStructureAnalysis,
    getCostOverrunAnalysis
} from '@/api/warning'
import { downloadAnalysisExport } from '@/api/analysis'
import { exportMultiSheetExcel } from '@/utils/excel'
import { addFavorite } from '@/api/favorite'
import { ElMessage } from 'element-plus'

const router = useRouter()
const turnoverRisk = ref([])
const deptRate = ref([])
const gapAnalysis = ref([])
const gapStructure = ref([])
const rawTurnoverRisk = ref([])
const rawGapAnalysis = ref([])
const rawGapStructure = ref([])
const rawCostOverrun = ref([])
const costOverrun = ref([])
const loading = ref({ risk: false, gap: false, struct: false, cost: false })
const deptTurnChart = ref(null)
const filters = ref({ department: '', position: '', empNo: '' })

const riskColumns = computed(() => pickColumns(turnoverRisk.value))
const gapColumns = computed(() => pickColumns(gapAnalysis.value))
const structColumns = computed(() => pickColumns(gapStructure.value))
const costColumns = computed(() => pickColumns(costOverrun.value))

function pickColumns(rows) {
    if (!rows || !rows.length) return []
    return Object.keys(rows[0])
}

function goBack() {
    router.push('/analysis/dashboard')
}

function initDeptChart() {
    if (!deptTurnChart.value || !deptRate.value.length) return
    const rows = deptRate.value
    const c = echarts.init(deptTurnChart.value)
    const x = rows.map((r) => r.department ?? r.dept ?? r.DEPARTMENT ?? '-')
    const y = rows.map((r) => Number(r.turnover_rate ?? r.rate ?? r.TURNOVER_RATE ?? 0))
    c.setOption({
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'category', data: x, axisLabel: { rotate: 25 } },
        yAxis: { type: 'value', name: '流失率%' },
        series: [{ type: 'bar', data: y, itemStyle: { color: '#F56C6C' } }]
    })
}

onMounted(async () => {
    loading.value = { risk: true, gap: true, struct: true, cost: true }
    try {
        const [a, b, c, d, e] = await Promise.all([
            getTurnoverRiskAnalysis(),
            getDepartmentTurnoverRate(),
            getTalentGapAnalysis(),
            getDepartmentStructureAnalysis(),
            getCostOverrunAnalysis()
        ])
        rawTurnoverRisk.value = a.data || []
        deptRate.value = b.data || []
        rawGapAnalysis.value = c.data || []
        rawGapStructure.value = d.data || []
        rawCostOverrun.value = e.data || []
        applyFilters()
    } finally {
        loading.value = { risk: false, gap: false, struct: false, cost: false }
    }
    await nextTick()
    initDeptChart()
})

function textMatch(val, keyword) {
    if (!keyword) return true
    return String(val ?? '').includes(keyword)
}

function textMatchOptional(val, keyword) {
    if (!keyword) return true
    if (val === undefined || val === null) return true
    return String(val).includes(keyword)
}

function applyFilters() {
    turnoverRisk.value = rawTurnoverRisk.value.filter((r) =>
        textMatch(r.department ?? r.DEPARTMENT, filters.value.department) &&
        textMatch(r.position ?? r.POSITION, filters.value.position) &&
        textMatch(r.emp_no ?? r.EMP_NO ?? r.empNo, filters.value.empNo)
    )
    gapAnalysis.value = rawGapAnalysis.value.filter((r) =>
        textMatch(r.department ?? r.DEPARTMENT, filters.value.department) &&
        textMatch(r.position ?? r.POSITION, filters.value.position)
    )
    gapStructure.value = rawGapStructure.value.filter((r) =>
        textMatch(r.department ?? r.DEPARTMENT, filters.value.department)
    )
    costOverrun.value = rawCostOverrun.value.filter((r) =>
        textMatch(r.department ?? r.DEPARTMENT, filters.value.department) &&
        textMatchOptional(r.position ?? r.POSITION, filters.value.position) &&
        textMatchOptional(r.emp_no ?? r.EMP_NO ?? r.empNo, filters.value.empNo)
    )
}

function resetFilters() {
    filters.value = { department: '', position: '', empNo: '' }
    applyFilters()
}

async function favoriteCurrent() {
    await addFavorite({
        favoriteType: 'warning_filter',
        targetKey: JSON.stringify(filters.value),
        title: '预警分析筛选',
        content: `部门:${filters.value.department || '全部'} 岗位:${filters.value.position || '全部'}`
    })
    ElMessage.success('已收藏当前筛选')
}

async function exportCurrent() {
    try {
        const file = await downloadAnalysisExport({
            module: 'warning',
            department: filters.value.department || undefined,
            position: filters.value.position || undefined,
            empNo: filters.value.empNo || undefined
        })
        const blobUrl = window.URL.createObjectURL(file)
        const link = document.createElement('a')
        link.href = blobUrl
        link.download = 'warning_filter_export.csv'
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

function createFieldMapping(rows) {
    if (!rows || !rows.length) {
        return {}
    }
    const mapping = {}
    Object.keys(rows[0]).forEach((key) => {
        mapping[key] = key
    })
    return mapping
}

async function exportExcelMultiSheet() {
    try {
        const sheets = [
            {
                name: '流失风险',
                data: turnoverRisk.value || [],
                fieldMapping: createFieldMapping(turnoverRisk.value || [])
            },
            {
                name: '人才缺口',
                data: gapAnalysis.value || [],
                fieldMapping: createFieldMapping(gapAnalysis.value || [])
            },
            {
                name: '部门结构',
                data: gapStructure.value || [],
                fieldMapping: createFieldMapping(gapStructure.value || [])
            },
            {
                name: '成本超支',
                data: costOverrun.value || [],
                fieldMapping: createFieldMapping(costOverrun.value || [])
            }
        ]
        exportMultiSheetExcel(sheets, '预警分析导出')
        ElMessage.success('Excel多Sheet导出成功')
    } catch (error) {
        console.error('Excel导出失败:', error)
        ElMessage.error('Excel导出失败')
    }
}
</script>

<style scoped>
.warning-analysis {
    padding: 20px;
}
.mb {
    margin-bottom: 20px;
}
.chart {
    height: 360px;
}
h4 {
    margin: 0 0 12px;
    color: #303133;
}
.mt {
    margin-top: 20px;
}
</style>
