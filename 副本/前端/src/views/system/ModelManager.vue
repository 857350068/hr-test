<template>
  <div class="page">
    <h2>预警模型管理</h2>
    <el-card class="mb">
      <el-button type="primary" @click="handleAdd">新增模型</el-button>
    </el-card>
    <el-card>
      <el-table :data="tableData" border>
        <el-table-column prop="modelName" label="模型名称" min-width="150" />
        <el-table-column prop="modelType" label="类型" width="120" />
        <el-table-column prop="modelVersion" label="版本" width="120" />
        <el-table-column prop="accuracyRate" label="准确率" width="120" />
        <el-table-column prop="featureWeights" label="特征权重(JSON)" min-width="220" />
        <el-table-column label="操作" width="180">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row.modelId)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    <el-dialog v-model="dialogVisible" :title="form.modelId ? '编辑模型' : '新增模型'" width="560px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="模型名"><el-input v-model="form.modelName" /></el-form-item>
        <el-form-item label="模型类型"><el-input v-model="form.modelType" /></el-form-item>
        <el-form-item label="版本"><el-input v-model="form.modelVersion" /></el-form-item>
        <el-form-item label="准确率"><el-input-number v-model="form.accuracyRate" :step="0.01" :min="0" :max="1" style="width: 100%" /></el-form-item>
        <el-form-item label="特征权重"><el-input v-model="form.featureWeights" type="textarea" /></el-form-item>
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
import { addModel, deleteModel, getModelList, updateModel } from '@/api/model'

const tableData = ref([])
const dialogVisible = ref(false)
const form = reactive({ modelId: null, modelName: '', modelType: '', modelVersion: '', accuracyRate: 0.8, featureWeights: '{}' })
async function loadData() {
  const res = await getModelList()
  tableData.value = res.data || []
}
function handleAdd() {
  Object.assign(form, { modelId: null, modelName: '', modelType: '', modelVersion: '', accuracyRate: 0.8, featureWeights: '{}' })
  dialogVisible.value = true
}
function handleEdit(row) {
  Object.assign(form, row)
  dialogVisible.value = true
}
async function handleSubmit() {
  if (form.modelId) await updateModel(form)
  else await addModel(form)
  dialogVisible.value = false
  ElMessage.success('保存成功')
  await loadData()
}
async function handleDelete(id) {
  await deleteModel(id)
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
