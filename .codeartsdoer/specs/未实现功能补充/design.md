# 人力资源数据中心 - 技术设计文档

## 文档信息
- **项目名称**: 人力资源数据中心系统 - 未实现功能补充
- **文档版本**: V1.0
- **创建日期**: 2025-01-13
- **基于文档**: spec.md (需求规格说明书)
- **技术栈**: Vue 3 + Spring Boot + MySQL + Hive

---

## 一、系统架构设计

### 1.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                         前端层 (Vue 3)                           │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ 员工管理  │  │ 薪酬管理  │  │ 绩效管理  │  │ 培训管理  │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ 数据分析  │  │ 系统管理  │  │ 消息中心  │  │ 文件服务  │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────────────────┘
                              ↓ Axios HTTP
┌─────────────────────────────────────────────────────────────────┐
│                      后端层 (Spring Boot)                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │Controller │  │  Service  │  │   DAO    │  │  Aspect  │        │
│  │   层      │→│    层     │→│   层     │  │  (AOP)   │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ 文件处理  │  │ Excel处理 │  │ 日志记录  │  │ 消息推送  │        │
│  │  服务    │  │   服务    │  │   服务    │  │   服务    │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────────────────┘
                              ↓ JDBC
┌─────────────────────────────────────────────────────────────────┐
│                        数据层                                    │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐         ┌──────────────────┐             │
│  │   MySQL (业务库)   │         │  Hive (数据仓库)  │             │
│  │  - 业务数据表      │         │  - 维度表         │             │
│  │  - 日志表         │         │  - 事实表         │             │
│  │  - 配置表         │         │  - 聚合表         │             │
│  └──────────────────┘         └──────────────────┘             │
│  ┌──────────────────┐         ┌──────────────────┐             │
│  │  文件存储 (本地/OSS) │       │   Redis (缓存)    │             │
│  └──────────────────┘         └──────────────────┘             │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 技术选型

| 层次 | 技术 | 版本 | 用途 |
|-----|------|------|------|
| 前端框架 | Vue 3 | 3.x | 响应式UI框架 |
| UI组件库 | Element Plus | 2.x | UI组件 |
| 图表库 | ECharts | 5.x | 数据可视化 |
| Excel处理 | xlsx / exceljs | 最新 | Excel导入导出 |
| 文件上传 | el-upload | - | 文件上传组件 |
| 后端框架 | Spring Boot | 2.7.18 | 应用框架 |
| ORM框架 | MyBatis Plus | 3.5.3.1 | 数据访问 |
| AOP | Spring AOP | - | 日志切面 |
| WebSocket | Spring WebSocket | - | 实时消息 |
| 邮件 | Spring Mail | - | 邮件发送 |
| 定时任务 | Spring Task | - | 定时任务 |
| 业务数据库 | MySQL | 8.0 | 业务数据存储 |
| 数据仓库 | Hive | 3.1.3 | 大数据分析 |
| 缓存 | Redis | 7.x | 数据缓存 |

---

## 二、前端模块设计

### 2.1 API导入路径修复设计

#### 2.1.1 问题分析
- **当前问题**: 3个API文件导入路径错误
- **错误路径**: `import request from '@/utils/request'`
- **正确路径**: `import request from './request'`

#### 2.1.2 修复方案

**文件**: `frontend/src/api/analysis.js`
```javascript
// 修改前
import request from '@/utils/request'

// 修改后
import request from './request'
```

**文件**: `frontend/src/api/warning.js`
```javascript
// 修改前
import request from '@/utils/request'

// 修改后
import request from './request'
```

**文件**: `frontend/src/api/category.js`
```javascript
// 修改前
import request from '@/utils/request'

// 修改后
import request from './request'
```

#### 2.1.3 验证方案
- 启动前端开发服务器
- 访问数据分析页面，检查控制台无404错误
- 访问预警信息页面，验证数据正常加载
- 访问数据分类管理页面，执行CRUD操作验证

---

### 2.2 Excel导出功能设计

#### 2.2.1 技术方案

**依赖安装**:
```bash
npm install xlsx file-saver
# 或
npm install exceljs file-saver
```

