<template>
  <div class="analysis-page">
    <div class="page-header">
      <h2 class="page-title">人才发展预测</h2>
      <el-select v-model="period" size="small" style="width: 120px" @change="load">
        <el-option label="202601" value="202601" />
        <el-option label="202602" value="202602" />
      </el-select>
    </div>

    <el-row :gutter="16" class="metrics-row">
      <el-col :span="6"><el-card><div class="metric-label">需求增长</div><div class="metric-value">{{ metrics.demandGrowth || '-' }}%</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">人才缺口</div><div class="metric-value">{{ metrics.talentGap || '-' }}人</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">高潜人才数</div><div class="metric-value">{{ metrics.highPotentialCount || '-' }}</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">关键岗位风险</div><div class="metric-value">{{ metrics.keyPositionRisk || '-' }}</div></el-card></el-col>
    </el-row>

    <el-row :gutter="16" class="charts-row">
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="人才需求预测"
          :data="demandData"
          chart-type="line"
          dimension="未来周期"
          :period="period"
        />
      </el-col>
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="人才缺口分布"
          :data="gapData"
          chart-type="bar"
          dimension="部门"
          :period="period"
        />
      </el-col>
    </el-row>

    <el-card>
      <template #header>
        <div class="card-header">
          <span>人才缺口详情</span>
          <el-button type="primary" size="small" @click="exportData">导出数据</el-button>
        </div>
      </template>
      <el-table :data="gapList" stripe>
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="job" label="岗位" />
        <el-table-column prop="current" label="现有人数" />
        <el-table-column prop="demand" label="需求人数" />
        <el-table-column prop="gap" label="缺口数" />
        <el-table-column prop="priority" label="优先级">
          <template #default="{ row }">
            <el-tag :type="getPriorityType(row.priority)">{{ row.priority }}</el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { getTalentDevelopment } from '@/api/analysis'
import AnalysisChart from '@/components/AnalysisChart.vue'

const period = ref('202601')
const metrics = ref({})
const gapList = ref([])

const demandData = computed(() => {
  return [
    { name: 'Q1', value: 120 },
    { name: 'Q2', value: 135 },
    { name: 'Q3', value: 150 },
    { name: 'Q4', value: 165 }
  ]
})

const gapData = computed(() => {
  const deptMap = {}
  gapList.value.forEach(item => {
    if (!deptMap[item.deptName]) {
      deptMap[item.deptName] = 0
    }
    deptMap[item.deptName] += item.gap
  })
  return Object.entries(deptMap).map(([name, value]) => ({ name, value }))
})

const getPriorityType = (priority) => {
  const typeMap = {
    '高': 'danger',
    '中': 'warning',
    '低': 'info'
  }
  return typeMap[priority] || 'info'
}

const load = async () => {
  try {
    const res = await getTalentDevelopment({ period: period.value })
    if (res.data) {
      metrics.value = res.data.metrics || {}
      gapList.value = res.data.gapList || []
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
