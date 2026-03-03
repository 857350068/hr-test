<template>
  <div class="analysis-page">
    <div class="page-header">
      <h2 class="page-title">人才发展预测</h2>
      <el-select v-model="period" size="small" style="width: 120px" @change="load">
        <el-option label="202601" value="202601" />
        <el-option label="202602" value="202602" />
      </el-select>
    </div>
    <el-row :gutter="16">
      <el-col :span="6"><el-card><div class="metric-label">需求增长</div><div class="metric-value">{{ metrics.demandGrowth || '-' }}%</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">人才缺口</div><div class="metric-value">{{ metrics.talentGap || '-' }}人</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">高潜人才数</div><div class="metric-value">{{ metrics.highPotentialCount || '-' }}</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">关键岗位风险</div><div class="metric-value">{{ metrics.keyPositionRisk || '-' }}</div></el-card></el-col>
    </el-row>
    <el-card style="margin-top: 16px">
      <template #header>人才缺口</template>
      <el-table :data="gapList" stripe>
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="job" label="岗位" />
        <el-table-column prop="gap" label="缺口数" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getTalentDevelopment } from '@/api/analysis'

const period = ref('202601')
const metrics = ref({})
const gapList = ref([])

const load = async () => {
  try {
    const res = await getTalentDevelopment({ period: period.value })
    if (res.data) {
      metrics.value = res.data.metrics || {}
      gapList.value = res.data.gapList || []
    }
  } catch (e) {}
}

onMounted(load)
</script>

<style scoped>
.metric-label { font-size: 12px; color: #909399; }
.metric-value { font-size: 24px; font-weight: bold; margin-top: 8px; }
</style>