**工具类设计**: `frontend/src/utils/excel.js`
```javascript
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

/**
 * 导出数据为Excel文件
 * @param {Array} data - 数据数组
 * @param {String} filename - 文件名
 * @param {Object} options - 配置选项
 */
export function exportToExcel(data, filename, options = {}) {
  const {
    sheetName = 'Sheet1',
    headerMap = null,  // 字段映射 { field: '显示名称' }
    excludeFields = [] // 排除字段
  } = options

  // 数据处理
  let exportData = data
  
  // 排除指定字段
  if (excludeFields.length > 0) {
    exportData = data.map(item => {
      const newItem = { ...item }
      excludeFields.forEach(field => delete newItem[field])
      return newItem
    })
  }
  
  // 字段映射（重命名表头）
  if (headerMap) {
    exportData = exportData.map(item => {
      const newItem = {}
      Object.keys(item).forEach(key => {
        const newKey = headerMap[key] || key
        newItem[newKey] = item[key]
      })
      return newItem
    })
  }
  
  // 创建工作表
  const ws = XLSX.utils.json_to_sheet(exportData)
  
  // 设置列宽
  const colWidths = []
  if (exportData.length > 0) {
    Object.keys(exportData[0]).forEach(key => {
      colWidths.push({ wch: Math.max(key.length, 15) })
    })
    ws['!cols'] = colWidths
  }
  
  // 创建工作簿
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, sheetName)
  
  // 生成文件
  const wbout = XLSX.write(wb, { bookType: 'xlsx', type: 'array' })
  const blob = new Blob([wbout], { type: 'application/octet-stream' })
  
  // 下载文件
  saveAs(blob, `${filename}.xlsx`)
}

/**
 * 导出大数据量Excel（分批处理）
 * @param {Function} fetchData - 数据获取函数
 * @param {String} filename - 文件名
 * @param {Number} batchSize - 每批数量
 */
export async function exportLargeExcel(fetchData, filename, batchSize = 10000) {
  const wb = XLSX.utils.book_new()
  let page = 1
  let hasMore = true
  
  while (hasMore) {
    const data = await fetchData(page, batchSize)
    if (data.length === 0) {
      hasMore = false
      break
    }
    
    const ws = XLSX.utils.json_to_sheet(data)
    XLSX.utils.book_append_sheet(wb, ws, `Sheet${page}`)
    
    if (data.length < batchSize) {
      hasMore = false
    }
    page++
  }
  
  const wbout = XLSX.write(wb, { bookType: 'xlsx', type: 'array' })
  const blob = new Blob([wbout], { type: 'application/octet-stream' })
  saveAs(blob, `${filename}.xlsx`)
}
```

#### 2.2.2 员工信息导出实现

**文件**: `frontend/src/views/employee/Index.vue`

```javascript
// 导入工具
import { exportToExcel } from '@/utils/excel'

// 导出Excel方法
const handleExportExcel = async () => {
  try {
    ElMessage.info('正在导出，请稍候...')
    
    // 获取导出数据（可从当前表格数据或重新请求）
    const params = {
      ...searchForm,
      page: 1,
      size: 10000 // 导出最大10000条
    }
    const res = await getEmployeeList(params)
    const data = res.data.records
    
    // 字段映射
    const headerMap = {
      empNo: '员工编号',
      empName: '员工姓名',
      gender: '性别',
      department: '部门',
      position: '职位',
      phone: '联系电话',
      email: '邮箱',
      salary: '薪资',
      status: '状态',
      hireDate: '入职日期',
      education: '学历'
    }
    
    // 数据转换
    const exportData = data.map(item => ({
      ...item,
      gender: item.gender === 1 ? '男' : '女',
      status: item.status === 1 ? '在职' : item.status === 2 ? '试用' : '离职',
      salary: item.salary ? `¥${item.salary.toLocaleString()}` : '¥0'
    }))
    
    // 导出
    const filename = `员工列表_${new Date().toISOString().slice(0, 10)}`
    exportToExcel(exportData, filename, { headerMap })
    
    ElMessage.success('导出成功')
  } catch (error) {
    console.error('导出失败:', error)
    ElMessage.error('导出失败')
  }
}
```

#### 2.2.3 薪资单导出实现

**文件**: `frontend/src/views/salary/Index.vue`

```javascript
const handleBatchExport = async () => {
  if (selectedPayments.value.length === 0) {
    ElMessage.warning('请先选择要导出的薪资记录')
    return
  }
  
  try {
    const headerMap = {
      empId: '员工ID',
      year: '年度',
      month: '月份',
      basicSalary: '基本工资',
      performanceSalary: '绩效工资',
      positionAllowance: '岗位津贴',
      totalGrossSalary: '应发工资',
      socialInsurancePersonal: '社保个人',
      housingFundPersonal: '公积金个人',
      incomeTax: '个人所得税',
      totalNetSalary: '实发工资',
      paymentStatus: '发放状态'
    }
    
    const exportData = selectedPayments.value.map(item => ({
      ...item,
      paymentStatus: item.paymentStatus === 0 ? '未发放' : '已发放'
    }))
    
    const filename = `薪资单_${exportData[0].year}年${exportData[0].month}月`
    exportToExcel(exportData, filename, { headerMap })
    
    ElMessage.success('导出成功')
  } catch (error) {
    ElMessage.error('导出失败')
  }
}
```

---

### 2.3 Excel导入功能设计

#### 2.3.1 导入流程设计

```
用户点击"批量导入"
    ↓
显示导入对话框
    ↓
用户下载Excel模板
    ↓
用户填写Excel文件
    ↓
用户上传Excel文件
    ↓
前端解析Excel数据
    ↓
数据格式校验
    ↓
显示数据预览
    ↓
用户确认导入
    ↓
调用后端API批量保存
    ↓
显示导入结果
```

#### 2.3.2 工具类设计: `frontend/src/utils/excel-import.js`

