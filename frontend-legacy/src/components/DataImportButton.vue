<template>
  <div class="data-import-container">
    <el-button 
      type="success" 
      :icon="Upload" 
      @click="showImportDialog"
      :loading="importing"
    >
      导入数据
    </el-button>

    <!-- 导入配置对话框 -->
    <el-dialog
      v-model="importDialogVisible"
      title="数据导入"
      width="700px"
      :close-on-click-modal="false"
    >
      <el-steps :active="importStep" align-center>
        <el-step title="选择数据类型" />
        <el-step title="上传文件" />
        <el-step title="验证数据" />
        <el-step title="完成导入" />
      </el-steps>

      <!-- 第一步：选择数据类型 -->
      <div v-if="importStep === 0" class="import-step-content">
        <el-alert
          title="提示"
          type="info"
          :closable="false"
          style="margin-bottom: 20px"
        >
          请选择要导入的数据类型，系统会提供相应的导入模板。
        </el-alert>

        <el-form :model="importForm" label-width="100px">
          <el-form-item label="数据类型">
            <el-select v-model="importForm.dataType" placeholder="请选择数据类型" style="width: 100%">
              <el-option
                v-for="item in dataTypeOptions"
                :key="item.code"
                :label="item.name"
                :value="item.code"
              >
                <div>
                  <span>{{ item.name }}</span>
                  <span style="color: #8492a6; font-size: 12px; margin-left: 10px">
                    {{ item.description }}
                  </span>
                </div>
              </el-option>
            </el-select>
          </el-form-item>

          <el-form-item label="数据分类" v-if="importForm.dataType === 'analysis-data'">
            <el-select v-model="importForm.categoryId" placeholder="请选择数据分类" style="width: 100%">
              <el-option
                v-for="item in categoryOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </el-select>
          </el-form-item>
        </el-form>

        <div style="text-align: center; margin-top: 20px">
          <el-button @click="downloadTemplate" :icon="Download">
            下载导入模板
          </el-button>
        </div>
      </div>

      <!-- 第二步：上传文件 -->
      <div v-if="importStep === 1" class="import-step-content">
        <el-upload
          ref="uploadRef"
          class="upload-demo"
          drag
          action="#"
          :auto-upload="false"
          :on-change="handleFileChange"
          :on-remove="handleFileRemove"
          :limit="1"
          accept=".xlsx,.xls"
        >
          <el-icon class="el-icon--upload"><upload-filled /></el-icon>
          <div class="el-upload__text">
            拖拽文件到此处或 <em>点击上传</em>
          </div>
          <template #tip>
            <div class="el-upload__tip">
              只支持 .xlsx 或 .xls 格式的Excel文件
            </div>
          </template>
        </el-upload>
      </div>

      <!-- 第三步：验证数据 -->
      <div v-if="importStep === 2" class="import-step-content">
        <div v-if="validating" style="text-align: center; padding: 40px">
          <el-icon class="is-loading" :size="40"><loading /></el-icon>
          <p style="margin-top: 10px">正在验证数据...</p>
        </div>

        <div v-else>
          <el-result
            :icon="validationResult.valid ? 'success' : 'error'"
            :title="validationResult.message"
            :sub-title="validationResult.valid ? '数据验证通过，可以开始导入' : '数据验证失败，请修正后重试'"
          >
            <template #extra>
              <div v-if="!validationResult.valid && validationResult.errors && validationResult.errors.length > 0">
                <el-alert
                  title="验证错误详情"
                  type="error"
                  :closable="false"
                >
                  <ul style="margin: 0; padding-left: 20px">
                    <li v-for="(error, index) in validationResult.errors.slice(0, 10)" :key="index">
                      {{ error }}
                    </li>
                    <li v-if="validationResult.errors.length > 10">
                      ...还有 {{ validationResult.errors.length - 10 }} 个错误
                    </li>
                  </ul>
                </el-alert>
              </div>
            </template>
          </el-result>
        </div>
      </div>

      <!-- 第四步：完成导入 -->
      <div v-if="importStep === 3" class="import-step-content">
        <div v-if="importing" style="text-align: center; padding: 40px">
          <el-icon class="is-loading" :size="40"><loading /></el-icon>
          <p style="margin-top: 10px">正在导入数据...</p>
        </div>

        <div v-else>
          <el-result
            :icon="importResult.success ? 'success' : 'error'"
            :title="importResult.message"
          >
            <template #extra>
              <div v-if="importResult.success">
                <el-descriptions :column="2" border>
                  <el-descriptions-item label="成功数量">
                    {{ importResult.successCount }} 条
                  </el-descriptions-item>
                  <el-descriptions-item label="失败数量">
                    {{ importResult.errorCount }} 条
                  </el-descriptions-item>
                </el-descriptions>

                <div v-if="importResult.errorCount > 0" style="margin-top: 20px">
                  <el-alert
                    title="导入错误详情"
                    type="warning"
                    :closable="false"
                  >
                    <ul style="margin: 0; padding-left: 20px">
                      <li v-for="(error, index) in importResult.errors.slice(0, 10)" :key="index">
                        {{ error }}
                      </li>
                      <li v-if="importResult.errors.length > 10">
                        ...还有 {{ importResult.errors.length - 10 }} 个错误
                      </li>
                    </ul>
                  </el-alert>
                </div>
              </div>
            </template>
          </el-result>
        </div>
      </div>

      <template #footer>
        <div v-if="importStep === 0">
          <el-button @click="importDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="nextStep" :disabled="!importForm.dataType">
            下一步
          </el-button>
        </div>
        <div v-else-if="importStep === 1">
          <el-button @click="previousStep">上一步</el-button>
          <el-button type="primary" @click="validateFile" :disabled="!importForm.file">
            验证数据
          </el-button>
        </div>
        <div v-else-if="importStep === 2">
          <el-button @click="previousStep">上一步</el-button>
          <el-button type="primary" @click="startImport" :disabled="!validationResult.valid">
            开始导入
          </el-button>
        </div>
        <div v-else-if="importStep === 3">
          <el-button @click="resetImport">重新导入</el-button>
          <el-button type="primary" @click="importDialogVisible = false">
            完成
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Upload, Download, Loading, UploadFilled } from '@element-plus/icons-vue'
import axios from 'axios'

