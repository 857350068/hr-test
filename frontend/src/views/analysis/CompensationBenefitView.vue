<template>
  <div class="analysis-page">
    <div class="page-header">
      <h2 class="page-title">薪酬福利分析</h2>
      <el-select v-model="period" size="small" style="width: 120px" @change="load">
        <el-option label="202601" value="202601" />
        <el-option label="202602" value="202602" />
      </el-select>
    </div>

    <el-row :gutter="16" class="metrics-row">
      <el-col :span="8"><el-card><div class="metric-label">平均薪酬</div><div class="metric-value">{{ metrics.avgSalary || '-' }}</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="metric-label">福利覆盖率</div><div class="metric-value">{{ metrics.benefitCoverage || '-' }}%</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="metric-label">公平性指数</div><div class="metric-value">{{ metrics.fairnessIndex || '-' }}</div></el-card></el-col>
    </el-row>

    <el-row :gutter="16" class="charts-row">
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="薪酬结构占比"
          :data="structureData"
          chart-type="pie"
          dimension="薪酬类型"
          :period="period"
        />
      </el-col>
      <el-col :xs="24" :lg="12">
        <analysis-chart
          title="部门薪酬对比"
          :data="salaryDistributionData"
          chart-type="bar"
          dimension="部门"
          :period="period"
        />
      </el-col>
    </el-row>

    <el-card>
      <template #header>
        <div class="card-header">
          <span>薪酬分布详情</span>
          <el-button type="primary" size="small" @click="exportData">导出数据</el-button>
        </div>
      </template>
      <el-table :data="salaryDistribution" stripe>
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="avgVal" label="平均薪酬" />
        <el-table-column prop="minVal" label="最低薪酬" />
        <el-table-column prop="maxVal" label="最高薪酬" />
        <el-table-column prop="medianVal" label="中位数" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { getCompensationBenefit } from '@/api/analysis'
import AnalysisChart from '@/components/AnalysisChart.vue'

const period = ref('202601')
const metrics = ref({})
const salaryDistribution = ref([])

const structureData = computed(() => {
  return [
    { name: '基本工资', value: 60 },
    { name: '绩效奖金', value: 25 },
    { name: '津贴补贴', value: 10 },
    { name: '福利待遇', value: 5 }
  ]
})

const salaryDistributionData = computed(() => {
  return salaryDistribution.value.map(item => ({
    name: item.deptName,
    value: item.avgVal
  }))
})

const load = async () => {
  try {
    const res = await getCompensationBenefit({ period: period.value })
    if (res.data) {
      metrics.value = res.data.metrics || {}
      salaryDistribution.value = res.data.salaryDistribution || []
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
