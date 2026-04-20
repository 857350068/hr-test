<template>
  <div class="page">
    <h2>我的收藏</h2>
    <el-card>
      <el-table :data="tableData" border>
        <el-table-column type="index" width="60" />
        <el-table-column prop="favoriteType" label="类型" width="120" />
        <el-table-column prop="title" label="标题" min-width="200" />
        <el-table-column prop="targetKey" label="标识" width="180" />
        <el-table-column prop="content" label="备注" min-width="220" />
        <el-table-column prop="createTime" label="收藏时间" width="180" />
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button type="danger" size="small" @click="handleDelete(row.favoriteId)">取消</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { deleteFavorite, getFavoriteList } from '@/api/favorite'

const tableData = ref([])

async function loadData() {
  const res = await getFavoriteList()
  tableData.value = res.data || []
}

async function handleDelete(id) {
  await deleteFavorite(id)
  ElMessage.success('已取消收藏')
  await loadData()
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.page { padding: 20px; }
h2 { margin-bottom: 20px; }
</style>
