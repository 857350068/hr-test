<template>
  <div class="analysis-page">
    <div class="page-header">
      <h2 class="page-title">绩效管理体系</h2>
      <el-select v-model="period" size="small" style="width: 120px" @change="load">
        <el-option label="202601" value="202601" />
        <el-option label="202602" value="202602" />
      </el-select>
    </div>

    <el-row :gutter="16" class="metrics-row">
      <el-col :span="8"><el-card><div class="metric-label">平均绩效得分</div><div class="metric-value">{{ metrics.avgScore || '-' }}</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="metric-label">完成率</div><div class="metric-value">{{ metrics.completionRate || '-' }}%</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="metric-label">改进率</div><div class="metric-value">{{ metrics.improvementRate || '-' }}%</div></el-card></el-col>
    </el-row>

    <el-row :gutter="16" class="charts-row">
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="绩效分布"
          :data="distributionData"
          chart-type="bar"
          dimension="绩效等级"
          :period="period"
        />
      </el-col>
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="部门绩效对比"
          :data="departmentData"
          chart-type="line"
          dimension="部门"
          :period="period"
        />
      </el-col>
    </el-row>

    <el-card>
      <template #header>
        <div class="card-header">
          <span>部门绩效详情</span>
          <el-button type="primary" size="small" @click="exportData">导出数据</el-button>
        </div>
      </template>
      <el-table :data="departmentComparison" stripe>
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="avgScore" label="平均得分" />
        <el-table-column prop="completionRate" label="完成率" />
        <el-table-column prop="improvementRate" label="改进率" />
        <el-table-column prop="totalEmployees" label="员工数" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { getPerformanceManagement } from '@/api/analysis'
import AnalysisChart from '@/components/AnalysisChart.vue'

const period = ref('202601')
const metrics = ref({})
const departmentComparison = ref([])

const distributionData = computed(() => {
  return [
    { name: '优秀(90-100)', value: 15 },
    { name: '良好(80-89)', value: 35 },
    { name: '合格(70-79)', value: 40 },
    { name: '待改进(<70)', value: 10 }
  ]
})

const departmentData = computed(() => {
  return departmentComparison.value.map(item => ({
    name: item.deptName,
    value: item.avgScore
  }))
})

const load = async () => {
  try {
    const res = await getPerformanceManagement({ period: period.value })
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
