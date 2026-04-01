<template>
  <div class="rule-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>分析规则管理</span>
          <el-button type="primary" @click="handleCreate">新建规则</el-button>
        </div>
      </template>

      <!-- 查询表单 -->
      <el-form :inline="true" :model="query" class="query-form">
        <el-form-item label="规则类型">
          <el-select v-model="query.ruleType" placeholder="请选择" clearable>
            <el-option label="流失预警" value="TURNOVER_WARNING" />
            <el-option label="薪酬对标" value="COMPENSATION_BENCHMARK" />
            <el-option label="培训ROI" value="TRAINING_ROI" />
            <el-option label="绩效评估" value="PERFORMANCE_EVAL" />
            <el-option label="人才缺口" value="TALENT_GAP" />
          </el-select>
        </el-form-item>
        <el-form-item label="生效状态">
          <el-select v-model="query.isActive" placeholder="请选择" clearable>
            <el-option label="已生效" :value="true" />
            <el-option label="未生效" :value="false" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 数据表格 -->
      <el-table :data="tableData" v-loading="loading" border stripe>
        <el-table-column prop="id" label="规则ID" width="180" />
        <el-table-column prop="ruleType" label="规则类型" width="120">
          <template #default="{ row }">
            <el-tag :type="getRuleTypeTag(row.ruleType)">
              {{ getRuleTypeLabel(row.ruleType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="ruleName" label="规则名称" />
        <el-table-column prop="isActive" label="生效状态" width="100">
          <template #default="{ row }">
            <el-switch
              v-model="row.isActive"
              @change="handleStatusChange(row)"
              :disabled="!hasPermission('HR_ADMIN')"
            />
          </template>
        </el-table-column>
        <el-table-column prop="createdTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="text" @click="handleView(row)">查看</el-button>
            <el-button type="text" @click="handleEdit(row)" v-if="hasPermission('HR_ADMIN')">编辑</el-button>
            <el-button type="text" @click="handleDelete(row)" v-if="hasPermission('HR_ADMIN') && !row.isActive">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :total="page.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="load"
        @current-change="load"
      />
    </el-card>

    <!-- 新建/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px">
      <el-form :model="formData" :rules="formRules" ref="formRef" label-width="100px">
        <el-form-item label="规则类型" prop="ruleType">
          <el-select v-model="formData.ruleType" placeholder="请选择" :disabled="isEdit">
            <el-option label="流失预警" value="TURNOVER_WARNING" />
            <el-option label="薪酬对标" value="COMPENSATION_BENCHMARK" />
            <el-option label="培训ROI" value="TRAINING_ROI" />
            <el-option label="绩效评估" value="PERFORMANCE_EVAL" />
            <el-option label="人才缺口" value="TALENT_GAP" />
          </el-select>
        </el-form-item>
        <el-form-item label="规则名称" prop="ruleName">
          <el-input v-model="formData.ruleName" placeholder="请输入规则名称" />
        </el-form-item>
        <el-form-item label="规则参数" prop="ruleParams">
          <el-input
            v-model="formData.ruleParams"
            type="textarea"
            :rows="6"
            placeholder="请输入JSON格式的规则参数"
          />
        </el-form-item>
        <el-form-item label="生效状态" prop="isActive">
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
import { getRuleList, addRule, updateRule, deleteRule } from '@/api/rule'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

// 分页状态
const page = reactive({
  current: 1,
  size: 10,
  total: 0
})

// 查询条件
// 用泛型声明类型，彻底解决语法报错（推荐标准写法）
const query = reactive<{
  ruleType: String,
  isActive: boolean,
}>({
  ruleType: '',
  isActive: undefined
})

// 表格数据
const tableData = ref([])
const loading = ref(false)

// 对话框
const dialogVisible = ref(false)
const dialogTitle = ref('新建规则')
const isEdit = ref(false)
const formRef = ref(null)
const formData = reactive({
  id: null,
  ruleType: null,
  ruleName: null,
  ruleParams: null,
  isActive: false
})

// 表单验证规则
const formRules = {
  ruleType: [{ required: true, message: '请选择规则类型', trigger: 'change' }],
  ruleName: [{ required: true, message: '请输入规则名称', trigger: 'blur' }],
  ruleParams: [{ required: true, message: '请输入规则参数', trigger: 'blur' }]
}

// 权限检查
const hasPermission = (role) => {
  return userStore.roles.includes(role)
}

// 获取规则类型标签
const getRuleTypeLabel = (type) => {
  const map = {
    'TURNOVER_WARNING': '流失预警',
    'COMPENSATION_BENCHMARK': '薪酬对标',
    'TRAINING_ROI': '培训ROI',
    'PERFORMANCE_EVAL': '绩效评估',
    'TALENT_GAP': '人才缺口'
  }
  return map[type] || type
}

// 获取规则类型标签颜色
const getRuleTypeTag = (type) => {
  const map = {
    'TURNOVER_WARNING': 'danger',
    'COMPENSATION_BENCHMARK': 'warning',
    'TRAINING_ROI': 'success',
    'PERFORMANCE_EVAL': 'primary',
    'TALENT_GAP': 'info'
  }
  return map[type] || ''
}

// 分页加载数据
const load = async () => {
  loading.value = true
  try {
    const res = await getRulePage({
      current: page.current,
      size: page.size,
      ruleType: query.ruleType || undefined,
      isActive: query.isActive
    })
    tableData.value = res.data.records || []
    page.total = res.data.total || 0
  } catch (e) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

// 查询数据
const handleQuery = () => {
  page.current = 1
  load()
}

// 重置查询
const handleReset = () => {
  query.ruleType = ''
  query.isActive = undefined
  page.current = 1
  load()
}

// 新建规则
const handleCreate = () => {
  dialogTitle.value = '新建规则'
  isEdit.value = false
  Object.assign(formData, {
    id: null,
    ruleType: null,
    ruleName: null,
    ruleParams: null,
    isActive: false
  })
  dialogVisible.value = true
}

// 查看规则
const handleView = (row) => {
  dialogTitle.value = '查看规则'
  isEdit.value = true
  Object.assign(formData, row)
  dialogVisible.value = true
}

// 编辑规则
const handleEdit = (row) => {
  dialogTitle.value = '编辑规则'
  isEdit.value = true
  Object.assign(formData, row)
  dialogVisible.value = true
}

// 删除规则
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除该规则吗？', '提示', {
      type: 'warning'
    })
    await deleteRule(row.id)
    ElMessage.success('删除成功')
    load()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败：' + error.message)
    }
  }
}

// 状态切换
const handleStatusChange = async (row) => {
  try {
    // 更新状态
    await updateRule(row.id, row)
    ElMessage.success('状态切换成功')
    load()
  } catch (error) {
    ElMessage.error('状态切换失败：' + error.message)
    row.isActive = !row.isActive
  }
}

// 提交表单
const handleSubmit = async () => {
  try {
    await formRef.value.validate()
    if (isEdit.value) {
      await updateRule(formData.id, formData)
      ElMessage.success('更新成功')
    } else {
      await addRule(formData)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    load()
  } catch (error) {
    ElMessage.error('操作失败：' + error.message)
  }
}

onMounted(() => {
  load()
})
</script>

<style scoped>
.rule-management {
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
</style>
