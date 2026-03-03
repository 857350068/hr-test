<template>
  <div class="analysis-page">
    <div class="page-header">
      <h2 class="page-title">薪酬福利分析</h2>
      <el-select v-model="period" size="small" style="width: 120px" @change="load">
        <el-option label="202601" value="202601" />
        <el-option label="202602" value="202602" />
      </el-select>
    </div>
    <el-row :gutter="16">
      <el-col :span="8"><el-card><div class="metric-label">平均薪酬</div><div class="metric-value">{{ metrics.avgSalary || '-' }}</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="metric-label">福利覆盖率</div><div class="metric-value">{{ metrics.benefitCoverage || '-' }}%</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="metric-label">公平性指数</div><div class="metric-value">{{ metrics.fairnessIndex || '-' }}</div></el-card></el-col>
    </el-row>
    <el-card style="margin-top: 16px">
      <template #header>薪酬分布</template>
      <el-table :data="salaryDistribution" stripe>
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="avgVal" label="平均薪酬" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getCompensationBenefit } from '@/api/analysis'

const period = ref('202601')
const metrics = ref({})
const salaryDistribution = ref([])

const load = async () => {
  try {
    const res = await getCompensationBenefit({ period: period.value })
    if (res.data) {
      metrics.value = res.data.metrics || {}
      salaryDistribution.value = res.data.salaryDistribution || []
    }
  } catch (e) {}
}

onMounted(load)
</script>

<style scoped>
.metric-label { font-size: 12px; color: #909399; }
.metric-value { font-size: 24px; font-weight: bold; margin-top: 8px; }
</style>
