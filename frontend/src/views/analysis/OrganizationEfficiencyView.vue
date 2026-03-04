<template>
  <div class="analysis-page">
    <div class="page-header">
      <h2 class="page-title">组织效能分析</h2>
      <el-select v-model="period" size="small" style="width: 120px" @change="load">
        <el-option label="202601" value="202601" />
        <el-option label="202602" value="202602" />
      </el-select>
    </div>

    <el-row :gutter="16" class="metrics-row">
      <el-col :span="6">
        <el-card><div class="metric-label">人均产出</div><div class="metric-value">{{ metrics.humanOutput || '-' }}</div></el-card>
      </el-col>
      <el-col :span="6">
        <el-card><div class="metric-label">协作效率</div><div class="metric-value">{{ metrics.collaborationEfficiency || '-' }}</div></el-card>
      </el-col>
      <el-col :span="6">
        <el-card><div class="metric-label">流程效率</div><div class="metric-value">{{ metrics.processEfficiency || '-' }}</div></el-card>
      </el-col>
      <el-col :span="6">
        <el-card><div class="metric-label">资源利用率</div><div class="metric-value">{{ metrics.resourceUtilization || '-' }}</div></el-card>
      </el-col>
    </el-row>

    <el-row :gutter="16" class="charts-row">
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="部门效能对比"
          :data="chartData"
          chart-type="bar"
          dimension="部门"
          :period="period"
        />
      </el-col>
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="效能指标趋势"
          :data="trendData"
          chart-type="line"
          dimension="时间周期"
          :period="period"
        />
      </el-col>
    </el-row>

    <el-card>
      <template #header>
        <div class="card-header">
          <span>详细数据</span>
          <el-button type="primary" size="small" @click="exportData">导出数据</el-button>
        </div>
      </template>
      <el-table :data="departmentComparison" stripe>
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="avgScore" label="平均得分" />
        <el-table-column prop="humanOutput" label="人均产出" />
        <el-table-column prop="collaborationEfficiency" label="协作效率" />
        <el-table-column prop="processEfficiency" label="流程效率" />
        <el-table-column prop="resourceUtilization" label="资源利用率" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { getOrganizationEfficiency } from '@/api/analysis'
import AnalysisChart from '@/components/AnalysisChart.vue'

const period = ref('202601')
const metrics = ref({})
const departmentComparison = ref([])

const chartData = computed(() => {
  return departmentComparison.value.map(item => ({
    name: item.deptName,
    value: item.avgScore
  }))
})

const trendData = computed(() => {
  return [
    { name: '人均产出', value: metrics.value.humanOutput || 0 },
    { name: '协作效率', value: metrics.value.collaborationEfficiency || 0 },
    { name: '流程效率', value: metrics.value.processEfficiency || 0 },
    { name: '资源利用率', value: metrics.value.resourceUtilization || 0 }
  ]
})

const load = async () => {
  try {
    const res = await getOrganizationEfficiency({ period: period.value })
    if (res.data) {
      metrics.value = res.data.metrics || {}
      departmentComparison.value = res.data.departmentComparison || []
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