```javascript
import * as XLSX from 'xlsx'

/**
 * 解析Excel文件
 * @param {File} file - 文件对象
 * @returns {Promise<Array>} 解析后的数据
 */
export function parseExcel(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    
    reader.onload = (e) => {
      try {
        const data = new Uint8Array(e.target.result)
        const workbook = XLSX.read(data, { type: 'array' })
        
        // 读取第一个工作表
        const firstSheetName = workbook.SheetNames[0]
        const worksheet = workbook.Sheets[firstSheetName]
        
        // 转换为JSON
        const jsonData = XLSX.utils.sheet_to_json(worksheet)
        
        resolve(jsonData)
      } catch (error) {
        reject(error)
      }
    }
    
    reader.onerror = (error) => reject(error)
    reader.readAsArrayBuffer(file)
  })
}

/**
 * 数据校验
 * @param {Array} data - 数据数组
 * @param {Object} rules - 校验规则
 * @returns {Object} { valid: boolean, errors: Array }
 */
export function validateData(data, rules) {
  const errors = []
  
  data.forEach((item, index) => {
    Object.keys(rules).forEach(field => {
      const rule = rules[field]
      const value = item[field]
      
      // 必填校验
      if (rule.required && !value) {
        errors.push({
          row: index + 2, // Excel行号（从2开始，第1行是表头）
          field,
          message: `${field}不能为空`
        })
      }
      
      // 格式校验
      if (rule.pattern && value && !rule.pattern.test(value)) {
        errors.push({
          row: index + 2,
          field,
          message: `${field}格式不正确`
        })
      }
      
      // 自定义校验
      if (rule.validator) {
        const result = rule.validator(value, item)
        if (result !== true) {
          errors.push({
            row: index + 2,
            field,
            message: result
          })
        }
      }
    })
  })
  
  return {
    valid: errors.length === 0,
    errors
  }
}
```

#### 2.3.3 员工信息导入实现

**文件**: `frontend/src/views/employee/Index.vue`

```vue
<template>
  <!-- 导入对话框 -->
  <el-dialog v-model="importDialogVisible" title="批量导入员工" width="800px">
    <el-steps :active="importStep" finish-status="success">
      <el-step title="下载模板"></el-step>
      <el-step title="上传文件"></el-step>
      <el-step title="数据预览"></el-step>
      <el-step title="导入结果"></el-step>
    </el-steps>
    
    <!-- Step 1: 下载模板 -->
    <div v-if="importStep === 0" class="import-step">
      <el-button type="primary" @click="downloadTemplate">
        <el-icon><Download /></el-icon>
        下载Excel模板
      </el-button>
    </div>
    
    <!-- Step 2: 上传文件 -->
    <div v-if="importStep === 1" class="import-step">
      <el-upload
        ref="uploadRef"
        :auto-upload="false"
        :limit="1"
        accept=".xlsx,.xls"
        :on-change="handleFileChange"
      >
        <el-button type="primary">选择Excel文件</el-button>
        <template #tip>
          <div class="el-upload__tip">
            只能上传 xlsx/xls 文件，且不超过 10MB
          </div>
        </template>
      </el-upload>
    </div>
    
    <!-- Step 3: 数据预览 -->
    <div v-if="importStep === 2" class="import-step">
      <el-alert v-if="importErrors.length > 0" type="error" :closable="false">
        <template #title>
          发现 {{ importErrors.length }} 条错误数据
        </template>
        <div v-for="error in importErrors.slice(0, 5)" :key="error.row">
          第{{ error.row }}行: {{ error.message }}
        </div>
      </el-alert>
      
      <el-table :data="importPreviewData" max-height="400">
        <el-table-column prop="empNo" label="员工编号" />
        <el-table-column prop="empName" label="员工姓名" />
        <el-table-column prop="department" label="部门" />
        <el-table-column prop="position" label="职位" />
        <!-- 更多列... -->
      </el-table>
    </div>
    
    <!-- Step 4: 导入结果 -->
    <div v-if="importStep === 3" class="import-step">
      <el-result
        :icon="importResult.success ? 'success' : 'error'"
        :title="importResult.title"
        :sub-title="importResult.message"
      />
    </div>
    
    <template #footer>
      <el-button @click="importDialogVisible = false">取消</el-button>
      <el-button v-if="importStep > 0" @click="importStep--">上一步</el-button>
      <el-button v-if="importStep < 3" type="primary" @click="nextImportStep">
        下一步
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { parseExcel, validateData } from '@/utils/excel-import'

const importDialogVisible = ref(false)
const importStep = ref(0)
const importFile = ref(null)
const importPreviewData = ref([])
const importErrors = ref([])
const importResult = ref({})

// 下载模板
const downloadTemplate = () => {
  const templateData = [{
    empNo: 'EMP001',
    empName: '张三',
    gender: '男',
    department: '技术部',
    position: '工程师',
    phone: '13800138000',
    email: 'zhangsan@example.com',
    hireDate: '2024-01-01',
    education: '本科'
  }]
  
  exportToExcel(templateData, '员工导入模板')
  importStep.value = 1
}

// 文件选择
const handleFileChange = (file) => {
  importFile.value = file.raw
}

// 下一步
const nextImportStep = async () => {
  if (importStep.value === 1) {
    // 解析Excel
    try {
      const data = await parseExcel(importFile.value)
      
      // 数据校验
      const rules = {
        empName: { required: true },
        phone: { 
          required: true, 
          pattern: /^1[3-9]\d{9}$/ 
        },
        email: { 
          required: true, 
          pattern: /^[^\s@]+@[^\s@]+\.[^\s@]+$/ 
        }
      }
      
      const validation = validateData(data, rules)
      importErrors.value = validation.errors
      importPreviewData.value = data
      
      importStep.value = 2
    } catch (error) {
      ElMessage.error('文件解析失败')
    }
  } else if (importStep.value === 2) {
    // 执行导入
    try {
      const res = await batchImportEmployees(importPreviewData.value)
      importResult.value = {
        success: true,
        title: '导入成功',
        message: `成功导入 ${res.data.success} 条，失败 ${res.data.failed} 条`
      }
      importStep.value = 3
    } catch (error) {
      importResult.value = {
        success: false,
        title: '导入失败',
        message: error.message
      }
      importStep.value = 3
    }
  }
}
</script>
```

