<template>
  <div class="analysis-page">
    <div class="page-header">
      <h2 class="page-title">员工流失预警</h2>
      <el-select v-model="period" size="small" style="width: 120px" @change="load">
        <el-option label="202601" value="202601" />
        <el-option label="202602" value="202602" />
      </el-select>
    </div>

    <el-row :gutter="16" class="metrics-row">
      <el-col :span="8"><el-card><div class="metric-label">流失率</div><div class="metric-value">{{ metrics.turnoverRate || '-' }}%</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="metric-label">高风险人数</div><div class="metric-value">{{ metrics.highRiskCount || '-' }}</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="metric-label">平均司龄(年)</div><div class="metric-value">{{ metrics.avgTenure || '-' }}</div></el-card></el-col>
    </el-row>

    <el-row :gutter="16" class="charts-row">
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="流失率趋势"
          :data="trendData"
          chart-type="line"
          dimension="时间周期"
          :period="period"
        />
      </el-col>
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="部门流失风险分布"
          :data="departmentData"
          chart-type="bar"
          dimension="部门"
          :period="period"
        />
      </el-col>
    </el-row>

    <el-card>
      <template #header>
        <div class="card-header">
          <span>高风险员工列表</span>
          <el-button type="primary" size="small" @click="exportData">导出数据</el-button>
        </div>
      </template>
      <el-table :data="highRiskList" stripe>
        <el-table-column prop="employeeNo" label="工号" />
        <el-table-column prop="name" label="姓名" />
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="job" label="岗位" />
        <el-table-column prop="riskScore" label="风险分">
          <template #default="{ row }">
            <el-tag :type="getRiskType(row.riskScore)">{{ row.riskScore }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="tenure" label="司龄(年)" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { getEmployeeTurnover } from '@/api/analysis'
import AnalysisChart from '@/components/AnalysisChart.vue'

const period = ref('202601')
const metrics = ref({})
const highRiskList = ref([])

const trendData = computed(() => {
  return [
    { name: '1月', value: 5.2 },
    { name: '2月', value: 4.8 },
    { name: '3月', value: 5.5 },
    { name: '4月', value: 4.9 },
    { name: '5月', value: 5.1 },
    { name: '6月', value: 4.7 }
  ]
})

const departmentData = computed(() => {
  const deptMap = {}
  highRiskList.value.forEach(item => {
    if (!deptMap[item.deptName]) {
      deptMap[item.deptName] = 0
    }
    deptMap[item.deptName]++
  })
  return Object.entries(deptMap).map(([name, value]) => ({ name, value }))
})

const getRiskType = (score) => {
  if (score >= 80) return 'danger'
  if (score >= 60) return 'warning'
  return 'info'
}

const load = async () => {
  try {
    const res = await getEmployeeTurnover({ period: period.value })
    if (res.data) {
      metrics.value = res.data.metrics || {}
      highRiskList.value = res.data.highRiskList || []
    }
  } catch (e) {}
}

const exportData = () => {
  console.log('导出数据功能待实现')
}

onMounted(load)
</script>

<style scoped>
.metrics-row { margin-bottom: 16px; }
.charts-row { margin-bottom: 16px; }
.metric-label { font-size: 12px; color: #909399; }
.metric-value { font-size: 24px; font-weight: bold; margin-top: 8px; }
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
