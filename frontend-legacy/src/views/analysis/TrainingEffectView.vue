<template>
  <div class="analysis-page">
    <div class="page-header">
      <h2 class="page-title">培训效果评估</h2>
      <el-select v-model="period" size="small" style="width: 120px" @change="load">
        <el-option label="202601" value="202601" />
        <el-option label="202602" value="202602" />
      </el-select>
    </div>

    <el-row :gutter="16" class="metrics-row">
      <el-col :span="8"><el-card><div class="metric-label">培训覆盖率</div><div class="metric-value">{{ metrics.coverage || '-' }}%</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="metric-label">平均得分</div><div class="metric-value">{{ metrics.avgScore || '-' }}</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="metric-label">满意度</div><div class="metric-value">{{ metrics.satisfaction || '-' }}%</div></el-card></el-col>
    </el-row>

    <el-row :gutter="16" class="charts-row">
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="培训类型分布"
          :data="typeData"
          chart-type="ring"
          dimension="培训类型"
          :period="period"
        />
      </el-col>
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="部门培训参与率"
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
          <span>部门培训统计</span>
          <el-button type="primary" size="small" @click="exportData">导出数据</el-button>
        </div>
      </template>
      <el-table :data="courseList" stripe>
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="count" label="参训人数" />
        <el-table-column prop="avgScore" label="平均得分" />
        <el-table-column prop="completionRate" label="完成率" />
        <el-table-column prop="satisfaction" label="满意度" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { getTrainingEffect } from '@/api/analysis'
import AnalysisChart from '@/components/AnalysisChart.vue'

const period = ref('202601')
const metrics = ref({})
const courseList = ref([])

const typeData = computed(() => {
  return [
    { name: '技能培训', value: 40 },
    { name: '管理培训', value: 25 },
    { name: '安全培训', value: 20 },
    { name: '新员工培训', value: 15 }
  ]
})

const departmentData = computed(() => {
  return courseList.value.map(item => ({
    name: item.deptName,
    value: item.count
  }))
})

const load = async () => {
  try {
    const res = await getTrainingEffect({ period: period.value })
    if (res.data) {
      metrics.value = res.data.metrics || {}
      courseList.value = res.data.courseList || []
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
