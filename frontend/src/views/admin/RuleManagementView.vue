<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">预警规则管理</h2>
    </div>
    <el-card>
      <el-table :data="list" stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="ruleType" label="规则类型" width="140" />
        <el-table-column prop="threshold" label="阈值" width="80" />
        <el-table-column prop="description" label="描述" />
        <el-table-column prop="effective" label="生效" width="80">
          <template #default="{ row }">{{ row.effective === 1 ? '是' : '否' }}</template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getRuleList } from '@/api/rule'

const list = ref([])

onMounted(async () => {
  try {
    const res = await getRuleList()
    list.value = res.data || []
  } catch (e) {}
})
</script>
