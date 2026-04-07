<template>
    <div class="org-efficiency">
        <el-page-header @back="goBack" content="组织效能分析" style="margin-bottom: 20px"></el-page-header>

        <!-- 部门效能分析 -->
        <el-card style="margin-bottom: 20px">
            <template #header>
                <span>部门效能分析</span>
            </template>
            <el-table :data="deptEfficiency" border style="width: 100%">
                <el-table-column prop="department" label="部门" width="150"></el-table-column>
                <el-table-column prop="emp_count" label="人数" width="80"></el-table-column>
                <el-table-column prop="avg_salary" label="平均薪资" width="120">
                    <template #default="scope">
                        {{ (scope.row.avg_salary || 0).toFixed(0) }}元
                    </template>
                </el-table-column>
                <el-table-column prop="total_salary" label="薪资总额" width="120">
                    <template #default="scope">
                        {{ ((scope.row.total_salary || 0) / 10000).toFixed(1) }}万
                    </template>
                </el-table-column>
                <el-table-column prop="active_count" label="在职人数" width="100"></el-table-column>
                <el-table-column prop="inactive_count" label="离职人数" width="100"></el-table-column>
                <el-table-column label="效能评分" width="150">
                    <template #default="scope">
                        <el-progress :percentage="calculateEfficiency(scope.row)" :color="getEfficiencyColor"></el-progress>
                    </template>
                </el-table-column>
            </el-table>
        </el-card>

        <!-- 组织架构分析 -->
        <el-card style="margin-bottom: 20px">
            <template #header>
                <span>组织架构分析</span>
            </template>
            <el-row :gutter="20">
                <el-col :span="12">
                    <h4>部门人员分布</h4>
                    <div ref="deptChart" style="height: 300px"></div>
                </el-col>
                <el-col :span="12">
                    <h4>岗位人员分布（Top 10）</h4>
                    <div ref="posChart" style="height: 300px"></div>
                </el-col>
            </el-row>
        </el-card>

        <!-- 组织健康度 -->
        <el-card style="margin-bottom: 20px">
            <template #header>
                <span>组织健康度评估</span>
            </template>
            <el-row :gutter="20">
                <el-col :span="6">
                    <div class="health-item">
                        <div class="health-label">综合评分</div>
                        <div class="health-value">{{ (orgHealth.healthScore || 0).toFixed(1) }}分</div>
                        <el-rate v-model="healthRate" disabled show-score text-color="#ff9900"></el-rate>
                    </div>
                </el-col>
                <el-col :span="6">
                    <div class="health-item">
                        <div class="health-label">员工稳定性</div>
                        <div class="health-value">{{ (orgHealth.stabilityRate || 0).toFixed(1) }}%</div>
                        <el-progress :percentage="orgHealth.stabilityRate || 0" color="#67C23A"></el-progress>
                    </div>
                </el-col>
                <el-col :span="6">
                    <div class="health-item">
                        <div class="health-label">流失率</div>
                        <div class="health-value">{{ (orgHealth.turnoverRate || 0).toFixed(1) }}%</div>
                        <el-progress :percentage="100 - (orgHealth.turnoverRate || 0)" color="#E6A23C"></el-progress>
                    </div>
                </el-col>
                <el-col :span="6">
                    <div class="health-item">
                        <div class="health-label">高学历比例</div>
                        <div class="health-value">{{ (orgHealth.highEducationRate || 0).toFixed(1) }}%</div>
                        <el-progress :percentage="orgHealth.highEducationRate || 0" color="#409EFF"></el-progress>
                    </div>
                </el-col>
            </el-row>
        </el-card>

        <!-- 部门对比分析 -->
        <el-card style="margin-bottom: 20px">
            <template #header>
                <span>部门对比分析</span>
            </template>
            <el-row :gutter="20">
                <el-col :span="12">
                    <h4>部门薪资对比</h4>
                    <div ref="salaryChart" style="height: 300px"></div>
                </el-col>
                <el-col :span="12">
                    <h4>部门人数对比</h4>
                    <div ref="employeeChart" style="height: 300px"></div>
                </el-col>
            </el-row>
        </el-card>

        <!-- 薪资分布分析 -->
        <el-card style="margin-bottom: 20px">
            <template #header>
                <span>薪资分布分析</span>
            </template>
            <el-row :gutter="20">
                <el-col :span="12">
                    <h4>薪资区间分布</h4>
                    <div ref="salaryRangeChart" style="height: 300px"></div>
                </el-col>
                <el-col :span="12">
                    <h4>学历薪资对比</h4>
                    <div ref="educationSalaryChart" style="height: 300px"></div>
                </el-col>
            </el-row>
        </el-card>

        <!-- 职级分布分析 -->
        <el-card>
            <template #header>
                <span>职级分布分析</span>
            </template>
            <el-row :gutter="20">
                <el-col :span="12">
                    <h4>职级人数分布</h4>
                    <div ref="levelChart" style="height: 300px"></div>
                </el-col>
                <el-col :span="12">
                    <h4>职级薪资对比</h4>
                    <div ref="levelSalaryChart" style="height: 300px"></div>
                </el-col>
            </el-row>
        </el-card>
    </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { getDepartmentEfficiency, getOrganizationStructure, getOrganizationHealth } from '@/api/analysis'
