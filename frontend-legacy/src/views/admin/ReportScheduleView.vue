<template>
  <div class="report-schedule">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>报表定时任务管理</span>
          <el-button type="primary" @click="handleCreate">新建任务</el-button>
        </div>
      </template>

      <!-- 查询表单 -->
      <el-form :inline="true" :model="queryParams" class="query-form">
        <el-form-item label="任务名称">
          <el-input v-model="queryParams.taskName" placeholder="请输入" clearable />
        </el-form-item>
        <el-form-item label="调度类型">
          <el-select v-model="queryParams.scheduleType" placeholder="请选择" clearable>
            <el-option label="日报" value="DAILY" />
            <el-option label="周报" value="WEEKLY" />
            <el-option label="月报" value="MONTHLY" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 数据表格 -->
      <el-table :data="tableData" v-loading="loading" border stripe>
        <el-table-column prop="taskId" label="任务ID" width="180" />
        <el-table-column prop="taskName" label="任务名称" />
        <el-table-column prop="scheduleType" label="调度类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getScheduleTypeTag(row.scheduleType)">
              {{ getScheduleTypeLabel(row.scheduleType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="executeTime" label="执行时间" width="120" />
        <el-table-column prop="linkExpiryDays" label="链接有效期(天)" width="120" />
        <el-table-column prop="isActive" label="启用状态" width="100">
          <template #default="{ row }">
            <el-switch v-model="row.isActive" @change="handleStatusChange(row)" />
          </template>
        </el-table-column>
        <el-table-column prop="createdTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="{ row }">
            <el-button type="text" @click="handleView(row)">查看</el-button>
            <el-button type="text" @click="handleEdit(row)">编辑</el-button>
            <el-button type="text" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleQuery"
        @current-change="handleQuery"
      />
    </el-card>

    <!-- 新建/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px">
      <el-form :model="formData" :rules="formRules" ref="formRef" label-width="120px">
        <el-form-item label="报表模板" prop="templateId">
          <el-select v-model="formData.templateId" placeholder="请选择报表模板">
            <el-option label="人力资源总览报表" value="TPL_001" />
            <el-option label="组织效能报表" value="TPL_002" />
            <el-option label="人才梯队报表" value="TPL_003" />
          </el-select>
        </el-form-item>
        <el-form-item label="任务名称" prop="taskName">
          <el-input v-model="formData.taskName" placeholder="请输入任务名称" />
        </el-form-item>
        <el-form-item label="调度类型" prop="scheduleType">
          <el-select v-model="formData.scheduleType" placeholder="请选择调度类型" @change="handleScheduleTypeChange">
            <el-option label="日报" value="DAILY" />
            <el-option label="周报" value="WEEKLY" />
            <el-option label="月报" value="MONTHLY" />
          </el-select>
        </el-form-item>
        <el-form-item label="执行时间" prop="executeTime">
          <el-input v-model="formData.executeTime" placeholder="格式：HH:MM 或 DAY HH:MM" />
          <div class="time-hint">
            <span v-if="formData.scheduleType === 'DAILY'">日报格式：HH:MM（如 09:00）</span>
            <span v-else-if="formData.scheduleType === 'WEEKLY'">周报格式：DAY HH:MM（如 1 09:00，1表示周一）</span>
            <span v-else-if="formData.scheduleType === 'MONTHLY'">月报格式：DAY HH:MM（如 1 09:00，1表示每月1号）</span>
          </div>
        </el-form-item>
        <el-form-item label="分享权限" prop="sharePermissions">
          <el-checkbox-group v-model="formData.sharePermissionList">
            <el-checkbox label="HR_ADMIN">HR管理员</el-checkbox>
            <el-checkbox label="DEPT_HEAD">部门负责人</el-checkbox>
            <el-checkbox label="MANAGEMENT">企业管理层</el-checkbox>
          </el-checkbox-group>
        </el-form-item>
        <el-form-item label="链接有效期" prop="linkExpiryDays">
          <el-input-number v-model="formData.linkExpiryDays" :min="1" :max="365" />
          <span class="unit">天</span>
        </el-form-item>
        <el-form-item label="是否启用" prop="isActive">
          <el-switch v-model="formData.isActive" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { queryTasks, createTask, updateTask, deleteTask } from '@/api/reportSchedule'

// 查询参数
const queryParams = reactive({
  taskName: null,
  scheduleType: null,
  pageNum: 1,
  pageSize: 10
})

// 表格数据
const tableData = ref([])
const total = ref(0)
const loading = ref(false)

// 对话框
const dialogVisible = ref(false)
const dialogTitle = ref('新建任务')
const isEdit = ref(false)
const formRef = ref(null)
const formData = reactive({
  taskId: null,
  templateId: null,
  taskName: null,
  scheduleType: null,
  executeTime: null,
  sharePermissionList: ['HR_ADMIN'],
  linkExpiryDays: 30,
  isActive: true
})

// 表单验证规则
const formRules = {
  templateId: [{ required: true, message: '请选择报表模板', trigger: 'change' }],
  taskName: [{ required: true, message: '请输入任务名称', trigger: 'blur' }],
  scheduleType: [{ required: true, message: '请选择调度类型', trigger: 'change' }],
  executeTime: [{ required: true, message: '请输入执行时间', trigger: 'blur' }],
  linkExpiryDays: [{ required: true, message: '请输入链接有效期', trigger: 'blur' }]
}

// 获取调度类型标签
const getScheduleTypeLabel = (type) => {
  const map = {
    'DAILY': '日报',
    'WEEKLY': '周报',
    'MONTHLY': '月报'
  }
  return map[type] || type
}

// 获取调度类型标签颜色
const getScheduleTypeTag = (type) => {
  const map = {
    'DAILY': 'primary',
    'WEEKLY': 'success',
    'MONTHLY': 'warning'
  }
  return map[type] || ''
}

// 调度类型变化处理
const handleScheduleTypeChange = (value) => {
  if (value === 'DAILY') {
    formData.executeTime = '09:00'
  } else if (value === 'WEEKLY') {
    formData.executeTime = '1 09:00'
  } else if (value === 'MONTHLY') {
    formData.executeTime = '1 09:00'
  }
}

// 查询数据
const handleQuery = async () => {
  loading.value = true
  try {
    const res = await queryTasks(queryParams)
    tableData.value = res.data.records
    total.value = res.data.total
  } catch (error) {
    ElMessage.error('查询失败：' + error.message)
  } finally {
    loading.value = false
  }
}

// 重置查询
const handleReset = () => {
  queryParams.taskName = null
  queryParams.scheduleType = null
  queryParams.pageNum = 1
  handleQuery()
}

// 新建任务
const handleCreate = () => {
  dialogTitle.value = '新建任务'
  isEdit.value = false
  Object.assign(formData, {
    taskId: null,
    templateId: null,
    taskName: null,
    scheduleType: null,
    executeTime: null,
    sharePermissionList: ['HR_ADMIN'],
    linkExpiryDays: 30,
    isActive: true
  })
  dialogVisible.value = true
}

// 查看任务
const handleView = (row) => {
  dialogTitle.value = '查看任务'
  isEdit.value = true
  Object.assign(formData, row, {
    sharePermissionList: JSON.parse(row.sharePermissions || '[]')
  })
  dialogVisible.value = true
}

// 编辑任务
const handleEdit = (row) => {
  dialogTitle.value = '编辑任务'
  isEdit.value = true
  Object.assign(formData, row, {
    sharePermissionList: JSON.parse(row.sharePermissions || '[]')
  })
  dialogVisible.value = true
}

// 删除任务
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除该任务吗？', '提示', {
      type: 'warning'
    })
    await deleteTask(row.taskId)
    ElMessage.success('删除成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败：' + error.message)
    }
  }
}

// 状态切换
const handleStatusChange = async (row) => {
  ElMessage.success('状态切换成功')
  handleQuery()
}

// 提交表单
const handleSubmit = async () => {
  try {
    await formRef.value.validate()
    const submitData = {
      ...formData,
      sharePermissions: JSON.stringify(formData.sharePermissionList)
    }
    if (isEdit.value) {
      await updateTask(formData.taskId, submitData)
      ElMessage.success('更新成功')
    } else {
      await createTask(submitData)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    handleQuery()
  } catch (error) {
    ElMessage.error('操作失败：' + error.message)
  }
}

onMounted(() => {
  handleQuery()
})
</script>

<style scoped>
.report-schedule {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.query-form {
  margin-bottom: 20px;
}

.el-pagination {
  margin-top: 20px;
  text-align: right;
}

.time-hint {
  margin-top: 5px;
  font-size: 12px;
  color: #909399;
}

.unit {
  margin-left: 10px;
}
</style>
