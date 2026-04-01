<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">数据同步</h2>
      <p class="page-description">将 MySQL 基础数据同步至 Hive</p>
    </div>
    <el-card>
      <el-button type="primary" :loading="syncing" @click="triggerSync">手动触发同步</el-button>
      <el-divider />
      <div class="card-header mb-4">
        <span class="card-title">同步日志</span>
      </div>
      <el-table :data="logs" stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="startTime" label="开始时间" width="180">
          <template #default="{ row }">{{ formatTime(row.startTime) }}</template>
        </el-table-column>
        <el-table-column prop="endTime" label="结束时间" width="180">
          <template #default="{ row }">{{ formatTime(row.endTime) }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'SUCCESS' ? 'success' : 'danger'">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="recordsProcessed" label="处理记录数" width="120" />
        <el-table-column prop="details" label="详情" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { triggerSync as triggerSyncApi, getSyncLogs } from '@/api/admin'
import { ElMessage } from 'element-plus'

const syncing = ref(false)
const logs = ref([])

const formatTime = (t) => {
  if (!t) return '-'
  return new Date(t).toLocaleString('zh-CN')
}

const loadLogs = async () => {
  try {
    const res = await getSyncLogs(20)
    logs.value = res.data || []
  } catch (e) {}
}

const triggerSync = async () => {
  syncing.value = true
  try {
    const res = await triggerSyncApi()
    ElMessage.success(res.data?.details || '同步任务已触发')
    loadLogs()
  } catch (e) {}
  finally {
    syncing.value = false
  }
}

onMounted(loadLogs)
</script>
