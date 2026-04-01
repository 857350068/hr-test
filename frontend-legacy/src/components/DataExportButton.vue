<template>
  <div class="data-export-container">
    <el-button-group>
      <el-button 
        type="primary" 
        :icon="Download" 
        @click="showExportDialog"
        :loading="exporting"
      >
        导出数据
      </el-button>
      <el-dropdown @command="handleQuickExport">
        <el-button type="primary">
          <el-icon><ArrowDown /></el-icon>
        </el-button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="excel" :icon="Document">
              导出为Excel
            </el-dropdown-item>
            <el-dropdown-item command="csv" :icon="Tickets">
              导出为CSV
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </el-button-group>

    <!-- 导出配置对话框 -->
    <el-dialog
      v-model="exportDialogVisible"
      title="数据导出配置"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form :model="exportForm" label-width="100px">
        <el-form-item label="导出格式">
          <el-radio-group v-model="exportForm.format">
            <el-radio label="excel">Excel格式</el-radio>
            <el-radio label="csv">CSV格式</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="数据类型">
          <el-select v-model="exportForm.dataType" placeholder="请选择数据类型" style="width: 100%">
            <el-option
              v-for="item in dataTypeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
              :disabled="item.disabled"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="筛选条件" v-if="showFilterOptions">
          <div class="filter-options">
            <el-form-item label="部门">
              <el-select v-model="exportForm.filters.deptId" placeholder="全部部门" clearable>
                <el-option
                  v-for="dept in departmentOptions"
                  :key="dept.id"
                  :label="dept.name"
                  :value="dept.id"
                />
              </el-select>
            </el-form-item>

            <el-form-item label="时间周期">
              <el-select v-model="exportForm.filters.period" placeholder="全部周期" clearable>
                <el-option
                  v-for="period in periodOptions"
                  :key="period.value"
                  :label="period.label"
                  :value="period.value"
                />
              </el-select>
            </el-form-item>

            <el-form-item label="岗位">
              <el-input v-model="exportForm.filters.job" placeholder="输入岗位名称" clearable />
            </el-form-item>
          </div>
        </el-form-item>

        <el-form-item label="文件名">
          <el-input v-model="exportForm.fileName" placeholder="留空使用默认文件名" />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="exportDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleExport" :loading="exporting">
          开始导出
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Download, ArrowDown, Document, Tickets } from '@element-plus/icons-vue'
import axios from 'axios'

const props = defineProps({
  exportType: {
    type: String,
    default: 'employee-profile' // employee-profile, analysis-data, users, departments
  },
  categoryId: {
    type: Number,
    default: null
  },
  templateId: {
    type: Number,
    default: null
  },
  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['export-start', 'export-success', 'export-error'])

const exporting = ref(false)
const exportDialogVisible = ref(false)
const exportForm = reactive({
  format: 'excel',
  dataType: 'employee-profile',
  fileName: '',
  filters: {
    deptId: null,
    period: '',
    job: ''
  }
})

const dataTypeOptions = ref([
  { value: 'employee-profile', label: '员工档案数据', disabled: false },
  { value: 'analysis-data', label: '分析数据', disabled: false },
  { value: 'users', label: '用户数据', disabled: false },
  { value: 'departments', label: '部门数据', disabled: false },
  { value: 'multi-dimension', label: '多维度数据', disabled: false }
])

const departmentOptions = ref([])
const periodOptions = ref([])

const showFilterOptions = computed(() => {
  return ['employee-profile', 'analysis-data'].includes(exportForm.dataType)
})

// 初始化数据类型
onMounted(async () => {
  exportForm.dataType = props.exportType
  await loadFilterOptions()
})

// 加载筛选选项
const loadFilterOptions = async () => {
  try {
    // 加载部门选项
    const deptRes = await axios.get('/api/query/filter-options/dept')
    if (deptRes.data.code === 200) {
      departmentOptions.value = deptRes.data.data.options
    }

    // 加载时间周期选项
    const periodRes = await axios.get('/api/query/filter-options/period')
    if (periodRes.data.code === 200) {
      periodOptions.value = periodRes.data.data.options.map(p => ({
        value: p.value,
        label: p.value
      }))
    }
  } catch (error) {
    console.error('加载筛选选项失败:', error)
  }
}

// 显示导出对话框
const showExportDialog = () => {
  exportDialogVisible.value = true
}

// 快速导出
const handleQuickExport = async (format) => {
  exportForm.format = format
  await handleExport()
}

// 执行导出
const handleExport = async () => {
  try {
    exporting.value = true
    emit('export-start')

    // 构建导出URL
    let url = `/api/export/${exportForm.dataType}/${exportForm.format}`
    let params = new URLSearchParams()

    // 添加筛选参数
    if (exportForm.filters.deptId) {
      params.append('deptId', exportForm.filters.deptId)
    }
    if (exportForm.filters.period) {
      params.append('period', exportForm.filters.period)
    }
    if (exportForm.filters.job) {
      params.append('job', exportForm.filters.job)
    }

    // 添加特定参数
    if (props.categoryId) {
      params.append('categoryId', props.categoryId)
    }
    if (props.templateId) {
      params.append('templateId', props.templateId)
    }

    // 多维度数据导出
    if (exportForm.dataType === 'multi-dimension') {
      params.append('categoryIds', Object.keys(dataTypeOptions.value)
        .filter(key => dataTypeOptions.value[key].value !== 'multi-dimension')
        .map(key => dataTypeOptions.value[key].value)
        .join(','))
    }

    // 构建完整URL
    const fullUrl = params.toString() ? `${url}?${params.toString()}` : url

    // 创建下载链接
    const link = document.createElement('a')
    link.href = fullUrl
    link.download = exportForm.fileName || '数据导出'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)

    exportDialogVisible.value = false
    ElMessage.success('导出成功')
    emit('export-success')

  } catch (error) {
    console.error('导出失败:', error)
    ElMessage.error('导出失败：' + (error.message || '未知错误'))
    emit('export-error', error)
  } finally {
    exporting.value = false
  }
}
</script>

<style scoped>
.data-export-container {
  display: inline-block;
}

.filter-options {
  width: 100%;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  padding: 15px;
}

.filter-options .el-form-item {
  margin-bottom: 15px;
}

.filter-options .el-form-item:last-child {
  margin-bottom: 0;
}
</style>
