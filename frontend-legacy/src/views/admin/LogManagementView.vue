<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">操作日志</h2>
    </div>
    <el-card>
      <el-form inline class="mb-4">
        <el-form-item label="用户名">
          <el-input v-model="query.username" placeholder="用户名" clearable style="width: 120px" />
        </el-form-item>
        <el-form-item label="操作类型">
          <el-input v-model="query.operation" placeholder="操作类型" clearable style="width: 150px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" width="100" />
        <el-table-column prop="operation" label="操作类型" width="120" />
        <el-table-column prop="method" label="请求方法" width="200" show-overflow-tooltip />
        <el-table-column prop="ip" label="IP地址" width="130" />
        <el-table-column prop="createTime" label="操作时间" width="180">
          <template #default="{ row }">{{ formatTime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button type="danger" link @click="handleDelete(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :total="page.total"
        layout="total, prev, pager, next"
        @current-change="load"
        style="margin-top: 16px"
      />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getLogPage, deleteLog } from '@/api/log'
import { ElMessage, ElMessageBox } from 'element-plus'

const query = reactive({ username: '', operation: '' })
const page = reactive({ current: 1, size: 10, total: 0 })
const tableData = ref([])
const loading = ref(false)

const formatTime = (t) => {
  if (!t) return '-'
  return new Date(t).toLocaleString('zh-CN')
}

const load = async () => {
  loading.value = true
  try {
    const res = await getLogPage({
      current: page.current,
      size: page.size,
      username: query.username,
      operation: query.operation
    })
    tableData.value = res.data.records || []
    page.total = res.data.total || 0
  } catch (e) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

const resetQuery = () => {
  query.username = ''
  query.operation = ''
  page.current = 1
  load()
}

const handleDelete = async (id) => {
  try {
    await ElMessageBox.confirm('确定删除该日志吗？', '提示', { type: 'warning' })
    await deleteLog(id)
    ElMessage.success('删除成功')
    load()
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('删除失败')
    }
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

.mb-4 {
  margin-bottom: 16px;
}
</style>
