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
                        <el-radio :label="1">男</el-radio>
                        <el-radio :label="0">女</el-radio>
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
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getEmployeeList, addEmployee, updateEmployee, deleteEmployee } from '@/api/employee'

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
    ElMessage.info('查看功能开发中')
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

// 导出Excel
const handleExport = () => {
    ElMessage.info('导出功能开发中')
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
