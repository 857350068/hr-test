<template>
  <div class="analysis-page">
    <div class="page-header">
      <h2 class="page-title">人力成本优化</h2>
      <el-select v-model="period" size="small" style="width: 120px" @change="load">
        <el-option label="202601" value="202601" />
        <el-option label="202602" value="202602" />
      </el-select>
    </div>

    <el-row :gutter="16" class="metrics-row">
      <el-col :span="6"><el-card><div class="metric-label">总人力成本</div><div class="metric-value">{{ metrics.totalCost || '-' }}</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">人均成本</div><div class="metric-value">{{ metrics.perCapitaCost || '-' }}</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">成本占比</div><div class="metric-value">{{ metrics.costRatio || '-' }}%</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">成本效益指数</div><div class="metric-value">{{ metrics.costEffectiveness || '-' }}</div></el-card></el-col>
    </el-row>

    <el-row :gutter="16" class="charts-row">
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="成本构成分析"
          :data="structureData"
          chart-type="pie"
          dimension="成本类型"
          :period="period"
        />
      </el-col>
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="部门成本对比"
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
          <span>部门成本详情</span>
          <el-button type="primary" size="small" @click="exportData">导出数据</el-button>
        </div>
      </template>
      <el-table :data="departmentCost" stripe>
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="total" label="总成本" />
        <el-table-column prop="perCapita" label="人均成本" />
        <el-table-column prop="ratio" label="成本占比" />
        <el-table-column prop="effectiveness" label="效益指数" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { getHumanCostOptimization } from '@/api/analysis'
import AnalysisChart from '@/components/AnalysisChart.vue'

const period = ref('202601')
const metrics = ref({})
const departmentCost = ref([])

const structureData = computed(() => {
  return [
    { name: '薪酬成本', value: 70 },
    { name: '福利成本', value: 15 },
    { name: '培训成本', value: 8 },
    { name: '其他成本', value: 7 }
  ]
})

const departmentData = computed(() => {
  return departmentCost.value.map(item => ({
    name: item.deptName,
    value: item.total
  }))
})

const load = async () => {
  try {
    const res = await getHumanCostOptimization({ period: period.value })
    if (res.data) {
      metrics.value = res.data.metrics || {}
      departmentCost.value = res.data.departmentCost || []
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
