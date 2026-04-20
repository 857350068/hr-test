<template>
    <div class="employee">
        <h2>员工管理</h2>

        <!-- 查询表单 -->
        <el-card class="search-card" style="margin-bottom: 20px">
            <el-form :inline="true" :model="searchForm">
                <el-form-item label="关键词">
                    <el-input v-model="searchForm.keyword" placeholder="请输入员工姓名/编号/部门" clearable />
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="handleSearch">查询</el-button>
                    <el-button @click="handleReset">重置</el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <!-- 操作按钮 -->
        <el-card style="margin-bottom: 20px">
            <el-button type="primary" @click="handleAdd">
                <el-icon><Plus /></el-icon>
                新增员工
            </el-button>
            <el-button type="success" @click="handleImport">
                <el-icon><Upload /></el-icon>
                批量导入
            </el-button>
            <el-button type="success" @click="handleExport">
                <el-icon><Download /></el-icon>
                导出Excel
            </el-button>
        </el-card>

        <!-- 数据表格 -->
        <el-card>
            <el-table :data="tableData" border style="width: 100%" v-loading="loading">
                <el-table-column type="index" label="序号" width="60" />
                <el-table-column prop="empNo" label="员工编号" width="120" />
                <el-table-column prop="empName" label="员工姓名" width="120" />
                <el-table-column prop="gender" label="性别" width="80">
                    <template #default="{ row }">
                        {{ row.gender === 1 ? '男' : '女' }}
                    </template>
                </el-table-column>
                <el-table-column prop="department" label="部门" width="120" />
                <el-table-column prop="position" label="职位" width="150" />
                <el-table-column prop="phone" label="联系电话" width="130" />
                <el-table-column prop="email" label="邮箱" width="180" />
                <el-table-column prop="salary" label="薪资" width="100">
                    <template #default="{ row }">
                        ¥{{ row.salary ? row.salary.toLocaleString() : '0' }}
                    </template>
                </el-table-column>
                <el-table-column prop="status" label="状态" width="80">
                    <template #default="{ row }">
                        <el-tag v-if="row.status === 1" type="success">在职</el-tag>
                        <el-tag v-else-if="row.status === 2" type="warning">试用</el-tag>
                        <el-tag v-else type="danger">离职</el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="hireDate" label="入职日期" width="110" />
                <el-table-column label="操作" width="200" fixed="right">
                    <template #default="{ row }">
                        <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
                        <el-button type="warning" size="small" @click="handleEdit(row)">编辑</el-button>
                        <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
                    </template>
                </el-table-column>
            </el-table>

            <!-- 分页 -->
            <el-pagination
                v-model:current-page="pagination.page"
                v-model:page-size="pagination.size"
                :page-sizes="[10, 20, 50, 100]"
                :total="pagination.total"
                layout="total, sizes, prev, pager, next, jumper"
                @size-change="handleSizeChange"
                @current-change="handleCurrentChange"
                style="margin-top: 20px; justify-content: flex-end"
            />
        </el-card>

        <!-- 新增/编辑对话框 -->
        <el-dialog
            v-model="dialogVisible"
            :title="dialogTitle"
            width="600px"
            @close="handleDialogClose"
        >
            <el-form :model="formData" :rules="formRules" ref="formRef" label-width="100px">
                <el-form-item label="员工编号" prop="empNo">
                    <el-input v-model="formData.empNo" placeholder="请输入员工编号" />
                </el-form-item>
                <el-form-item label="员工姓名" prop="empName">
                    <el-input v-model="formData.empName" placeholder="请输入员工姓名" />
                </el-form-item>
                <el-form-item label="性别" prop="gender">
                    <el-radio-group v-model="formData.gender">
                        <el-radio :value="1">男</el-radio>
                        <el-radio :value="0">女</el-radio>
                    </el-radio-group>
                </el-form-item>
                <el-form-item label="出生日期" prop="birthDate">
                    <el-date-picker
                        v-model="formData.birthDate"
                        type="date"
                        placeholder="选择日期"
                        value-format="YYYY-MM-DD"
                        style="width: 100%"
                    />
                </el-form-item>
                <el-form-item label="身份证号" prop="idCard">
                    <el-input v-model="formData.idCard" placeholder="请输入身份证号" />
                </el-form-item>
                <el-form-item label="手机号码" prop="phone">
                    <el-input v-model="formData.phone" placeholder="请输入手机号码" />
                </el-form-item>
                <el-form-item label="邮箱" prop="email">
                    <el-input v-model="formData.email" placeholder="请输入邮箱" />
                </el-form-item>
                <el-form-item label="部门" prop="department">
                    <el-input v-model="formData.department" placeholder="请输入部门" />
                </el-form-item>
                <el-form-item label="职位" prop="position">
                    <el-input v-model="formData.position" placeholder="请输入职位" />
                </el-form-item>
                <el-form-item label="薪资" prop="salary">
                    <el-input-number v-model="formData.salary" :min="0" :precision="2" style="width: 100%" />
                </el-form-item>
                <el-form-item label="入职日期" prop="hireDate">
                    <el-date-picker
                        v-model="formData.hireDate"
                        type="date"
                        placeholder="选择日期"
                        value-format="YYYY-MM-DD"
                        style="width: 100%"
                    />
                </el-form-item>
                <el-form-item label="员工状态" prop="status">
                    <el-select v-model="formData.status" placeholder="请选择状态" style="width: 100%">
                        <el-option label="在职" :value="1" />
                        <el-option label="试用" :value="2" />
                        <el-option label="离职" :value="0" />
                    </el-select>
                </el-form-item>
                <el-form-item label="学历" prop="education">
                    <el-input v-model="formData.education" placeholder="请输入学历" />
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="dialogVisible = false">取消</el-button>
                <el-button type="primary" @click="handleSubmit">确定</el-button>
            </template>
        </el-dialog>

        <!-- 批量导入对话框 -->
        <el-dialog
            v-model="importDialogVisible"
            title="批量导入员工信息"
            width="700px"
        >
            <el-steps :active="importStep" finish-status="success" simple style="margin-bottom: 20px">
                <el-step title="下载模板" />
                <el-step title="上传文件" />
                <el-step title="数据预览" />
                <el-step title="导入结果" />
            </el-steps>

            <!-- 步骤1: 下载模板 -->
            <div v-if="importStep === 0" style="text-align: center; padding: 40px 0">
                <el-button type="primary" size="large" @click="handleDownloadTemplate">
                    <el-icon><Download /></el-icon>
                    下载导入模板
                </el-button>
                <p style="margin-top: 20px; color: #999">请先下载模板，按模板格式填写员工信息</p>
            </div>

            <!-- 步骤2: 上传文件 -->
            <div v-if="importStep === 1">
                <el-upload
                    ref="uploadRef"
                    :auto-upload="false"
                    :limit="1"
                    :on-change="handleFileChange"
                    :before-upload="beforeFileUpload"
                    accept=".xlsx,.xls"
                    drag
                >
                    <el-icon class="el-icon--upload"><upload-filled /></el-icon>
                    <div class="el-upload__text">
                        将文件拖到此处，或<em>点击上传</em>
                    </div>
                    <template #tip>
                        <div class="el-upload__tip">
                            只能上传 xlsx/xls 文件，且文件大小不超过 10MB
                        </div>
                    </template>
                </el-upload>
            </div>

            <!-- 步骤3: 数据预览 -->
            <div v-if="importStep === 2">
                <div v-if="importErrors.length > 0" style="margin-bottom: 20px">
                    <el-alert
                        title="数据校验发现错误"
                        type="error"
                        :closable="false"
                    >
                        <div v-for="(error, index) in importErrors.slice(0, 10)" :key="index">
                            {{ error.message }}
                        </div>
                        <div v-if="importErrors.length > 10">
                            还有 {{ importErrors.length - 10 }} 条错误...
                        </div>
                    </el-alert>
                </div>
                <el-table :data="importPreviewData" border max-height="400">
                    <el-table-column type="index" label="行号" width="60" />
                    <el-table-column prop="empNo" label="员工编号" width="120" />
                    <el-table-column prop="empName" label="员工姓名" width="120" />
                    <el-table-column prop="gender" label="性别" width="80" />
                    <el-table-column prop="department" label="部门" width="120" />
                    <el-table-column prop="position" label="职位" width="120" />
                    <el-table-column prop="phone" label="联系电话" width="130" />
                </el-table>
            </div>

            <!-- 步骤4: 导入结果 -->
            <div v-if="importStep === 3" style="text-align: center; padding: 40px 0">
                <el-result
                    :icon="importResult.success ? 'success' : 'warning'"
                    :title="importResult.title"
                    :sub-title="importResult.message"
                >
                    <template #extra>
                        <el-button type="primary" @click="closeImportDialog">完成</el-button>
                    </template>
                </el-result>
            </div>

            <template #footer>
                <el-button @click="closeImportDialog">取消</el-button>
                <el-button v-if="importStep > 0 && importStep < 3" @click="importStep--">上一步</el-button>
                <el-button v-if="importStep === 1" type="primary" @click="handleParseFile" :disabled="!importFile">解析文件</el-button>
                <el-button v-if="importStep === 2" type="primary" @click="handleConfirmImport" :disabled="importErrors.length > 0">确认导入</el-button>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Download, UploadFilled } from '@element-plus/icons-vue'