---

### 2.4 文件上传功能设计

#### 2.4.1 上传组件封装

**文件**: `frontend/src/components/FileUpload.vue`

```vue
<template>
  <el-upload
    ref="uploadRef"
    :action="uploadUrl"
    :headers="uploadHeaders"
    :multiple="multiple"
    :limit="limit"
    :file-list="fileList"
    :accept="acceptTypes"
    :before-upload="handleBeforeUpload"
    :on-success="handleSuccess"
    :on-error="handleError"
    :on-progress="handleProgress"
    :on-preview="handlePreview"
    :on-remove="handleRemove"
    :auto-upload="autoUpload"
    :data="extraData"
  >
    <el-button type="primary">
      <el-icon><Upload /></el-icon>
      {{ buttonText }}
    </el-button>
    
    <template #tip>
      <div class="el-upload__tip">
        {{ tipText }}
      </div>
    </template>
  </el-upload>
  
  <!-- 图片预览对话框 -->
  <el-dialog v-model="previewVisible" title="文件预览">
    <img v-if="isImage" :src="previewUrl" style="width: 100%" />
    <iframe v-else :src="previewUrl" style="width: 100%; height: 500px" />
  </el-dialog>
</template>

<script setup>
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'

const props = defineProps({
  uploadUrl: { type: String, default: '/api/upload' },
  multiple: { type: Boolean, default: false },
  limit: { type: Number, default: 5 },
  maxSize: { type: Number, default: 10 }, // MB
  accept: { type: String, default: '' },
  autoUpload: { type: Boolean, default: true },
  buttonText: { type: String, default: '点击上传' },
  tipText: { type: String, default: '' },
  extraData: { type: Object, default: () => ({}) }
})

const emit = defineEmits(['success', 'error', 'remove'])

const uploadRef = ref(null)
const fileList = ref([])
const previewVisible = ref(false)
const previewUrl = ref('')

// 上传请求头
const uploadHeaders = computed(() => ({
  Authorization: `Bearer ${localStorage.getItem('token')}`
}))

// 接受的文件类型
const acceptTypes = computed(() => {
  if (props.accept) return props.accept
  return '.jpg,.jpeg,.png,.gif,.pdf,.doc,.docx,.xls,.xlsx'
})

// 是否是图片
const isImage = computed(() => {
  const imageTypes = ['.jpg', '.jpeg', '.png', '.gif']
  return imageTypes.some(type => previewUrl.value.toLowerCase().endsWith(type))
})

// 上传前校验
const handleBeforeUpload = (file) => {
  // 文件大小校验
  const isLtMaxSize = file.size / 1024 / 1024 < props.maxSize
  if (!isLtMaxSize) {
    ElMessage.error(`文件大小不能超过 ${props.maxSize}MB`)
    return false
  }
  
  // 文件类型校验
  if (props.accept) {
    const acceptTypes = props.accept.split(',').map(t => t.trim())
    const fileType = '.' + file.name.split('.').pop().toLowerCase()
    if (!acceptTypes.includes(fileType)) {
      ElMessage.error(`只能上传 ${props.accept} 格式的文件`)
      return false
    }
  }
  
  return true
}

// 上传成功
const handleSuccess = (response, file) => {
  if (response.code === 200) {
    ElMessage.success('上传成功')
    emit('success', response.data)
  } else {
    ElMessage.error(response.message || '上传失败')
    emit('error', response)
  }
}

// 上传失败
const handleError = (error, file) => {
  ElMessage.error('上传失败')
  emit('error', error)
}

// 上传进度
const handleProgress = (event, file) => {
  console.log(`上传进度: ${event.percent}%`)
}

// 文件预览
const handlePreview = (file) => {
  previewUrl.value = file.url || file.response?.data?.url
  previewVisible.value = true
}

// 文件移除
const handleRemove = (file) => {
  emit('remove', file)
}
</script>
```

#### 2.4.2 员工照片上传实现

