<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">我的收藏</h2>
    </div>
    <el-card>
      <!-- 查询表单 -->
      <el-form :inline="true" :model="query" class="query-form">
        <el-form-item label="收藏类型">
          <el-select v-model="query.favType" placeholder="请选择" clearable>
            <el-option label="报表" value="REPORT" />
            <el-option label="分析" value="ANALYSIS" />
            <el-option label="仪表盘" value="DASHBOARD" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 数据表格 -->
      <el-table :data="list" stripe v-loading="loading">
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

      <!-- 分页组件 -->
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :page-sizes="[10, 20, 50, 100]"
        :total="page.total"
        layout="total, sizes, prev, pager, next, jumper"
        @current-change="load"
        @size-change="load"
        style="margin-top: 20px; justify-content: flex-end;"
      />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getFavoriteList, getFavoritePage, deleteFavorite } from '@/api/favorite'
import { ElMessage } from 'element-plus'

const list = ref([])
const loading = ref(false)

// 分页状态
const page = reactive({
  current: 1,
  size: 10,
  total: 0
})

// 查询条件
const query = reactive({
  favType: ''
})

const formatTime = (t) => {
  if (!t) return '-'
  const d = new Date(t)
  return d.toLocaleString('zh-CN')
}

const load = async () => {
  loading.value = true
  try {
    const res = await getFavoritePage({
      current: page.current,
      size: page.size,
      favType: query.favType || undefined
    })
    list.value = res.data.records || []
    page.total = res.data.total || 0
  } catch (e) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  query.favType = ''
  page.current = 1
  load()
}

const remove = async (id) => {
  try {
    await deleteFavorite(id)
    ElMessage.success('已取消收藏')
    load()
  } catch (e) {
    ElMessage.error('取消收藏失败')
  }
}

onMounted(load)
</script>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-title {
  margin: 0;
}

.query-form {
  margin-bottom: 20px;
}
</style>
