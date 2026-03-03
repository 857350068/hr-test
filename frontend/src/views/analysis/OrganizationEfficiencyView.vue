<template>
  <div class="analysis-page">
    <div class="page-header">
      <h2 class="page-title">组织效能分析</h2>
      <el-select v-model="period" size="small" style="width: 120px" @change="load">
        <el-option label="202601" value="202601" />
        <el-option label="202602" value="202602" />
      </el-select>
    </div>
    <el-row :gutter="16">
      <el-col :span="6">
        <el-card><div class="metric-label">人均产出</div><div class="metric-value">{{ metrics.humanOutput || '-' }}</div></el-card>
      </el-col>
      <el-col :span="6">
        <el-card><div class="metric-label">协作效率</div><div class="metric-value">{{ metrics.collaborationEfficiency || '-' }}</div></el-card>
      </el-col>
      <el-col :span="6">
        <el-card><div class="metric-label">流程效率</div><div class="metric-value">{{ metrics.processEfficiency || '-' }}</div></el-card>
      </el-col>
      <el-col :span="6">
        <el-card><div class="metric-label">资源利用率</div><div class="metric-value">{{ metrics.resourceUtilization || '-' }}</div></el-card>
      </el-col>
    </el-row>
    <el-card style="margin-top: 16px">
      <template #header>部门效能对比</template>
      <el-table :data="departmentComparison" stripe>
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="avgScore" label="平均得分" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getOrganizationEfficiency } from '@/api/analysis'

const period = ref('202601')
const metrics = ref({})
const departmentComparison = ref([])

const load = async () => {
  try {
    const res = await getOrganizationEfficiency({ period: period.value })
    if (res.data) {
      metrics.value = res.data.metrics || {}
      departmentComparison.value = res.data.departmentComparison || []
    }
  } catch (e) {}
}

onMounted(load)
</script>

<style scoped>
.metric-label { font-size: 12px; color: #909399; }
.metric-value { font-size: 24px; font-weight: bold; margin-top: 8px; }
</style>
