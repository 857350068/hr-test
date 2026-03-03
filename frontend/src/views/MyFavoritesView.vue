<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">我的收藏</h2>
    </div>
    <el-card>
      <el-table :data="list" stripe>
        <el-table-column prop="favType" label="类型" width="120" />
        <el-table-column prop="title" label="标题" />
        <el-table-column prop="createTime" label="收藏时间" width="180">
          <template #default="{ row }">{{ formatTime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="100">
          <template #default="{ row }">
            <el-button type="danger" link @click="remove(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getFavoriteList, deleteFavorite } from '@/api/favorite'
import { ElMessage } from 'element-plus'

const list = ref([])

const formatTime = (t) => {
  if (!t) return '-'
  const d = new Date(t)
  return d.toLocaleString('zh-CN')
}

const load = async () => {
  try {
    const res = await getFavoriteList()
    list.value = res.data || []
  } catch (e) {}
}

const remove = async (id) => {
  try {
    await deleteFavorite(id)
    ElMessage.success('已取消收藏')
    load()
  } catch (e) {}
}

onMounted(load)
</script>