import {
    getEmployeeList,
    addEmployee,
    updateEmployee,
    deleteEmployee,
    batchImportEmployees,
    downloadEmployeeExport
} from '@/api/employee'

const loading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formRef = ref(null)

const searchForm = reactive({
    keyword: ''
})

const pagination = reactive({
    page: 1,
    size: 10,
    total: 0
})

const tableData = ref([])

const formData = reactive({
    empId: null,
    empNo: '',
    empName: '',
    gender: 1,
    birthDate: '',
    idCard: '',
    phone: '',
    email: '',
    department: '',
    position: '',
    salary: 0,
    hireDate: '',
    status: 1,
    education: ''
})

const formRules = {
    empName: [
        { required: true, message: '请输入员工姓名', trigger: 'blur' }
    ],
    phone: [
        { required: true, message: '请输入手机号码', trigger: 'blur' },
        { pattern: /^1[3-9]\d{9}$/, message: '手机号码格式不正确', trigger: 'blur' }
    ],
    email: [
        { required: true, message: '请输入邮箱', trigger: 'blur' },
        { type: 'email', message: '邮箱格式不正确', trigger: 'blur' }
    ],
    department: [
        { required: true, message: '请输入部门', trigger: 'blur' }
    ],
    position: [
        { required: true, message: '请输入职位', trigger: 'blur' }
    ]
}