```vue
<template>
  <el-form-item label="员工照片">
    <el-upload
      class="avatar-uploader"
      action="/api/upload/image"
      :headers="uploadHeaders"
      :show-file-list="false"
      :before-upload="beforeAvatarUpload"
      :on-success="handleAvatarSuccess"
    >
      <img v-if="formData.photo" :src="formData.photo" class="avatar" />
      <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
    </el-upload>
  </el-form-item>
</template>

<script setup>
const beforeAvatarUpload = (file) => {
  const isJPG = file.type === 'image/jpeg'
  const isPNG = file.type === 'image/png'
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isJPG && !isPNG) {
    ElMessage.error('上传头像图片只能是 JPG/PNG 格式!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('上传头像图片大小不能超过 2MB!')
    return false
  }
  return true
}

const handleAvatarSuccess = (response) => {
  if (response.code === 200) {
    formData.photo = response.data.url
    ElMessage.success('照片上传成功')
  }
}
</script>

<style scoped>
.avatar-uploader .avatar {
  width: 178px;
  height: 178px;
  display: block;
}

.avatar-uploader .el-upload {
  border: 1px dashed var(--el-border-color);
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: var(--el-transition-duration-fast);
}

.avatar-uploader .el-upload:hover {
  border-color: var(--el-color-primary);
}

.el-icon.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 178px;
  height: 178px;
  text-align: center;
}
</style>
```

---

## 三、后端模块设计

### 3.1 文件上传服务设计

#### 3.1.1 文件上传Controller

**文件**: `backend/src/main/java/com/hr/datacenter/controller/FileUploadController.java`

```java
package com.hr.datacenter.controller;

import com.hr.datacenter.common.Result;
import com.hr.datacenter.service.FileUploadService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

/**
 * 文件上传控制器
 */
@Slf4j
@RestController
@RequestMapping("/upload")
@CrossOrigin(origins = "*")
public class FileUploadController {

    @Autowired
    private FileUploadService fileUploadService;

    /**
     * 上传图片
     */
    @PostMapping("/image")
    public Result<Map<String, String>> uploadImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam(required = false) String type) {
        log.info("上传图片，文件名：{}，类型：{}", file.getOriginalFilename(), type);
        Map<String, String> result = fileUploadService.uploadImage(file, type);
        return Result.success(result);
    }

    /**
     * 上传附件
     */
    @PostMapping("/attachment")
    public Result<Map<String, String>> uploadAttachment(
            @RequestParam("file") MultipartFile file,
            @RequestParam(required = false) String category) {
        log.info("上传附件，文件名：{}，分类：{}", file.getOriginalFilename(), category);
        Map<String, String> result = fileUploadService.uploadAttachment(file, category);
        return Result.success(result);
    }

    /**
     * 上传Excel文件
     */
    @PostMapping("/excel")
    public Result<Map<String, Object>> uploadExcel(
            @RequestParam("file") MultipartFile file) {
        log.info("上传Excel文件，文件名：{}", file.getOriginalFilename());
        Map<String, Object> result = fileUploadService.uploadExcel(file);
        return Result.success(result);
    }
}
```

#### 3.1.2 文件上传Service

**文件**: `backend/src/main/java/com/hr/datacenter/service/FileUploadService.java`

```java
package com.hr.datacenter.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import lombok.extern.slf4j.Slf4j;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * 文件上传服务
 */
@Slf4j
@Service
public class FileUploadService {

    @Value("${file.upload.path:/data/uploads}")
    private String uploadPath;

    @Value("${file.upload.max-size:10485760}") // 10MB
    private long maxFileSize;

    /**
     * 上传图片
     */
    public Map<String, String> uploadImage(MultipartFile file, String type) {
        // 校验文件类型
        String contentType = file.getContentType();
        if (!isImage(contentType)) {
            throw new RuntimeException("只能上传图片文件");
        }

        // 校验文件大小
        if (file.getSize() > maxFileSize) {
            throw new RuntimeException("文件大小超过限制");
        }

        // 生成文件路径
        String datePath = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
        String fileName = generateFileName(file.getOriginalFilename());
        String relativePath = "images/" + datePath + "/" + fileName;
        
        // 保存文件
        saveFile(file, relativePath);

        // 返回结果
        Map<String, String> result = new HashMap<>();
        result.put("url", "/uploads/" + relativePath);
        result.put("fileName", fileName);
        result.put("originalName", file.getOriginalFilename());
        result.put("size", String.valueOf(file.getSize()));
        
        return result;
    }

    /**
     * 上传附件
     */
    public Map<String, String> uploadAttachment(MultipartFile file, String category) {
        // 校验文件大小
        if (file.getSize() > maxFileSize) {
            throw new RuntimeException("文件大小超过限制");
        }

        // 生成文件路径
        String datePath = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
        String fileName = generateFileName(file.getOriginalFilename());
        String categoryPath = category != null ? category + "/" : "";
        String relativePath = "attachments/" + categoryPath + datePath + "/" + fileName;
        
        // 保存文件
        saveFile(file, relativePath);

        // 返回结果
        Map<String, String> result = new HashMap<>();
        result.put("url", "/uploads/" + relativePath);
        result.put("fileName", fileName);
        result.put("originalName", file.getOriginalFilename());
        result.put("size", String.valueOf(file.getSize()));
        
        return result;
    }

    /**
     * 上传Excel文件
     */
    public Map<String, Object> uploadExcel(MultipartFile file) {
        // 校验文件类型
        String fileName = file.getOriginalFilename();
        if (!fileName.endsWith(".xlsx") && !fileName.endsWith(".xls")) {
            throw new RuntimeException("只能上传Excel文件");
        }

        // 校验文件大小
        if (file.getSize() > maxFileSize) {
            throw new RuntimeException("文件大小超过限制");
        }

        // 生成文件路径
        String datePath = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
        String newFileName = generateFileName(fileName);
        String relativePath = "excel/" + datePath + "/" + newFileName;
        
        // 保存文件
        saveFile(file, relativePath);

        // 返回结果
        Map<String, Object> result = new HashMap<>();
        result.put("url", "/uploads/" + relativePath);
        result.put("fileName", newFileName);
        result.put("originalName", fileName);
        result.put("size", file.getSize());
        result.put("path", uploadPath + "/" + relativePath);
        
        return result;
    }

    /**
     * 保存文件
     */
    private void saveFile(MultipartFile file, String relativePath) {
        try {
            Path path = Paths.get(uploadPath, relativePath);
            Files.createDirectories(path.getParent());
            file.transferTo(path.toFile());
            log.info("文件保存成功：{}", path);
        } catch (IOException e) {
            log.error("文件保存失败", e);
            throw new RuntimeException("文件保存失败");
        }
    }

    /**
     * 生成文件名
     */
    private String generateFileName(String originalName) {
        String extension = originalName.substring(originalName.lastIndexOf("."));
        return UUID.randomUUID().toString().replace("-", "") + extension;
    }

    /**
     * 判断是否是图片
     */
    private boolean isImage(String contentType) {
        return contentType != null && 
               (contentType.startsWith("image/jpeg") || 
                contentType.startsWith("image/png") || 
                contentType.startsWith("image/gif"));
    }
}
```

