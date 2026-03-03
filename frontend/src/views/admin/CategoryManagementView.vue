<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">数据分类管理</h2>
    </div>
    <el-card>
      <el-table :data="list" stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="分类名称" />
        <el-table-column prop="parentId" label="父ID" width="80" />
        <el-table-column prop="sortOrder" label="排序" width="80" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getCategoryList } from '@/api/category'

const list = ref([])

onMounted(async () => {
  try {
    const res = await getCategoryList()
    list.value = res.data || []
  } catch (e) {}
})
</script>
