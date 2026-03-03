<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">报表管理</h2>
    </div>
    <el-card>
      <el-table :data="list" stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="模板名称" />
        <el-table-column prop="category" label="分类" width="120" />
        <el-table-column prop="enabled" label="启用" width="80">
          <template #default="{ row }">{{ row.enabled === 1 ? '是' : '否' }}</template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getReportList } from '@/api/report'

const list = ref([])

onMounted(async () => {
  try {
    const res = await getReportList()
    list.value = res.data || []
  } catch (e) {}
})
</script>
