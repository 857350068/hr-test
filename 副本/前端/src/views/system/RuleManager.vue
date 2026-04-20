<template>
  <div class="page">
    <h2>分析规则管理</h2>
    <el-card class="mb">
      <el-button type="primary" @click="handleAdd">新增规则</el-button>
    </el-card>
    <el-card>
      <el-table :data="tableData" border>
        <el-table-column prop="ruleName" label="规则名称" />
        <el-table-column prop="ruleType" label="类型" width="120" />
        <el-table-column prop="ruleKey" label="键" width="160" />
        <el-table-column prop="ruleValue" label="值" width="160" />
        <el-table-column prop="effectStatus" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.effectStatus === 1 ? 'success' : 'info'">{{ row.effectStatus === 1 ? '已生效' : '未生效' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="260">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)" :disabled="row.effectStatus === 1">编辑</el-button>
            <el-button size="small" type="success" @click="handleEffect(row.ruleId)" :disabled="row.effectStatus === 1">生效</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row.ruleId)" :disabled="row.effectStatus === 1">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="form.ruleId ? '编辑规则' : '新增规则'" width="520px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="规则名"><el-input v-model="form.ruleName" /></el-form-item>
        <el-form-item label="规则类型"><el-input v-model="form.ruleType" /></el-form-item>
        <el-form-item label="规则键"><el-input v-model="form.ruleKey" /></el-form-item>
        <el-form-item label="规则值"><el-input v-model="form.ruleValue" /></el-form-item>
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
import { addRule, deleteRule, effectRule, getRuleList, updateRule } from '@/api/rule'

const tableData = ref([])
const dialogVisible = ref(false)
const form = reactive({ ruleId: null, ruleName: '', ruleType: '', ruleKey: '', ruleValue: '' })

async function loadData() {
  const res = await getRuleList()
  tableData.value = res.data || []
}
function handleAdd() {
  Object.assign(form, { ruleId: null, ruleName: '', ruleType: '', ruleKey: '', ruleValue: '' })
  dialogVisible.value = true
}
function handleEdit(row) {
  Object.assign(form, row)
  dialogVisible.value = true
}
async function handleSubmit() {
  if (form.ruleId) await updateRule(form)
  else await addRule(form)
  dialogVisible.value = false
  ElMessage.success('保存成功')
  await loadData()
}
async function handleDelete(id) {
  await deleteRule(id)
  ElMessage.success('删除成功')
  await loadData()
}
async function handleEffect(id) {
  await effectRule(id)
  ElMessage.success('规则已生效')
  await loadData()
}
onMounted(() => loadData())
</script>

<style scoped>
.page { padding: 20px; }
.mb { margin-bottom: 20px; }
h2 { margin-bottom: 20px; }
</style>
