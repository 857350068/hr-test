<template>
    <div class="salary-analysis">
        <el-page-header @back="goBack" content="薪酬福利分析" style="margin-bottom: 20px" />

        <el-card class="mb">
            <template #header>薪酬结构</template>
            <el-row :gutter="20">
                <el-col :span="12">
                    <h4>部门薪酬</h4>
                    <div ref="deptSalChart" class="chart" />
                </el-col>
                <el-col :span="12">
                    <h4>薪酬区间分布</h4>
                    <div ref="rangeChart" class="chart" />
                </el-col>
            </el-row>
            <el-divider />
            <h4>岗位薪酬 Top</h4>
            <el-table :data="structure.positionSalary || []" border size="small" max-height="320">
                <el-table-column prop="position" label="岗位" min-width="140" />
                <el-table-column prop="emp_count" label="人数" width="80" />
                <el-table-column label="平均薪资" width="120">
                    <template #default="{ row }">{{ fmtMoney(row.avg_salary) }}</template>
                </el-table-column>
                <el-table-column label="最低" width="100">
                    <template #default="{ row }">{{ fmtMoney(row.min_salary) }}</template>
                </el-table-column>
                <el-table-column label="最高" width="100">
                    <template #default="{ row }">{{ fmtMoney(row.max_salary) }}</template>
                </el-table-column>
            </el-table>
        </el-card>

        <el-card class="mb">
            <template #header>薪酬竞争力</template>
            <el-row :gutter="16" style="margin-bottom: 16px">
                <el-col :span="8">
                    <el-statistic title="全员平均薪资" :value="fmtNum(compete.overallStats?.avg_salary)" suffix="元" />
                </el-col>
                <el-col :span="8">
                    <el-statistic title="中位数" :value="fmtNum(compete.overallStats?.median_salary)" suffix="元" />
                </el-col>
                <el-col :span="8">
                    <el-statistic title="标准差" :value="fmtNum(compete.overallStats?.salary_stddev)" />
                </el-col>
            </el-row>
            <el-table :data="compete.departmentCompetitiveness || []" border>
                <el-table-column prop="department" label="部门" />
                <el-table-column label="平均薪资">
                    <template #default="{ row }">{{ fmtMoney(row.avg_salary) }}</template>
                </el-table-column>
                <el-table-column label="与全员差值">
                    <template #default="{ row }">{{ fmtMoney(row.salary_diff) }}</template>
                </el-table-column>
            </el-table>
            <h4 style="margin-top: 16px">高薪人才分布</h4>
            <el-table :data="compete.highPayDistribution || []" border size="small">
                <el-table-column prop="department" label="部门" />
                <el-table-column prop="position" label="岗位" />
                <el-table-column prop="high_pay_count" label="高薪人数" width="100" />
            </el-table>
        </el-card>

        <el-card class="mb">
            <template #header>人力成本</template>
            <el-row :gutter="16" style="margin-bottom: 16px">
                <el-col :span="8">
                    <el-statistic title="总成本" :value="fmtNum(cost.totalCost?.total_cost)" suffix="元" />
                </el-col>
                <el-col :span="8">
                    <el-statistic title="人均成本" :value="fmtNum(cost.totalCost?.avg_cost)" suffix="元" />
                </el-col>
                <el-col :span="8">
                    <el-statistic title="在职人数" :value="cost.totalCost?.emp_count ?? 0" />
                </el-col>
            </el-row>
            <el-row :gutter="20">
                <el-col :span="12">
                    <h4>部门成本占比</h4>
                    <div ref="costRatioChart" class="chart" />
                </el-col>
                <el-col :span="12">
                    <h4>年度新增成本趋势</h4>
                    <div ref="costTrendChart" class="chart" />
                </el-col>
            </el-row>
        </el-card>

        <el-card>
            <template #header>薪酬优化建议</template>
            <el-table :data="optimization" border>
                <el-table-column prop="type" label="类型" width="120" />
                <el-table-column prop="employee" label="员工" width="120" />
                <el-table-column prop="department" label="部门" width="140" />
                <el-table-column prop="currentSalary" label="当前薪资" width="120">
                    <template #default="{ row }">{{ fmtMoney(row.currentSalary) }}</template>
                </el-table-column>
                <el-table-column prop="suggestion" label="建议" min-width="200" />
            </el-table>
        </el-card>
    </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import * as echarts from 'echarts'
import {
    getSalaryStructure,
    getSalaryCompetitiveness,
    getLaborCostAnalysis,
    getSalaryOptimization
} from '@/api/analysis'

const router = useRouter()
const structure = ref({})
const compete = ref({})
const cost = ref({})
const optimization = ref([])

const deptSalChart = ref(null)
const rangeChart = ref(null)
const costRatioChart = ref(null)
const costTrendChart = ref(null)

function fmtNum(v) {
    if (v == null || v === '') return '-'
    const n = Number(v)
    return Number.isFinite(n) ? Math.round(n * 100) / 100 : '-'
}

function fmtMoney(v) {
    if (v == null) return '-'
    const n = Number(v)
    return Number.isFinite(n) ? n.toFixed(0) : '-'
}

function goBack() {
    router.push('/analysis/dashboard')
}

function initDeptChart() {
    const rows = structure.value.departmentSalary || []
    if (!deptSalChart.value) return
    const c = echarts.init(deptSalChart.value)
    c.setOption({
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'category', data: rows.map((r) => r.department), axisLabel: { rotate: 30 } },
        yAxis: { type: 'value', name: '平均薪资' },
        series: [{ type: 'bar', data: rows.map((r) => r.avg_salary || 0), itemStyle: { color: '#67C23A' } }]
    })
}

function initRangeChart() {
    const rows = structure.value.salaryRangeDistribution || []
    if (!rangeChart.value) return
    const c = echarts.init(rangeChart.value)
    c.setOption({
        tooltip: { trigger: 'item' },
        series: [
            {
                type: 'pie',
                radius: '58%',
                data: rows.map((r) => ({ name: r.salary_range, value: r.count }))
            }
        ]
    })
}

function initCostCharts() {
    const ratio = cost.value.departmentCostRatio || []
    if (costRatioChart.value) {
        const c = echarts.init(costRatioChart.value)
        c.setOption({
            tooltip: { trigger: 'axis' },
            xAxis: { type: 'category', data: ratio.map((r) => r.department) },
            yAxis: { type: 'value', name: '占比%' },
            series: [{ type: 'line', data: ratio.map((r) => r.cost_ratio || 0), smooth: true }]
        })
    }
    const trend = cost.value.costTrend || []
    if (costTrendChart.value) {
        const c = echarts.init(costTrendChart.value)
        c.setOption({
            tooltip: { trigger: 'axis' },
            xAxis: { type: 'category', data: trend.map((r) => r.year) },
            yAxis: { type: 'value' },
            series: [{ name: '新增成本', type: 'bar', data: trend.map((r) => r.new_cost || 0) }]
        })
    }
}

onMounted(async () => {
    const [s, co, l, o] = await Promise.all([
        getSalaryStructure(),
        getSalaryCompetitiveness(),
        getLaborCostAnalysis(),
        getSalaryOptimization()
    ])
    structure.value = s.data || {}
    compete.value = co.data || {}
    cost.value = l.data || {}
    optimization.value = o.data || []
    await nextTick()
    initDeptChart()
    initRangeChart()
    initCostCharts()
})
</script>

<style scoped>
.salary-analysis {
    padding: 20px;
}
.mb {
    margin-bottom: 20px;
}
.chart {
    height: 300px;
}
h4 {
    margin: 0 0 12px;
    color: #303133;
}
</style>