// 获取员工列表
const fetchEmployeeList = async () => {
    loading.value = true
    try {
        const params = {
            page: pagination.page,
            size: pagination.size,
            keyword: searchForm.keyword
        }
        const res = await getEmployeeList(params)
        tableData.value = res.data.records
        pagination.total = res.data.total
    } catch (error) {
        console.error('获取员工列表失败:', error)
        ElMessage.error('获取员工列表失败')
    } finally {
        loading.value = false
    }
}

// 查询
const handleSearch = () => {
    pagination.page = 1
    fetchEmployeeList()
}

// 重置
const handleReset = () => {
    searchForm.keyword = ''
    pagination.page = 1
    fetchEmployeeList()
}

// 分页大小改变
const handleSizeChange = (val) => {
    pagination.size = val
    pagination.page = 1
    fetchEmployeeList()
}

// 当前页改变
const handleCurrentChange = (val) => {
    pagination.page = val
    fetchEmployeeList()
}

// 新增员工
const handleAdd = () => {
    dialogTitle.value = '新增员工'
    resetForm()
    dialogVisible.value = true
}

// 编辑员工
const handleEdit = (row) => {
    dialogTitle.value = '编辑员工'
    Object.assign(formData, row)
    dialogVisible.value = true
}

// 查看员工
const handleView = (row) => {
    ElMessageBox.alert(`
        <div style="line-height: 2;">
            <p><strong>员工编号：</strong>${row.empNo}</p>
            <p><strong>员工姓名：</strong>${row.empName}</p>
            <p><strong>性别：</strong>${row.gender === 1 ? '男' : '女'}</p>
            <p><strong>出生日期：</strong>${row.birthDate || '未填写'}</p>
            <p><strong>身份证号：</strong>${row.idCard || '未填写'}</p>
            <p><strong>联系电话：</strong>${row.phone || '未填写'}</p>
            <p><strong>邮箱：</strong>${row.email || '未填写'}</p>
            <p><strong>部门：</strong>${row.department || '未填写'}</p>
            <p><strong>职位：</strong>${row.position || '未填写'}</p>
            <p><strong>薪资：</strong>¥${row.salary ? row.salary.toLocaleString() : '0'}</p>
            <p><strong>入职日期：</strong>${row.hireDate || '未填写'}</p>
            <p><strong>状态：</strong>${row.status === 1 ? '在职' : row.status === 2 ? '试用' : '离职'}</p>
            <p><strong>学历：</strong>${row.education || '未填写'}</p>
        </div>
    `, '员工详情', {
        dangerouslyUseHTMLString: true,
        confirmButtonText: '关闭'
    })
}