---

### 3.2 操作日志设计

#### 3.2.1 日志注解定义

**文件**: `backend/src/main/java/com/hr/datacenter/annotation/OperationLog.java`

```java
package com.hr.datacenter.annotation;

import java.lang.annotation.*;

/**
 * 操作日志注解
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface OperationLog {
    /**
     * 操作模块
     */
    String module() default "";

    /**
     * 操作类型
     */
    String type() default "";

    /**
     * 操作描述
     */
    String description() default "";
}
```

#### 3.2.2 日志切面实现

**文件**: `backend/src/main/java/com/hr/datacenter/aspect/OperationLogAspect.java`

```java
package com.hr.datacenter.aspect;

import com.hr.datacenter.annotation.OperationLog;
import com.hr.datacenter.entity.SysOperationLog;
import com.hr.datacenter.service.OperationLogService;
import com.hr.datacenter.util.IpUtil;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;
import java.util.Date;

/**
 * 操作日志切面
 */
@Slf4j
@Aspect
@Component
public class OperationLogAspect {

    @Autowired
    private OperationLogService operationLogService;

    @Around("@annotation(operationLog)")
    public Object around(ProceedingJoinPoint point, OperationLog operationLog) throws Throwable {
        long startTime = System.currentTimeMillis();
        
        // 执行方法
        Object result = point.proceed();
        
        // 记录日志
        try {
            saveLog(point, operationLog, result, System.currentTimeMillis() - startTime);
        } catch (Exception e) {
            log.error("记录操作日志失败", e);
        }
        
        return result;
    }

    /**
     * 保存日志
     */
    private void saveLog(ProceedingJoinPoint point, OperationLog operationLog, 
                         Object result, long duration) {
        // 获取请求信息
        ServletRequestAttributes attributes = 
            (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes == null) {
            return;
        }
        
        HttpServletRequest request = attributes.getRequest();
        
        // 构建日志对象
        SysOperationLog log = new SysOperationLog();
        log.setModule(operationLog.module());
        log.setType(operationLog.type());
        log.setDescription(operationLog.description());
        log.setMethod(((MethodSignature) point.getSignature()).getMethod().getName());
        log.setRequestUrl(request.getRequestURI());
        log.setRequestMethod(request.getMethod());
        log.setIp(IpUtil.getIpAddress(request));
        log.setUserAgent(request.getHeader("User-Agent"));
        log.setDuration(duration);
        log.setCreateTime(new Date());
        
        // 获取当前用户
        // TODO: 从Security上下文获取用户信息
        // log.setUserId(userId);
        // log.setUsername(username);
        
        // 保存日志
        operationLogService.save(log);
    }
}
```

#### 3.2.3 日志实体类

**文件**: `backend/src/main/java/com/hr/datacenter/entity/SysOperationLog.java`

```java
package com.hr.datacenter.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.util.Date;

/**
 * 操作日志实体
 */
@Data
@TableName("sys_operation_log")
public class SysOperationLog {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 操作模块 */
    private String module;

    /** 操作类型 */
    private String type;

    /** 操作描述 */
    private String description;

    /** 请求方法 */
    private String method;

    /** 请求URL */
    private String requestUrl;

    /** 请求方式 */
    private String requestMethod;

    /** 请求参数 */
    private String requestParams;

    /** 响应结果 */
    private String responseResult;

    /** 用户ID */
    private Long userId;

    /** 用户名 */
    private String username;

    /** IP地址 */
    private String ip;

    /** User-Agent */
    private String userAgent;

    /** 执行时长(ms) */
    private Long duration;

    /** 状态：0失败 1成功 */
    private Integer status;

    /** 错误信息 */
    private String errorMsg;

    /** 创建时间 */
    @TableField(fill = FieldFill.INSERT)
    private Date createTime;
}
```

