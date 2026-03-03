<template>
  <div class="analysis-page">
    <div class="page-header">
      <h2 class="page-title">人力成本优化</h2>
      <el-select v-model="period" size="small" style="width: 120px" @change="load">
        <el-option label="202601" value="202601" />
        <el-option label="202602" value="202602" />
      </el-select>
    </div>
    <el-row :gutter="16">
      <el-col :span="6"><el-card><div class="metric-label">总人力成本</div><div class="metric-value">{{ metrics.totalCost || '-' }}</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">人均成本</div><div class="metric-value">{{ metrics.perCapitaCost || '-' }}</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">成本占比</div><div class="metric-value">{{ metrics.costRatio || '-' }}%</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">成本效益指数</div><div class="metric-value">{{ metrics.costEffectiveness || '-' }}</div></el-card></el-col>
    </el-row>
    <el-card style="margin-top: 16px">
      <template #header>部门成本</template>
      <el-table :data="departmentCost" stripe>
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="total" label="总成本" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getHumanCostOptimization } from '@/api/analysis'

const period = ref('202601')
const metrics = ref({})
const departmentCost = ref([])

const load = async () => {
  try {
    const res = await getHumanCostOptimization({ period: period.value })
    if (res.data) {
      metrics.value = res.data.metrics || {}
      departmentCost.value = res.data.departmentCost || []
    }
  } catch (e) {}
}

onMounted(load)
</script>

<style scoped>
.metric-label { font-size: 12px; color: #909399; }
.metric-value { font-size: 24px; font-weight: bold; margin-top: 8px; }
</style>