// 删除员工
const handleDelete = (row) => {
    ElMessageBox.confirm(`确定要删除员工"${row.empName}"吗?`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(async () => {
        try {
            await deleteEmployee(row.empId)
            ElMessage.success('删除成功')
            fetchEmployeeList()
        } catch (error) {
            console.error('删除失败:', error)
            ElMessage.error('删除失败')
        }
    }).catch(() => {
        // 取消删除
    })
}

// 导出数据（统一走后端导出接口）
const handleExport = async () => {
    try {
        const file = await downloadEmployeeExport({
            keyword: searchForm.keyword || undefined
        })
        const blobUrl = window.URL.createObjectURL(file)
        const link = document.createElement('a')
        link.href = blobUrl
        link.download = 'employee_export.csv'
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
        window.URL.revokeObjectURL(blobUrl)
        ElMessage.success('导出成功')
    } catch (error) {
        console.error('导出失败:', error)
        ElMessage.error('导出失败')
    }
}

// ==================== 批量导入功能 ====================
const importDialogVisible = ref(false)
const importStep = ref(0)
const importFile = ref(null)
const importPreviewData = ref([])
const importErrors = ref([])
const importResult = ref({
    success: false,
    title: '',
    message: ''
})
const uploadRef = ref(null)

// 打开导入对话框
const handleImport = () => {
    importStep.value = 0
    importFile.value = null
    importPreviewData.value = []
    importErrors.value = []
    importDialogVisible.value = true
}

// 关闭导入对话框
const closeImportDialog = () => {
    importDialogVisible.value = false
    importStep.value = 0
    importFile.value = null
    importPreviewData.value = []
    importErrors.value = []
}

// 下载模板
const handleDownloadTemplate = async () => {
    try {
        const { generateTemplate } = await import('@/utils/excel')

        const fields = [
            { name: 'empNo', label: '员工编号', example: 'EMP001' },
            { name: 'empName', label: '员工姓名', example: '张三' },
            { name: 'gender', label: '性别', example: '男' },
            { name: 'birthDate', label: '出生日期', example: '1990-01-01' },
            { name: 'idCard', label: '身份证号', example: '110101199001011234' },
            { name: 'phone', label: '联系电话', example: '13800138000' },
            { name: 'email', label: '邮箱', example: 'zhangsan@example.com' },
            { name: 'department', label: '部门', example: '技术部' },
            { name: 'position', label: '职位', example: '软件工程师' },
            { name: 'salary', label: '薪资', example: '10000' },
            { name: 'hireDate', label: '入职日期', example: '2024-01-01' },
            { name: 'status', label: '状态', example: '在职' },
            { name: 'education', label: '学历', example: '本科' }
        ]

        generateTemplate(fields, '员工信息导入模板')
        ElMessage.success('模板下载成功')

        // 自动进入下一步
        importStep.value = 1
    } catch (error) {
        console.error('模板下载失败:', error)
        ElMessage.error('模板下载失败: ' + error.message)
    }
}

// 文件选择变化
const handleFileChange = (file) => {
    importFile.value = file.raw
}

// 文件上传前校验
const beforeFileUpload = (file) => {
    const isExcel = file.name.endsWith('.xlsx') || file.name.endsWith('.xls')
    const isLt10M = file.size / 1024 / 1024 < 10

    if (!isExcel) {
        ElMessage.error('只能上传 xlsx/xls 文件!')
        return false
    }
    if (!isLt10M) {
        ElMessage.error('文件大小不能超过 10MB!')
        return false
    }
    return true
}

// 解析文件
const handleParseFile = async () => {
    if (!importFile.value) {
        ElMessage.warning('请先选择文件')
        return
    }

    try {
        const { parseExcel, validateData } = await import('@/utils/excel-import')

        // 字段映射（中文表头 -> 英文字段名）
        const fieldMapping = {
            '员工编号': 'empNo',
            '员工姓名': 'empName',
            '性别': 'gender',
            '出生日期': 'birthDate',
            '身份证号': 'idCard',
            '联系电话': 'phone',
            '邮箱': 'email',
            '部门': 'department',
            '职位': 'position',
            '薪资': 'salary',
            '入职日期': 'hireDate',
            '状态': 'status',
            '学历': 'education'
        }

        // 解析Excel
        const data = await parseExcel(importFile.value, { fieldMapping })

        // 数据转换
        const processedData = data.map(item => ({
            ...item,
            gender: item.gender === '男' ? 1 : 0,
            status: item.status === '在职' ? 1 : item.status === '试用' ? 2 : 0,
            salary: Number(item.salary) || 0
        }))

        // 数据校验
        const rules = {
            empNo: { required: true, message: '员工编号不能为空' },
            empName: { required: true, message: '员工姓名不能为空' },
            phone: { required: true, type: 'phone', message: '联系电话格式不正确' },
            email: { required: true, type: 'email', message: '邮箱格式不正确' },
            department: { required: true, message: '部门不能为空' },
            position: { required: true, message: '职位不能为空' }
        }

        const validation = validateData(processedData, rules)

        importPreviewData.value = processedData
        importErrors.value = validation.errors

        if (validation.valid) {
            ElMessage.success(`文件解析成功，共 ${processedData.length} 条数据`)
        } else {
            ElMessage.warning(`文件解析完成，发现 ${validation.errors.length} 个错误`)
        }

        // 进入预览步骤
        importStep.value = 2
    } catch (error) {
        console.error('文件解析失败:', error)
        ElMessage.error('文件解析失败: ' + error.message)
    }
}

// 确认导入
const handleConfirmImport = async () => {
    try {
        const result = await batchImportEmployees(importPreviewData.value)

        if (result.code === 200) {
            importResult.value = {
                success: true,
                title: '导入成功',
                message: `成功导入 ${result.data.successCount} 条数据，失败 ${result.data.failCount} 条`
            }
            ElMessage.success('导入成功')
            fetchEmployeeList() // 刷新列表
        } else {
            importResult.value = {
                success: false,
                title: '导入失败',
                message: result.message || '导入过程中发生错误'
            }
        }

        // 进入结果步骤
        importStep.value = 3
    } catch (error) {
        console.error('导入失败:', error)
        importResult.value = {
            success: false,
            title: '导入失败',
            message: error.message
        }
        importStep.value = 3
    }
}

// 重置表单
const resetForm = () => {
    Object.assign(formData, {
        empId: null,
        empNo: '',
        empName: '',
        gender: 1,
        birthDate: '',
        idCard: '',
        phone: '',
        email: '',
        department: '',
        position: '',
        salary: 0,
        hireDate: '',
        status: 1,
        education: ''
    })
}

// 对话框关闭
const handleDialogClose = () => {
    resetForm()
    formRef.value?.resetFields()
}

// 提交表单
const handleSubmit = () => {
    formRef.value.validate(async (valid) => {
        if (!valid) return

        try {
            if (formData.empId) {
                // 编辑
                await updateEmployee(formData)
                ElMessage.success('更新成功')
            } else {
                // 新增
                await addEmployee(formData)
                ElMessage.success('新增成功')
            }
            dialogVisible.value = false
            fetchEmployeeList()
        } catch (error) {
            console.error('提交失败:', error)
            ElMessage.error('提交失败')
        }
    })
}

onMounted(() => {
    fetchEmployeeList()
})
</script>

<style scoped>
.employee {
    padding: 20px;
}

h2 {
    margin-bottom: 20px;
    color: #333;
}

.search-card {
    margin-bottom: 20px;
}
</style>