#### 3.2.4 日志使用示例

```java
@RestController
@RequestMapping("/employee")
public class EmployeeController {

    @PostMapping("/add")
    @OperationLog(module = "员工管理", type = "新增", description = "新增员工信息")
    public Result<Void> addEmployee(@RequestBody Employee employee) {
        employeeService.save(employee);
        return Result.success();
    }

    @PutMapping("/update")
    @OperationLog(module = "员工管理", type = "修改", description = "修改员工信息")
    public Result<Void> updateEmployee(@RequestBody Employee employee) {
        employeeService.updateById(employee);
        return Result.success();
    }

    @DeleteMapping("/delete/{id}")
    @OperationLog(module = "员工管理", type = "删除", description = "删除员工信息")
    public Result<Void> deleteEmployee(@PathVariable Long id) {
        employeeService.removeById(id);
        return Result.success();
    }
}
```

---

### 3.3 消息通知设计

#### 3.3.1 WebSocket配置

**文件**: `backend/src/main/java/com/hr/datacenter/config/WebSocketConfig.java`

```java
package com.hr.datacenter.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.*;

/**
 * WebSocket配置
 */
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // 启用简单的内存消息代理
        config.enableSimpleBroker("/topic");
        // 设置应用程序目的地前缀
        config.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // 注册STOMP端点
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*")
                .withSockJS();
    }
}
```

#### 3.3.2 消息推送服务

**文件**: `backend/src/main/java/com/hr/datacenter/service/MessageService.java`

```java
package com.hr.datacenter.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import lombok.extern.slf4j.Slf4j;

import java.util.HashMap;
import java.util.Map;

/**
 * 消息推送服务
 */
@Slf4j
@Service
public class MessageService {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    /**
     * 推送消息给指定用户
     */
    public void sendToUser(Long userId, String type, Object content) {
        String destination = "/topic/user/" + userId;
        Map<String, Object> message = new HashMap<>();
        message.put("type", type);
        message.put("content", content);
        message.put("timestamp", System.currentTimeMillis());
        
        messagingTemplate.convertAndSend(destination, message);
        log.info("推送消息给用户{}：{}", userId, message);
    }

    /**
     * 推送消息给所有用户
     */
    public void sendToAll(String type, Object content) {
        String destination = "/topic/all";
        Map<String, Object> message = new HashMap<>();
        message.put("type", type);
        message.put("content", content);
        message.put("timestamp", System.currentTimeMillis());
        
        messagingTemplate.convertAndSend(destination, message);
        log.info("推送消息给所有用户：{}", message);
    }

    /**
     * 推送审批提醒
     */
    public void sendApprovalReminder(Long userId, String message) {
        Map<String, Object> content = new HashMap<>();
        content.put("message", message);
        content.put("url", "/leave/pending");
        
        sendToUser(userId, "APPROVAL_REMINDER", content);
    }

    /**
     * 推送系统公告
     */
    public void sendSystemNotice(String title, String content) {
        Map<String, Object> notice = new HashMap<>();
        notice.put("title", title);
        notice.put("content", content);
        
        sendToAll("SYSTEM_NOTICE", notice);
    }
}
```

#### 3.3.3 前端WebSocket连接

**文件**: `frontend/src/utils/websocket.js`

```javascript
import SockJS from 'sockjs-client'
import Stomp from 'stompjs'

class WebSocketService {
  constructor() {
    this.stompClient = null
    this.connected = false
    this.subscriptions = []
  }

  /**
   * 连接WebSocket
   */
  connect(userId, onMessage) {
    const socket = new SockJS('/ws')
    this.stompClient = Stomp.over(socket)
    
    this.stompClient.connect({}, (frame) => {
      console.log('WebSocket连接成功', frame)
      this.connected = true
      
      // 订阅个人消息
      this.subscribe(`/topic/user/${userId}`, onMessage)
      
      // 订阅全局消息
      this.subscribe('/topic/all', onMessage)
    }, (error) => {
      console.error('WebSocket连接失败', error)
      this.connected = false
      // 重连
      setTimeout(() => this.connect(userId, onMessage), 5000)
    })
  }

  /**
   * 订阅消息
   */
  subscribe(destination, callback) {
    if (this.stompClient && this.connected) {
      const subscription = this.stompClient.subscribe(destination, (message) => {
        const data = JSON.parse(message.body)
        callback(data)
      })
      this.subscriptions.push(subscription)
    }
  }

  /**
   * 断开连接
   */
  disconnect() {
    if (this.stompClient) {
      this.subscriptions.forEach(sub => sub.unsubscribe())
      this.stompClient.disconnect()
      this.connected = false
    }
  }
}

export default new WebSocketService()
```

---

## 四、数据库设计

### 4.1 操作日志表

