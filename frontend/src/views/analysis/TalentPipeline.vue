<template>
    <div class="talent-pipeline">
        <el-page-header @back="goBack" content="人才梯队分析" style="margin-bottom: 20px" />

        <el-card class="mb">
            <template #header>人才梯队健康度</template>
            <el-row :gutter="16">
                <el-col :span="6">
                    <div class="stat-block">
                        <div class="label">综合健康度</div>
                        <div class="value">{{ fmtNum(health.healthScore) }} 分</div>
                        <el-progress :percentage="Math.min(100, Number(health.healthScore) || 0)" />
                    </div>
                </el-col>
                <el-col :span="6">
                    <div class="stat-block">
                        <div class="label">高学历占比</div>
                        <div class="value">{{ fmtNum(health.highEducationRate) }}%</div>
                    </div>
                </el-col>
                <el-col :span="6">
                    <div class="stat-block">
                        <div class="label">继任准备度</div>
                        <div class="value">{{ fmtNum(health.successorReadiness) }}%</div>
                    </div>
                </el-col>
                <el-col :span="6">
                    <div class="stat-block">
                        <div class="label">核心 / 总人数</div>
                        <div class="value">
                            {{ health.coreTalentStats?.core_count ?? health.coreTalentStats?.CORE_COUNT ?? '-' }}
                            /
                            {{ health.coreTalentStats?.total_count ?? health.coreTalentStats?.TOTAL_COUNT ?? '-' }}
                        </div>
                    </div>
                </el-col>
            </el-row>
        </el-card>

        <el-card class="mb">
            <template #header>
                <div class="hdr">
                    <span>人才储备分析</span>
                    <el-input v-model="deptFilter" placeholder="按部门筛选（可选）" clearable style="width: 220px" @change="loadReserve" />
                </div>
            </template>
            <el-table :data="reserveList" border v-loading="loading.reserve">
                <el-table-column prop="department" label="部门" min-width="120" />
                <el-table-column prop="position" label="岗位" min-width="140" />
                <el-table-column prop="total_count" label="人数" width="90" />
                <el-table-column prop="high_talent_count" label="高学历人数" width="110" />
                <el-table-column prop="high_salary_count" label="高薪人数" width="100" />
                <el-table-column label="平均薪资" width="120">
                    <template #default="{ row }">{{ fmtMoney(row.avg_salary) }}</template>
                </el-table-column>
            </el-table>
        </el-card>

        <el-card class="mb">
            <template #header>继任计划（关键岗位）</template>
            <el-table :data="successionList" border v-loading="loading.succession">
                <el-table-column prop="department" label="部门" min-width="120" />
                <el-table-column prop="position" label="岗位" min-width="140" />
                <el-table-column prop="current_count" label="现有人数" width="100" />
                <el-table-column prop="manager_count" label="管理岗人数" width="110" />
                <el-table-column prop="potential_successor" label="潜在继任" width="100" />
            </el-table>
        </el-card>

        <el-card>
            <template #header>能力分布</template>
            <el-row :gutter="20">
                <el-col :span="12">
                    <h4>学历分布</h4>
                    <div ref="eduChart" class="chart" />
                </el-col>
                <el-col :span="12">
                    <h4>薪资区间能力分布</h4>
                    <div ref="salaryCapChart" class="chart" />
                </el-col>
            </el-row>
            <el-row :gutter="20" style="margin-top: 16px">
                <el-col :span="12">
                    <h4>工龄分布</h4>
                    <div ref="tenureChart" class="chart" />
                </el-col>
            </el-row>
        </el-card>
    </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import * as echarts from 'echarts'
import {
    getTalentReserve,
    getSuccessionPlan,
    getCapabilityAssessment,
    getTalentPipelineHealth
} from '@/api/analysis'

const router = useRouter()
const deptFilter = ref('')
const health = ref({})
const reserveList = ref([])
const successionList = ref([])
const capability = ref({})
const loading = ref({ reserve: false, succession: false, cap: false })

const eduChart = ref(null)
const salaryCapChart = ref(null)
const tenureChart = ref(null)

function fmtNum(v) {
    if (v == null || v === '') return '-'
    const n = Number(v)
    return Number.isFinite(n) ? n.toFixed(1) : String(v)
}

function fmtMoney(v) {
    if (v == null) return '-'
    const n = Number(v)
    return Number.isFinite(n) ? `${n.toFixed(0)} 元` : '-'
}

async function loadHealth() {
    const res = await getTalentPipelineHealth()
    health.value = res.data || {}
}

async function loadReserve() {
    loading.value.reserve = true
    try {
        const res = await getTalentReserve(deptFilter.value || undefined)
        reserveList.value = res.data || []
    } finally {
        loading.value.reserve = false
    }
}

async function loadSuccession() {
    loading.value.succession = true
    try {
        const res = await getSuccessionPlan()
        successionList.value = res.data || []
    } finally {
        loading.value.succession = false
    }
}

async function loadCapability() {
    loading.value.cap = true
    try {
        const res = await getCapabilityAssessment()
        capability.value = res.data || {}
    } finally {
        loading.value.cap = false
    }
}

function rowVal(row, key) {
    if (!row || !key) return undefined
    if (row[key] != null && row[key] !== '') return row[key]
    const found = Object.keys(row).find((k) => k.toLowerCase() === key.toLowerCase())
    return found != null ? row[found] : undefined
}

function drawBar(el, rows, nameKey, valKey, label) {
    if (!el) return
    const chart = echarts.init(el)
    const names = (rows || []).map((r) => rowVal(r, nameKey) ?? '-')
    const vals = (rows || []).map((r) => Number(rowVal(r, valKey)) || 0)
    chart.setOption({
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'category', data: names },
        yAxis: { type: 'value', name: label },
        series: [{ type: 'bar', data: vals, itemStyle: { color: '#409EFF' } }]
    })
}

async function initCharts() {
    await nextTick()
    const cap = capability.value
    const edu = cap.educationDistribution || []
    const sal = cap.salaryDistribution || []
    const ten = cap.tenureDistribution || []
    drawBar(eduChart.value, edu, 'education', 'count', '人数')
    drawBar(salaryCapChart.value, sal, 'salary_range', 'count', '人数')
    drawBar(tenureChart.value, ten, 'tenure_range', 'count', '人数')
}

onMounted(async () => {
    await loadHealth()
    await Promise.all([loadReserve(), loadSuccession(), loadCapability()])
    await initCharts()
})

function goBack() {
    router.push('/analysis/dashboard')
}
</script>

<style scoped>
.talent-pipeline {
    padding: 20px;
}
.mb {
    margin-bottom: 20px;
}
.hdr {
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.stat-block {
    padding: 8px 0;
}
.stat-block .label {
    color: #909399;
    font-size: 13px;
}
.stat-block .value {
    font-size: 22px;
    font-weight: 600;
    margin: 8px 0;
}
.chart {
    height: 280px;
}
h4 {
    margin: 0 0 12px;
    color: #303133;
}
</style>
