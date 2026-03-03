<template>
  <div class="analysis-page">
    <div class="page-header">
      <h2 class="page-title">培训效果评估</h2>
      <el-select v-model="period" size="small" style="width: 120px" @change="load">
        <el-option label="202601" value="202601" />
        <el-option label="202602" value="202602" />
      </el-select>
    </div>
    <el-row :gutter="16">
      <el-col :span="8"><el-card><div class="metric-label">培训覆盖率</div><div class="metric-value">{{ metrics.coverage || '-' }}%</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="metric-label">平均得分</div><div class="metric-value">{{ metrics.avgScore || '-' }}</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="metric-label">满意度</div><div class="metric-value">{{ metrics.satisfaction || '-' }}%</div></el-card></el-col>
    </el-row>
    <el-card style="margin-top: 16px">
      <template #header>部门培训统计</template>
      <el-table :data="courseList" stripe>
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="count" label="参训人数" />
        <el-table-column prop="avgScore" label="平均得分" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getTrainingEffect } from '@/api/analysis'

const period = ref('202601')
const metrics = ref({})
const courseList = ref([])

const load = async () => {
  try {
    const res = await getTrainingEffect({ period: period.value })
    if (res.data) {
      metrics.value = res.data.metrics || {}
      courseList.value = res.data.courseList || []
    }
  } catch (e) {}
}

onMounted(load)
</script>

<style scoped>
.metric-label { font-size: 12px; color: #909399; }
.metric-value { font-size: 24px; font-weight: bold; margin-top: 8px; }
</style>
