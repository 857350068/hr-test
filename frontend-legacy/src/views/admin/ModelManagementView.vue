<template>
  <div class="model-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>预警模型管理</span>
          <el-button type="primary" @click="handleCreate">新建模型</el-button>
        </div>
      </template>

      <!-- 查询表单 -->
      <el-form :inline="true" :model="queryParams" class="query-form">
        <el-form-item label="模型类型">
          <el-select v-model="queryParams.modelType" placeholder="请选择" clearable>
            <el-option label="流失预测" value="TURNOVER_PREDICTION" />
            <el-option label="人才缺口" value="TALENT_GAP" />
            <el-option label="成本超支" value="COST_OVERSPEED" />
          </el-select>
        </el-form-item>
        <el-form-item label="模型名称">
          <el-input v-model="queryParams.modelName" placeholder="请输入" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 数据表格 -->
      <el-table :data="tableData" v-loading="loading" border stripe>
        <el-table-column prop="modelId" label="模型ID" width="180" />
        <el-table-column prop="modelType" label="模型类型" width="120">
          <template #default="{ row }">
            <el-tag :type="getModelTypeTag(row.modelType)">
              {{ getModelTypeLabel(row.modelType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="modelName" label="模型名称" />
        <el-table-column prop="accuracyRate" label="准确率" width="100">
          <template #default="{ row }">
            {{ row.accuracyRate ? (row.accuracyRate * 100).toFixed(2) + '%' : '未验证' }}
          </template>
        </el-table-column>
        <el-table-column prop="version" label="版本" width="80" />
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
            <el-button type="text" @click="handleValidate(row)">验证</el-button>
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
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="800px">
      <el-form :model="formData" :rules="formRules" ref="formRef" label-width="120px">
        <el-form-item label="模型类型" prop="modelType">
          <el-select v-model="formData.modelType" placeholder="请选择" :disabled="isEdit">
            <el-option label="流失预测" value="TURNOVER_PREDICTION" />
            <el-option label="人才缺口" value="TALENT_GAP" />
            <el-option label="成本超支" value="COST_OVERSPEED" />
          </el-select>
        </el-form-item>
        <el-form-item label="模型名称" prop="modelName">
          <el-input v-model="formData.modelName" placeholder="请输入模型名称" />
        </el-form-item>
        <el-form-item label="特征权重配置" prop="featureWeights">
          <div class="weight-config">
            <div v-for="(weight, feature) in formData.featureWeights" :key="feature" class="weight-item">
              <span class="feature-name">{{ getFeatureLabel(feature) }}</span>
              <el-slider v-model="formData.featureWeights[feature]" :min="0" :max="1" :step="0.01" />
              <span class="weight-value">{{ formData.featureWeights[feature].toFixed(2) }}</span>
            </div>
            <div class="weight-sum">
              权重总和：<span :class="{ 'is-valid': weightSum === 1, 'is-invalid': weightSum !== 1 }">{{ weightSum.toFixed(2) }}</span>
            </div>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :disabled="weightSum !== 1">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { queryModels, createModel, validateModel } from '@/api/warningModel'

// 查询参数
const queryParams = reactive({
  modelType: null,
  modelName: null,
  pageNum: 1,
  pageSize: 10
})

// 表格数据
const tableData = ref([])
const total = ref(0)
const loading = ref(false)

// 对话框
const dialogVisible = ref(false)
const dialogTitle = ref('新建模型')
const isEdit = ref(false)
const formRef = ref(null)
const formData = reactive({
  modelId: null,
  modelType: null,
  modelName: null,
  featureWeights: {
    age: 0.2,
    performance: 0.3,
    salary: 0.3,
    tenure: 0.2
  }
})

// 表单验证规则
const formRules = {
  modelType: [{ required: true, message: '请选择模型类型', trigger: 'change' }],
  modelName: [{ required: true, message: '请输入模型名称', trigger: 'blur' }]
}

// 计算权重总和
const weightSum = computed(() => {
  return Object.values(formData.featureWeights).reduce((sum, w) => sum + w, 0)
})

// 获取模型类型标签
const getModelTypeLabel = (type) => {
  const map = {
    'TURNOVER_PREDICTION': '流失预测',
    'TALENT_GAP': '人才缺口',
    'COST_OVERSPEED': '成本超支'
  }
  return map[type] || type
}

// 获取模型类型标签颜色
const getModelTypeTag = (type) => {
  const map = {
    'TURNOVER_PREDICTION': 'danger',
    'TALENT_GAP': 'warning',
    'COST_OVERSPEED': 'success'
  }
  return map[type] || ''
}

// 获取特征标签
const getFeatureLabel = (feature) => {
  const map = {
    'age': '年龄',
    'performance': '绩效',
    'salary': '薪酬',
    'tenure': '工龄',
    'satisfaction': '满意度',
    'businessGrowth': '业务增长',
    'turnoverRate': '流失率',
    'retirementRate': '退休率',
    'marketDemand': '市场需求'
  }
  return map[feature] || feature
}

// 查询数据
const handleQuery = async () => {
  loading.value = true
  try {
    const res = await queryModels(queryParams)
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
  queryParams.modelType = null
  queryParams.modelName = null
  queryParams.pageNum = 1
  handleQuery()
}

// 新建模型
const handleCreate = () => {
  dialogTitle.value = '新建模型'
  isEdit.value = false
  Object.assign(formData, {
    modelId: null,
    modelType: null,
    modelName: null,
    featureWeights: {
      age: 0.2,
      performance: 0.3,
      salary: 0.3,
      tenure: 0.2
    }
  })
  dialogVisible.value = true
}

// 查看模型
const handleView = (row) => {
  dialogTitle.value = '查看模型'
  isEdit.value = true
  Object.assign(formData, row)
  dialogVisible.value = true
}

// 编辑模型
const handleEdit = (row) => {
  dialogTitle.value = '编辑模型'
  isEdit.value = true
  Object.assign(formData, row)
  dialogVisible.value = true
}

// 验证模型
const handleValidate = async (row) => {
  try {
    await ElMessageBox.confirm('确定要验证该模型的准确率吗？验证可能需要较长时间。', '提示', {
      type: 'warning'
    })
    ElMessage.info('开始验证模型，请稍候...')
    const res = await validateModel(row.modelId)
    ElMessage.success(`验证完成，准确率：${(res.data.accuracyRate * 100).toFixed(2)}%`)
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('验证失败：' + error.message)
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
    if (weightSum.value !== 1) {
      ElMessage.error('特征权重之和必须等于1')
      return
    }
    if (isEdit.value) {
      ElMessage.success('更新成功')
    } else {
      await createModel(formData)
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
.model-management {
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

.weight-config {
  width: 100%;
}

.weight-item {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
}

.feature-name {
  width: 100px;
  font-weight: bold;
}

.weight-item .el-slider {
  flex: 1;
  margin: 0 15px;
}

.weight-value {
  width: 50px;
  text-align: right;
}

.weight-sum {
  margin-top: 20px;
  padding: 10px;
  background: #f5f7fa;
  border-radius: 4px;
  text-align: center;
  font-size: 16px;
  font-weight: bold;
}

.is-valid {
  color: #67c23a;
}

.is-invalid {
  color: #f56c6c;
}
</style>
