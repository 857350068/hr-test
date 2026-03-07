<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">报表管理</h2>
      <el-button type="primary" @click="openDialog()">新增报表</el-button>
    </div>
    <el-card>
      <el-table :data="list" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="模板名称" />
        <el-table-column prop="category" label="分类" width="120" />
        <el-table-column prop="description" label="描述" show-overflow-tooltip />
        <el-table-column prop="enabled" label="启用状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.enabled === 1 ? 'success' : 'info'">
              {{ row.enabled === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="openDialog(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="700px"
      @close="resetForm"
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="模板名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入模板名称" />
        </el-form-item>
        <el-form-item label="分类" prop="category">
          <el-select v-model="form.category" placeholder="请选择分类" clearable>
            <el-option label="人员报表" value="PERSONNEL" />
            <el-option label="绩效报表" value="PERFORMANCE" />
            <el-option label="薪酬报表" value="COMPENSATION" />
            <el-option label="效能报表" value="EFFICIENCY" />
            <el-option label="人才报表" value="TALENT" />
            <el-option label="流失报表" value="TURNOVER" />
            <el-option label="培训报表" value="TRAINING" />
            <el-option label="成本报表" value="COST" />
            <el-option label="发展报表" value="DEVELOPMENT" />
            <el-option label="综合报表" value="COMPREHENSIVE" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" :rows="2" placeholder="请输入描述" />
        </el-form-item>
        <el-form-item label="SQL查询" prop="querySql">
          <el-input v-model="form.querySql" type="textarea" :rows="4" placeholder="请输入SQL查询语句" />
        </el-form-item>
        <el-form-item label="参数配置" prop="parameters">
          <el-input v-model="form.parameters" type="textarea" :rows="2" placeholder='JSON格式,如: {"period":"YYYYMM"}' />
        </el-form-item>
        <el-form-item label="图表配置" prop="chartConfig">
          <el-input v-model="form.chartConfig" type="textarea" :rows="2" placeholder='JSON格式,如: {"type":"bar","title":"标题"}' />
        </el-form-item>
        <el-form-item label="启用状态" prop="enabled">
          <el-switch v-model="form.enabled" :active-value="1" :inactive-value="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getReportList, addReport, updateReport, deleteReport } from '@/api/report'
import { ElMessage, ElMessageBox } from 'element-plus'

const list = ref([])
const loading = ref(false)
const dialogVisible = ref(false)
const submitting = ref(false)
const dialogTitle = ref('')
const formRef = ref(null)

const form = reactive({
  id: null,
  name: '',
  category: '',
  description: '',
  querySql: '',
  parameters: '',
  chartConfig: '',
  enabled: 1
})

const rules = {
  name: [{ required: true, message: '请输入模板名称', trigger: 'blur' }],
  category: [{ required: true, message: '请选择分类', trigger: 'change' }],
  querySql: [{ required: true, message: '请输入SQL查询语句', trigger: 'blur' }]
}

const loadList = async () => {
  loading.value = true
  try {
    const res = await getReportList()
    list.value = res.data || []
  } catch (e) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

const openDialog = (row = null) => {
  if (row) {
    dialogTitle.value = '编辑报表'
    form.id = row.id
    form.name = row.name
    form.category = row.category
    form.description = row.description || ''
    form.querySql = row.querySql || ''
    form.parameters = row.parameters || ''
    form.chartConfig = row.chartConfig || ''
    form.enabled = row.enabled
  } else {
    dialogTitle.value = '新增报表'
    resetForm()
  }
  dialogVisible.value = true
}

const resetForm = () => {
  form.id = null
  form.name = ''
  form.category = ''
  form.description = ''
  form.querySql = ''
  form.parameters = ''
  form.chartConfig = ''
  form.enabled = 1
  formRef.value?.clearValidate()
}

const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate()
  submitting.value = true
  try {
    if (form.id) {
      await updateReport(form.id, form)
      ElMessage.success('更新成功')
    } else {
      await addReport(form)
      ElMessage.success('新增成功')
    }
    dialogVisible.value = false
    loadList()
  } catch (e) {
    ElMessage.error(form.id ? '更新失败' : '新增失败')
  } finally {
    submitting.value = false
  }
}

const handleDelete = async (id) => {
  try {
    await ElMessageBox.confirm('确定删除该报表吗？', '提示', { type: 'warning' })
    await deleteReport(id)
    ElMessage.success('删除成功')
    loadList()
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

onMounted(loadList)
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
</style>