const emit = defineEmits(['import-start', 'import-success', 'import-error'])

const importDialogVisible = ref(false)
const importStep = ref(0)
const importing = ref(false)
const validating = ref(false)
const uploadRef = ref(null)

const importForm = reactive({
  dataType: '',
  categoryId: null,
  file: null
})

const validationResult = reactive({
  valid: false,
  message: '',
  errors: []
})

const importResult = reactive({
  success: false,
  message: '',
  successCount: 0,
  errorCount: 0,
  errors: []
})

const dataTypeOptions = ref([])
const categoryOptions = ref([])

// 初始化
onMounted(async () => {
  await loadDataTypeOptions()
  await loadCategoryOptions()
})

// 加载数据类型选项
const loadDataTypeOptions = async () => {
  try {
    const res = await axios.get('/api/import/data-types')
    if (res.data.code === 200) {
      dataTypeOptions.value = res.data.data.dataTypes
    }
  } catch (error) {
    console.error('加载数据类型失败:', error)
  }
}

// 加载分类选项
const loadCategoryOptions = async () => {
  try {
    const res = await axios.get('/api/query/filter-options/category')
    if (res.data.code === 200) {
      categoryOptions.value = res.data.data.options
    }
  } catch (error) {
    console.error('加载分类选项失败:', error)
  }
}

// 显示导入对话框
const showImportDialog = () => {
  importDialogVisible.value = true
  importStep.value = 0
  resetImport()
}

// 下载模板
const downloadTemplate = async () => {
  try {
    const url = `/api/import/template/${importForm.dataType}`
    const link = document.createElement('a')
    link.href = url
    link.download = `${importForm.dataType}_导入模板.xlsx`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    ElMessage.success('模板下载成功')
  } catch (error) {
    ElMessage.error('模板下载失败：' + (error.message || '未知错误'))
  }
}

// 文件变化处理
const handleFileChange = (file) => {
  importForm.file = file.raw
}

// 文件移除处理
const handleFileRemove = () => {
  importForm.file = null
}

// 下一步
const nextStep = () => {
  importStep.value++
}

// 上一步
const previousStep = () => {
  importStep.value--
}

// 验证文件
const validateFile = async () => {
  try {
    validating.value = true
    
    const formData = new FormData()
    formData.append('file', importForm.file)
    formData.append('dataType', importForm.dataType)

    const res = await axios.post('/api/import/validate', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })

    if (res.data.code === 200) {
      Object.assign(validationResult, res.data.data)
      importStep.value++
    } else {
      ElMessage.error('验证失败：' + res.data.message)
    }
  } catch (error) {
    console.error('验证失败:', error)
    ElMessage.error('验证失败：' + (error.message || '未知错误'))
    validationResult.valid = false
    validationResult.message = '验证失败'
    validationResult.errors = [error.message]
    importStep.value++
  } finally {
    validating.value = false
  }
}

// 开始导入
const startImport = async () => {
  try {
    importing.value = true
    emit('import-start')

    const formData = new FormData()
    formData.append('file', importForm.file)

    let url = ''
    switch (importForm.dataType) {
      case 'employee-profile':
        url = '/api/import/employee-profile'
        break
      case 'user':
        url = '/api/import/users'
        break
      case 'department':
        url = '/api/import/departments'
        break
      case 'analysis-data':
        url = `/api/import/analysis-data?categoryId=${importForm.categoryId}`
        break
      default:
        throw new Error('不支持的数据类型')
    }

    const res = await axios.post(url, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })

    if (res.data.code === 200) {
      Object.assign(importResult, res.data.data)
      importResult.success = true
      emit('import-success', importResult)
      ElMessage.success('导入完成')
    } else {
      throw new Error(res.data.message)
    }
  } catch (error) {
    console.error('导入失败:', error)
    importResult.success = false
    importResult.message = '导入失败'
    importResult.errors = [error.message]
    emit('import-error', error)
    ElMessage.error('导入失败：' + (error.message || '未知错误'))
  } finally {
    importing.value = false
    importStep.value++
  }
}

// 重置导入
const resetImport = () => {
  importForm.dataType = ''
  importForm.categoryId = null
  importForm.file = null
  
  validationResult.valid = false
  validationResult.message = ''
  validationResult.errors = []
  
  importResult.success = false
  importResult.message = ''
  importResult.successCount = 0
  importResult.errorCount = 0
  importResult.errors = []
  
  if (uploadRef.value) {
    uploadRef.value.clearFiles()
  }
}
</script>

<style scoped>
.data-import-container {
  display: inline-block;
}

.import-step-content {
  min-height: 300px;
  padding: 20px 0;
}

.upload-demo {
  margin-top: 20px;
}

:deep(.el-upload-dragger) {
  padding: 40px;
}
</style>
