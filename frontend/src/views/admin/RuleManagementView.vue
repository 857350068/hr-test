<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">预警规则管理</h2>
      <el-button type="primary" @click="openDialog()">新增规则</el-button>
    </div>
    <el-card>
      <el-table :data="list" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="ruleType" label="规则类型" width="140">
          <template #default="{ row }">
            <el-tag>{{ getRuleTypeName(row.ruleType) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="threshold" label="阈值" width="100">
          <template #default="{ row }">{{ row.threshold }}{{ getRuleUnit(row.ruleType) }}</template>
        </el-table-column>
        <el-table-column prop="description" label="描述" show-overflow-tooltip />
        <el-table-column prop="effective" label="生效状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.effective === 1 ? 'success' : 'info'">
              {{ row.effective === 1 ? '生效' : '未生效' }}
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
      width="600px"
      @close="resetForm"
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="规则类型" prop="ruleType">
          <el-select v-model="form.ruleType" placeholder="请选择规则类型" clearable>
            <el-option
              v-for="item in ruleTypeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="阈值" prop="threshold">
          <el-input-number
            v-model="form.threshold"
            :precision="1"
            :step="0.5"
            :min="0"
            style="width: 100%"
          />
          <span class="unit-hint">{{ getRuleUnit(form.ruleType) }}</span>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" :rows="3" placeholder="请输入规则描述" />
        </el-form-item>
        <el-form-item label="生效状态" prop="effective">
          <el-switch v-model="form.effective" :active-value="1" :inactive-value="0" />
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
import { getRuleList, addRule, updateRule, deleteRule } from '@/api/rule'
import { ElMessage, ElMessageBox } from 'element-plus'

const list = ref([])
const loading = ref(false)
const dialogVisible = ref(false)
const submitting = ref(false)
const dialogTitle = ref('')
const formRef = ref(null)

const ruleTypeOptions = [
  { value: 'FLIGHT_RISK', label: '员工流失风险' },
  { value: 'TALENT_SHORTAGE', label: '人才短缺' },
  { value: 'COST_OVER', label: '成本超支' }
]

const form = reactive({
  id: null,
  ruleType: '',
  threshold: 0,
  description: '',
  effective: 1
})

const rules = {
  ruleType: [{ required: true, message: '请选择规则类型', trigger: 'change' }],
  threshold: [{ required: true, message: '请输入阈值', trigger: 'blur' }],
  description: [{ required: true, message: '请输入规则描述', trigger: 'blur' }]
}

const getRuleTypeName = (type) => {
  const option = ruleTypeOptions.find(item => item.value === type)
  return option ? option.label : type
}

const getRuleUnit = (type) => {
  const units = {
    'FLIGHT_RISK': '%',
    'TALENT_SHORTAGE': '人',
    'COST_OVER': '%'
  }
  return units[type] || ''
}

const loadList = async () => {
  loading.value = true
  try {
    const res = await getRuleList()
    list.value = res.data || []
  } catch (e) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

const openDialog = (row = null) => {
  if (row) {
    dialogTitle.value = '编辑预警规则'
    form.id = row.id
    form.ruleType = row.ruleType
    form.threshold = row.threshold
    form.description = row.description || ''
    form.effective = row.effective
  } else {
    dialogTitle.value = '新增预警规则'
    resetForm()
  }
  dialogVisible.value = true
}

const resetForm = () => {
  form.id = null
  form.ruleType = ''
  form.threshold = 0
  form.description = ''
  form.effective = 1
  formRef.value?.clearValidate()
}

const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate()
  submitting.value = true
  try {
    if (form.id) {
      await updateRule(form.id, form)
      ElMessage.success('更新成功')
    } else {
      await addRule(form)
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
    await ElMessageBox.confirm('确定删除该预警规则吗？', '提示', { type: 'warning' })
    await deleteRule(id)
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

.unit-hint {
  margin-left: 10px;
  color: #909399;
  font-size: 14px;
}
</style>