import * as echarts from 'echarts'

const router = useRouter()

const deptEfficiency = ref([])
const orgStructure = ref({})
const orgHealth = ref({})
const deptChart = ref(null)
const posChart = ref(null)
const salaryChart = ref(null)
const employeeChart = ref(null)
const salaryRangeChart = ref(null)
const educationSalaryChart = ref(null)
const levelChart = ref(null)
const levelSalaryChart = ref(null)

const healthRate = computed(() => {
    return Math.round((orgHealth.value.healthScore || 0) / 20)
})

onMounted(async () => {
    await loadData()
    initCharts()
})

async function loadData() {
    try {
        const [deptRes, structRes, healthRes] = await Promise.all([
            getDepartmentEfficiency(),
            getOrganizationStructure(),
            getOrganizationHealth()
        ])
        
        deptEfficiency.value = deptRes.data
        orgStructure.value = structRes.data
        orgHealth.value = healthRes.data
    } catch (error) {
        console.error('加载数据失败:', error)
    }
}

function initCharts() {
    // 部门分布图
    const deptChartInstance = echarts.init(deptChart.value)
    const deptData = orgStructure.value.departmentStats || []
    deptChartInstance.setOption({
        tooltip: { trigger: 'item' },
        legend: { orient: 'vertical', left: 'left' },
        series: [{
            type: 'pie',
            radius: '50%',
            data: deptData.map(item => ({
                name: item.department,
                value: item.count
            }))
        }]
    })

    // 岗位分布图
    const posChartInstance = echarts.init(posChart.value)
    const posData = orgStructure.value.positionStats || []
    posChartInstance.setOption({
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'category', data: posData.map(item => item.position) },
        yAxis: { type: 'value' },
        series: [{
            type: 'bar',
            data: posData.map(item => item.count),
            itemStyle: { color: '#409EFF' }
        }]
    })

    // 部门薪资对比图
    if (salaryChart.value) {
        const salaryChartInstance = echarts.init(salaryChart.value)
        const salaryData = deptEfficiency.value || []
        salaryChartInstance.setOption({
            tooltip: { trigger: 'axis' },
            xAxis: { type: 'category', data: salaryData.map(item => item.department) },
            yAxis: { type: 'value', name: '薪资(元)' },
            series: [{
                type: 'bar',
                data: salaryData.map(item => item.avg_salary || 0),
                itemStyle: { color: '#67C23A' }
            }]
        })
    }

    // 部门人数对比图
    if (employeeChart.value) {
        const employeeChartInstance = echarts.init(employeeChart.value)
        const employeeData = deptEfficiency.value || []
        employeeChartInstance.setOption({
            tooltip: { trigger: 'axis' },
            xAxis: { type: 'category', data: employeeData.map(item => item.department) },
            yAxis: { type: 'value', name: '人数' },
            series: [{
                type: 'bar',
                data: employeeData.map(item => item.emp_count || 0),
                itemStyle: { color: '#E6A23C' }
            }]
        })
    }

    // 薪资区间分布图
    if (salaryRangeChart.value) {
        const salaryRangeChartInstance = echarts.init(salaryRangeChart.value)
        const allEmployees = orgStructure.value.allEmployees || []
        const salaryRanges = {
            '5000以下': 0,
            '5000-10000': 0,
            '10000-15000': 0,
            '15000-20000': 0,
            '20000-30000': 0,
            '30000以上': 0
        }
        allEmployees.forEach(emp => {
            const salary = emp.salary || 0
            if (salary < 5000) salaryRanges['5000以下']++
            else if (salary < 10000) salaryRanges['5000-10000']++
            else if (salary < 15000) salaryRanges['10000-15000']++
            else if (salary < 20000) salaryRanges['15000-20000']++
            else if (salary < 30000) salaryRanges['20000-30000']++
            else salaryRanges['30000以上']++
        })
        salaryRangeChartInstance.setOption({
            tooltip: { trigger: 'axis' },
            xAxis: { type: 'category', data: Object.keys(salaryRanges) },
            yAxis: { type: 'value', name: '人数' },
            series: [{
                type: 'bar',
                data: Object.values(salaryRanges),
                itemStyle: { color: '#409EFF' }
            }]
        })
    }

    // 学历薪资对比图
    if (educationSalaryChart.value) {
        const educationSalaryChartInstance = echarts.init(educationSalaryChart.value)
        const allEmployees = orgStructure.value.allEmployees || []
        const educationSalary = {}
        allEmployees.forEach(emp => {
            const edu = emp.education || '其他'
            const salary = emp.salary || 0
            if (!educationSalary[edu]) {
                educationSalary[edu] = { total: 0, count: 0 }
            }
            educationSalary[edu].total += salary
            educationSalary[edu].count++
        })
        const educationData = Object.keys(educationSalary).map(edu => ({
            education: edu,
            avgSalary: educationSalary[edu].total / educationSalary[edu].count
        }))
        educationSalaryChartInstance.setOption({
            tooltip: { trigger: 'axis' },
            xAxis: { type: 'category', data: educationData.map(item => item.education) },
            yAxis: { type: 'value', name: '平均薪资(元)' },
            series: [{
                type: 'bar',
                data: educationData.map(item => item.avgSalary),
                itemStyle: { color: '#909399' }
            }]
        })
    }

    // 职级人数分布图
    if (levelChart.value) {
        const levelChartInstance = echarts.init(levelChart.value)
        const allEmployees = orgStructure.value.allEmployees || []
        const levelStats = {}
        allEmployees.forEach(emp => {
            const level = emp.position || '其他'
            levelStats[level] = (levelStats[level] || 0) + 1
        })
        const levelData = Object.keys(levelStats).map(level => ({
            level: level,
            count: levelStats[level]
        })).sort((a, b) => b.count - a.count).slice(0, 10)
        levelChartInstance.setOption({
            tooltip: { trigger: 'axis' },
            xAxis: { type: 'category', data: levelData.map(item => item.level) },
            yAxis: { type: 'value', name: '人数' },
            series: [{
                type: 'bar',
                data: levelData.map(item => item.count),
                itemStyle: { color: '#F56C6C' }
            }]
        })
    }

    // 职级薪资对比图
    if (levelSalaryChart.value) {
        const levelSalaryChartInstance = echarts.init(levelSalaryChart.value)
        const allEmployees = orgStructure.value.allEmployees || []
        const levelSalary = {}
        allEmployees.forEach(emp => {
            const level = emp.position || '其他'
            const salary = emp.salary || 0
            if (!levelSalary[level]) {
                levelSalary[level] = { total: 0, count: 0 }
            }
            levelSalary[level].total += salary
            levelSalary[level].count++
        })
        const levelData = Object.keys(levelSalary).map(level => ({
            level: level,
            avgSalary: levelSalary[level].total / levelSalary[level].count
        })).sort((a, b) => b.avgSalary - a.avgSalary).slice(0, 10)
        levelSalaryChartInstance.setOption({
            tooltip: { trigger: 'axis' },
            xAxis: { type: 'category', data: levelData.map(item => item.level) },
            yAxis: { type: 'value', name: '平均薪资(元)' },
            series: [{
                type: 'bar',
                data: levelData.map(item => item.avgSalary),
                itemStyle: { color: '#67C23A' }
            }]
        })
    }
}

function calculateEfficiency(row) {
    const activeRate = row.emp_count > 0 ? (row.active_count / row.emp_count) * 100 : 0
    return Math.round(activeRate)
}

function getEfficiencyColor(percentage) {
    if (percentage >= 80) return '#67C23A'
    if (percentage >= 60) return '#E6A23C'
    return '#F56C6C'
}

function goBack() {
    router.push('/analysis/dashboard')
}
</script>

<style scoped>
.org-efficiency {
    padding: 20px;
}

.health-item {
    text-align: center;
    padding: 20px;
}

.health-label {
    font-size: 14px;
    color: #666;
    margin-bottom: 10px;
}

.health-value {
    font-size: 28px;
    font-weight: bold;
    color: #333;
    margin-bottom: 10px;
}

h4 {
    margin-bottom: 15px;
    color: #333;
}
</style>
