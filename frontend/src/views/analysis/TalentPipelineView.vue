<template>
  <div class="analysis-page">
    <div class="page-header">
      <h2 class="page-title">人才梯队建设</h2>
      <el-select v-model="period" size="small" style="width: 120px" @change="load">
        <el-option label="202601" value="202601" />
        <el-option label="202602" value="202602" />
      </el-select>
    </div>
    <el-row :gutter="16">
      <el-col :span="6"><el-card><div class="metric-label">人才储备率</div><div class="metric-value">{{ metrics.talentReserveRate || '-' }}%</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">核心人才占比</div><div class="metric-value">{{ metrics.coreTalentRatio || '-' }}%</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">内部晋升率</div><div class="metric-value">{{ metrics.internalPromotionRate || '-' }}%</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">培训覆盖率</div><div class="metric-value">{{ metrics.trainingCoverage || '-' }}%</div></el-card></el-col>
    </el-row>
    <el-card style="margin-top: 16px">
      <template #header>高潜人才名单</template>
      <el-table :data="highPotential" stripe>
        <el-table-column prop="employeeNo" label="工号" />
        <el-table-column prop="name" label="姓名" />
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="job" label="岗位" />
        <el-table-column prop="value" label="得分" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getTalentPipeline } from '@/api/analysis'

const period = ref('202601')
const metrics = ref({})
const highPotential = ref([])

const load = async () => {
  try {
    const res = await getTalentPipeline({ period: period.value })
    if (res.data) {
      metrics.value = res.data.metrics || {}
      highPotential.value = res.data.highPotential || []
    }
  } catch (e) {}
}

onMounted(load)
</script>

<style scoped>
.metric-label { font-size: 12px; color: #909399; }
.metric-value { font-size: 24px; font-weight: bold; margin-top: 8px; }
</style>
