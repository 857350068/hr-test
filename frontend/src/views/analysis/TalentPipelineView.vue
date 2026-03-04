<template>
  <div class="analysis-page">
    <div class="page-header">
      <h2 class="page-title">人才梯队建设</h2>
      <el-select v-model="period" size="small" style="width: 120px" @change="load">
        <el-option label="202601" value="202601" />
        <el-option label="202602" value="202602" />
      </el-select>
    </div>

    <el-row :gutter="16" class="metrics-row">
      <el-col :span="6"><el-card><div class="metric-label">人才储备率</div><div class="metric-value">{{ metrics.talentReserveRate || '-' }}%</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">核心人才占比</div><div class="metric-value">{{ metrics.coreTalentRatio || '-' }}%</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">内部晋升率</div><div class="metric-value">{{ metrics.internalPromotionRate || '-' }}%</div></el-card></el-col>
      <el-col :span="6"><el-card><div class="metric-label">培训覆盖率</div><div class="metric-value">{{ metrics.trainingCoverage || '-' }}%</div></el-card></el-col>
    </el-row>

    <el-row :gutter="16" class="charts-row">
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="人才梯队结构"
          :data="pipelineData"
          chart-type="ring"
          dimension="人才层级"
          :period="period"
        />
      </el-col>
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="各部门人才储备对比"
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
          <span>高潜人才名单</span>
          <el-button type="primary" size="small" @click="exportData">导出数据</el-button>
        </div>
      </template>
      <el-table :data="highPotential" stripe>
        <el-table-column prop="employeeNo" label="工号" />
        <el-table-column prop="name" label="姓名" />
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="job" label="岗位" />
        <el-table-column prop="value" label="得分" />
        <el-table-column prop="potential" label="潜质等级">
          <template #default="{ row }">
            <el-tag :type="getPotentialType(row.potential)">{{ row.potential }}</el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { getTalentPipeline } from '@/api/analysis'
import AnalysisChart from '@/components/AnalysisChart.vue'

const period = ref('202601')
const metrics = ref({})
const highPotential = ref([])

const pipelineData = computed(() => {
  return [
    { name: '核心人才', value: metrics.value.coreTalentRatio || 0 },
    { name: '骨干人才', value: metrics.value.talentReserveRate || 0 },
    { name: '后备人才', value: metrics.value.internalPromotionRate || 0 },
    { name: '待培养', value: metrics.value.trainingCoverage || 0 }
  ]
})

const departmentData = computed(() => {
  const deptMap = {}
  highPotential.value.forEach(item => {
    if (!deptMap[item.deptName]) {
      deptMap[item.deptName] = 0
    }
    deptMap[item.deptName]++
  })
  return Object.entries(deptMap).map(([name, value]) => ({ name, value }))
})

const getPotentialType = (potential) => {
  const typeMap = {
    '高': 'danger',
    '中': 'warning',
    '低': 'info'
  }
  return typeMap[potential] || 'info'
}

const load = async () => {
  try {
    const res = await getTalentPipeline({ period: period.value })
    if (res.data) {
      metrics.value = res.data.metrics || {}
      highPotential.value = res.data.highPotential || []
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
