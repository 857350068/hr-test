<template>
  <div class="analysis-page">
    <div class="page-header">
      <h2 class="page-title">员工流失预警</h2>
      <el-select v-model="period" size="small" style="width: 120px" @change="load">
        <el-option label="202601" value="202601" />
        <el-option label="202602" value="202602" />
      </el-select>
    </div>
    <el-row :gutter="16">
      <el-col :span="8"><el-card><div class="metric-label">流失率</div><div class="metric-value">{{ metrics.turnoverRate || '-' }}%</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="metric-label">高风险人数</div><div class="metric-value">{{ metrics.highRiskCount || '-' }}</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="metric-label">平均司龄(年)</div><div class="metric-value">{{ metrics.avgTenure || '-' }}</div></el-card></el-col>
    </el-row>
    <el-card style="margin-top: 16px">
      <template #header>高风险员工列表</template>
      <el-table :data="highRiskList" stripe>
        <el-table-column prop="employeeNo" label="工号" />
        <el-table-column prop="name" label="姓名" />
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="job" label="岗位" />
        <el-table-column prop="riskScore" label="风险分" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getEmployeeTurnover } from '@/api/analysis'

const period = ref('202601')
const metrics = ref({})
const highRiskList = ref([])

const load = async () => {
  try {
    const res = await getEmployeeTurnover({ period: period.value })
    if (res.data) {
      metrics.value = res.data.metrics || {}
      highRiskList.value = res.data.highRiskList || []
    }
  } catch (e) {}
}

onMounted(load)
</script>

<style scoped>
.metric-label { font-size: 12px; color: #909399; }
.metric-value { font-size: 24px; font-weight: bold; margin-top: 8px; }
</style>
