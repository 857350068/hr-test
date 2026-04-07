<template>
  <div class="file-upload">
    <el-upload
      ref="uploadRef"
      :action="uploadUrl"
      :headers="uploadHeaders"
      :multiple="multiple"
      :limit="limit"
      :file-list="fileList"
      :before-upload="handleBeforeUpload"
      :on-success="handleSuccess"
      :on-error="handleError"
      :on-remove="handleRemove"
      :on-preview="handlePreview"
      :accept="acceptTypes"
      :list-type="listType"
      :auto-upload="autoUpload"
    >
      <template v-if="listType === 'picture-card'">
        <el-icon><plus /></el-icon>
      </template>
      <template v-else>
        <el-button type="primary">
          <el-icon><upload /></el-icon>
          {{ buttonText }}
        </el-button>
      </template>
      <template #tip>
        <div class="el-upload__tip" v-if="showTip">
          {{ tipText }}
        </div>
      </template>
    </el-upload>

    <!-- 图片预览对话框 -->
    <el-dialog v-model="previewVisible" title="图片预览" width="600px">
      <img :src="previewUrl" style="width: 100%" />
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus, Upload } from '@element-plus/icons-vue'

const props = defineProps({
  // 上传地址
  action: {
    type: String,
    default: '/api/file/upload'
  },
  // 是否支持多选
  multiple: {
    type: Boolean,
    default: false
  },
  // 最大上传数量
  limit: {
    type: Number,
    default: 5
  },
  // 文件类型限制
  accept: {
    type: String,
    default: ''
  },
  // 文件大小限制(MB)
  maxSize: {
    type: Number,
    default: 10
  },
  // 列表类型
  listType: {
    type: String,
    default: 'text' // text | picture | picture-card
  },
  // 是否自动上传
  autoUpload: {
    type: Boolean,
    default: true
  },
  // 按钮文本
  buttonText: {
    type: String,
    default: '选择文件'
  },
  // 是否显示提示
  showTip: {
    type: Boolean,
    default: true
  },
  // 提示文本
  tip: {
    type: String,
    default: ''
  },
  // 初始文件列表
  modelValue: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue', 'success', 'error', 'remove'])

const uploadRef = ref(null)
const previewVisible = ref(false)
const previewUrl = ref('')
const fileList = ref(props.modelValue || [])

// 上传地址
const uploadUrl = computed(() => props.action)

// 上传请求头
const uploadHeaders = computed(() => ({
  Authorization: 'Bearer ' + localStorage.getItem('token')
}))

// 接受的文件类型
const acceptTypes = computed(() => props.accept)

// 提示文本
const tipText = computed(() => {
  if (props.tip) return props.tip
  const sizeText = `文件大小不超过 ${props.maxSize}MB`
  const typeText = props.accept ? `，仅支持 ${props.accept} 格式` : ''
  return sizeText + typeText
})

// 上传前校验
const handleBeforeUpload = (file) => {
  // 文件大小校验
  const isLtMaxSize = file.size / 1024 / 1024 < props.maxSize
  if (!isLtMaxSize) {
    ElMessage.error(`文件大小不能超过 ${props.maxSize}MB!`)
    return false
  }

  // 文件类型校验
  if (props.accept) {
    const acceptTypes = props.accept.split(',').map(type => type.trim())
    const fileType = '.' + file.name.split('.').pop().toLowerCase()
    if (!acceptTypes.some(type => type.toLowerCase() === fileType)) {
      ElMessage.error(`仅支持 ${props.accept} 格式的文件!`)
      return false
    }
  }

  return true
}

// 上传成功
const handleSuccess = (response, file, fileList) => {
  if (response.code === 200) {
    ElMessage.success('上传成功')
    emit('success', response.data, file, fileList)
    emit('update:modelValue', fileList)
  } else {
    ElMessage.error(response.message || '上传失败')
    emit('error', response, file, fileList)
  }
}

// 上传失败
const handleError = (error, file, fileList) => {
  ElMessage.error('上传失败: ' + error.message)
  emit('error', error, file, fileList)
}

// 删除文件
const handleRemove = (file, fileList) => {
  emit('remove', file, fileList)
  emit('update:modelValue', fileList)
}

// 预览文件
const handlePreview = (file) => {
  if (file.url || file.response?.data?.url) {
    previewUrl.value = file.url || file.response.data.url
    previewVisible.value = true
  }
}

// 手动上传
const submit = () => {
  uploadRef.value?.submit()
}

// 清空文件列表
const clearFiles = () => {
  uploadRef.value?.clearFiles()
  fileList.value = []
  emit('update:modelValue', [])
}

// 暴露方法
defineExpose({
  submit,
  clearFiles
})
</script>

<style scoped>
.file-upload {
  width: 100%;
}

.el-upload__tip {
  color: #999;
  font-size: 12px;
  margin-top: 7px;
}
</style>