```sql
CREATE TABLE `sys_operation_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `module` varchar(50) DEFAULT NULL COMMENT '操作模块',
  `type` varchar(20) DEFAULT NULL COMMENT '操作类型',
  `description` varchar(200) DEFAULT NULL COMMENT '操作描述',
  `method` varchar(100) DEFAULT NULL COMMENT '请求方法',
  `request_url` varchar(200) DEFAULT NULL COMMENT '请求URL',
  `request_method` varchar(10) DEFAULT NULL COMMENT '请求方式',
  `request_params` text COMMENT '请求参数',
  `response_result` text COMMENT '响应结果',
  `user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `username` varchar(50) DEFAULT NULL COMMENT '用户名',
  `ip` varchar(50) DEFAULT NULL COMMENT 'IP地址',
  `user_agent` varchar(500) DEFAULT NULL COMMENT 'User-Agent',
  `duration` bigint DEFAULT NULL COMMENT '执行时长(ms)',
  `status` tinyint DEFAULT 1 COMMENT '状态：0失败 1成功',
  `error_msg` text COMMENT '错误信息',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_module` (`module`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';
```

### 4.2 消息通知表

```sql
CREATE TABLE `sys_message` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `title` varchar(200) NOT NULL COMMENT '消息标题',
  `content` text COMMENT '消息内容',
  `type` varchar(20) NOT NULL COMMENT '消息类型：SYSTEM-系统消息, APPROVAL-审批消息, NOTICE-通知',
  `sender_id` bigint DEFAULT NULL COMMENT '发送人ID',
  `sender_name` varchar(50) DEFAULT NULL COMMENT '发送人姓名',
  `receiver_id` bigint DEFAULT NULL COMMENT '接收人ID（为空表示全体用户）',
  `is_read` tinyint DEFAULT 0 COMMENT '是否已读：0未读 1已读',
  `read_time` datetime DEFAULT NULL COMMENT '阅读时间',
  `url` varchar(200) DEFAULT NULL COMMENT '跳转URL',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_receiver_id` (`receiver_id`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息通知表';
```

### 4.3 文件上传记录表

```sql
CREATE TABLE `sys_file` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `original_name` varchar(200) DEFAULT NULL COMMENT '原始文件名',
  `file_name` varchar(200) NOT NULL COMMENT '存储文件名',
  `file_path` varchar(500) NOT NULL COMMENT '文件路径',
  `file_url` varchar(500) NOT NULL COMMENT '访问URL',
  `file_size` bigint DEFAULT NULL COMMENT '文件大小(字节)',
  `file_type` varchar(50) DEFAULT NULL COMMENT '文件类型',
  `category` varchar(50) DEFAULT NULL COMMENT '文件分类',
  `upload_user_id` bigint DEFAULT NULL COMMENT '上传用户ID',
  `upload_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  `is_deleted` tinyint DEFAULT 0 COMMENT '是否删除：0否 1是',
  PRIMARY KEY (`id`),
  KEY `idx_upload_user_id` (`upload_user_id`),
  KEY `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文件上传记录表';
```

---

## 五、接口设计

### 5.1 文件上传接口

| 接口 | 方法 | 说明 |
|-----|------|------|
| `/api/upload/image` | POST | 上传图片 |
| `/api/upload/attachment` | POST | 上传附件 |
| `/api/upload/excel` | POST | 上传Excel文件 |

### 5.2 Excel导入导出接口

| 接口 | 方法 | 说明 |
|-----|------|------|
| `/api/employee/export` | GET | 导出员工Excel |
| `/api/employee/import` | POST | 批量导入员工 |
| `/api/employee/template` | GET | 下载导入模板 |
| `/api/salary/export` | POST | 导出薪资单 |
| `/api/performance/export` | POST | 导出绩效报告 |
| `/api/training/export` | POST | 导出培训记录 |
| `/api/attendance/export` | POST | 导出考勤统计 |

### 5.3 操作日志接口

| 接口 | 方法 | 说明 |
|-----|------|------|
| `/api/log/operation/list` | GET | 查询操作日志列表 |
| `/api/log/operation/export` | GET | 导出操作日志 |

### 5.4 消息通知接口

| 接口 | 方法 | 说明 |
|-----|------|------|
| `/api/message/list` | GET | 查询消息列表 |
| `/api/message/unread-count` | GET | 获取未读消息数 |
| `/api/message/read/{id}` | PUT | 标记消息已读 |
| `/api/message/read-all` | PUT | 标记所有消息已读 |
| `/api/message/send` | POST | 发送消息 |

---

## 六、部署配置

### 6.1 前端配置

**文件**: `frontend/.env.production`
```
VITE_API_BASE_URL=/api
VITE_WS_URL=ws://localhost:8080/ws
```

### 6.2 后端配置

**文件**: `backend/src/main/resources/application.yml`
```yaml
# 文件上传配置
file:
  upload:
    path: /data/uploads
    max-size: 10485760  # 10MB

# WebSocket配置
spring:
  websocket:
    enabled: true

# 邮件配置
spring:
  mail:
    host: smtp.example.com
    port: 587
    username: noreply@example.com
    password: ${MAIL_PASSWORD}
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true
```

---

## 七、测试方案

### 7.1 单元测试

- Excel导出功能测试
- Excel导入功能测试
- 文件上传功能测试
- 日志记录功能测试
- 消息推送功能测试

### 7.2 集成测试

- API接口测试
- WebSocket连接测试
- 文件上传下载测试

### 7.3 性能测试

- 大数据量导出测试（10000+条）
- 并发上传测试
- 消息推送性能测试

---

**文档结束**
