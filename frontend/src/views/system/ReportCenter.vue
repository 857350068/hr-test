<template>
  <div class="page">
    <h2>报表中心</h2>
    <el-card class="mb">
      <el-row :gutter="12">
        <el-col :span="8"><el-input v-model="reportType" placeholder="输入报表类型（如 warning）" /></el-col>
        <el-col :span="8"><el-input v-model="shareTarget" placeholder="分享目标（如 manager@corp）" /></el-col>
        <el-col :span="8">
          <el-button type="primary" @click="handleExport">导出报表</el-button>
          <el-button type="warning" @click="exportPageExcel">导出页面Excel</el-button>
          <el-button type="success" @click="handleShare">分享报表</el-button>
        </el-col>
      </el-row>
    </el-card>
    <el-card class="mb">
      <el-button type="primary" @click="handleAdd">新增定时任务</el-button>
    </el-card>
    <el-card class="mb">
      <el-table :data="tableData" border>
        <el-table-column prop="taskName" label="任务名" />
        <el-table-column prop="reportType" label="报表类型" width="120" />
        <el-table-column prop="cronExpr" label="Cron" width="180" />
        <el-table-column prop="shareTarget" label="分享目标" min-width="180" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '启用' : '停用' }}</el-tag></template>
        </el-table-column>
        <el-table-column label="操作" width="180">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row.taskId)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    <el-row :gutter="20">
      <el-col :span="12">
        <el-card>
          <template #header>最近执行记录</template>
          <el-table :data="executionLogs" border size="small" max-height="280">
            <el-table-column prop="taskName" label="任务名" min-width="140" />
            <el-table-column prop="reportType" label="类型" width="100" />
            <el-table-column prop="fileName" label="文件名" min-width="160" show-overflow-tooltip />
            <el-table-column label="文件状态" width="100">
              <template #default="{ row }">
                <el-tag :type="row.fileExists ? 'success' : 'danger'">
                  {{ row.fileExists ? '存在' : '丢失' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="文件操作" width="150">
              <template #default="{ row }">
                <el-button
                  size="small"
                  type="primary"
                  text
                  :disabled="row.status !== 1 || !row.fileName || !row.fileExists"
                  @click="handleDownloadLogFile(row)"
                >
                  下载
                </el-button>
                <el-button
                  size="small"
                  type="success"
                  text
                  :disabled="row.status !== 1 || !row.fileName || !row.fileExists"
                  @click="handleOpenLogFile(row)"
                >
                  打开
                </el-button>
              </template>
            </el-table-column>
            <el-table-column label="重建" width="90">
              <template #default="{ row }">
                <el-button
                  size="small"
                  type="danger"
                  text
                  :disabled="row.status !== 1"
                  @click="handleRebuildLogFile(row)"
                >
                  重建
                </el-button>
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="80">
              <template #default="{ row }">
                <el-tag :type="row.status === 1 ? 'success' : 'danger'">{{ row.status === 1 ? '成功' : '失败' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="runTime" label="时间" width="170" />
          </el-table>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <template #header>最近分享记录</template>
          <el-table :data="shareLogs" border size="small" max-height="280">
            <el-table-column prop="reportType" label="类型" width="100" />
            <el-table-column prop="target" label="分享目标" min-width="140" />
            <el-table-column prop="shareChannel" label="渠道" width="90" />
            <el-table-column prop="status" label="状态" width="80">
              <template #default="{ row }">
                <el-tag :type="row.status === 1 ? 'success' : 'danger'">{{ row.status === 1 ? '成功' : '失败' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="shareTime" label="时间" width="170" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>
    <el-dialog v-model="dialogVisible" :title="form.taskId ? '编辑任务' : '新增任务'" width="560px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="任务名"><el-input v-model="form.taskName" /></el-form-item>
        <el-form-item label="报表类型"><el-input v-model="form.reportType" /></el-form-item>
        <el-form-item label="Cron"><el-input v-model="form.cronExpr" /></el-form-item>
        <el-form-item label="分享目标"><el-input v-model="form.shareTarget" /></el-form-item>
        <el-form-item label="状态"><el-switch v-model="form.status" :active-value="1" :inactive-value="0" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { exportMultiSheetExcel } from '@/utils/excel'
import {
  addReportTask,
  deleteReportTask,
  downloadGeneratedReportFile,
  downloadReportFile,
  getReportExecutionLogs,
  getReportShareLogs,
  getReportTaskList,
  rebuildExecutionLogFile,
  shareReport,
  updateReportTask
} from '@/api/report'

const tableData = ref([])
const executionLogs = ref([])
const shareLogs = ref([])
const reportType = ref('warning')
const shareTarget = ref('')
const dialogVisible = ref(false)
const form = reactive({ taskId: null, taskName: '', reportType: 'warning', cronExpr: '0 0 9 * * ?', shareTarget: '', status: 1 })

async function loadData() {
  const [taskRes, execRes, shareRes] = await Promise.all([
    getReportTaskList(),
    getReportExecutionLogs(),
    getReportShareLogs()
  ])
  tableData.value = taskRes.data || []
  executionLogs.value = execRes.data || []
  shareLogs.value = shareRes.data || []
}
async function handleExport() {
  const file = await downloadReportFile(reportType.value || 'warning')
  const blobUrl = window.URL.createObjectURL(file)
  const link = document.createElement('a')
  link.href = blobUrl
  link.download = `report_${reportType.value || 'warning'}.csv`
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  window.URL.revokeObjectURL(blobUrl)
  ElMessage.success('报表导出成功')
}
async function handleShare() {
  await shareReport(reportType.value || 'warning', shareTarget.value || 'default')
  ElMessage.success('分享成功')
}

async function handleDownloadLogFile(row) {
  try {
    const file = await downloadGeneratedReportFile(row.fileName, 'attachment')
    triggerBlobDownload(file, row.fileName || 'report.csv')
    ElMessage.success('文件下载成功')
  } catch (error) {
    console.error('下载执行记录文件失败:', error)
    ElMessage.error('下载失败，文件可能已不存在')
  }
}

async function handleOpenLogFile(row) {
  try {
    const file = await downloadGeneratedReportFile(row.fileName, 'inline')
    const blobUrl = window.URL.createObjectURL(file)
    window.open(blobUrl, '_blank')
    setTimeout(() => window.URL.revokeObjectURL(blobUrl), 60000)
  } catch (error) {
    console.error('打开执行记录文件失败:', error)
    ElMessage.error('打开失败，文件可能已不存在')
  }
}

async function handleRebuildLogFile(row) {
  try {
    await rebuildExecutionLogFile(row.logId)
    ElMessage.success('执行记录文件重建成功')
    await loadData()
  } catch (error) {
    console.error('重建执行记录文件失败:', error)
    ElMessage.error('重建失败，请检查后端日志')
  }
}

function triggerBlobDownload(file, filename) {
  const blobUrl = window.URL.createObjectURL(file)
  const link = document.createElement('a')
  link.href = blobUrl
  link.download = filename
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  window.URL.revokeObjectURL(blobUrl)
}

function exportPageExcel() {
  try {
    exportMultiSheetExcel(
      [
        { name: '报表任务', data: tableData.value || [] },
        { name: '执行记录', data: executionLogs.value || [] },
        { name: '分享记录', data: shareLogs.value || [] }
      ],
      '报表中心页面数据'
    )
    ElMessage.success('页面Excel导出成功')
  } catch (error) {
    console.error('页面Excel导出失败:', error)
    ElMessage.error('页面Excel导出失败')
  }
}

function handleAdd() {
  Object.assign(form, { taskId: null, taskName: '', reportType: 'warning', cronExpr: '0 0 9 * * ?', shareTarget: '', status: 1 })
  dialogVisible.value = true
}
function handleEdit(row) {
  Object.assign(form, row)
  dialogVisible.value = true
}
async function handleSubmit() {
  if (form.taskId) await updateReportTask(form)
  else await addReportTask(form)
  dialogVisible.value = false
  ElMessage.success('保存成功')
  await loadData()
}
async function handleDelete(id) {
  await deleteReportTask(id)
  ElMessage.success('删除成功')
  await loadData()
}
onMounted(() => loadData())
</script>

<style scoped>
.page { padding: 20px; }
.mb { margin-bottom: 20px; }
h2 { margin-bottom: 20px; }
</style>
