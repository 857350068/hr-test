<template>
    <div class="data-category">
        <h2>数据分类管理</h2>

        <!-- 查询表单 -->
        <el-card class="search-card" style="margin-bottom: 20px">
            <el-form :inline="true" :model="searchForm">
                <el-form-item label="关键词">
                    <el-input v-model="searchForm.keyword" placeholder="请输入分类名称/编码" clearable />
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
                新增分类
            </el-button>
        </el-card>

        <!-- 数据表格 -->
        <el-card>
            <el-table :data="tableData" border style="width: 100%" v-loading="loading">
                <el-table-column type="index" label="序号" width="60" />
                <el-table-column prop="categoryName" label="分类名称" width="150" />
                <el-table-column prop="categoryCode" label="分类编码" width="150" />
                <el-table-column prop="description" label="分类描述" width="250" />
                <el-table-column prop="sortOrder" label="排序号" width="100" />
                <el-table-column prop="status" label="状态" width="100">
                    <template #default="{ row }">
                        <el-tag v-if="row.status === 1" type="success">启用</el-tag>
                        <el-tag v-else type="danger">禁用</el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="createTime" label="创建时间" width="180" />
                <el-table-column label="操作" width="200" fixed="right">
                    <template #default="{ row }">
                        <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
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
            width="500px"
            @close="handleDialogClose"
        >
            <el-form :model="formData" :rules="formRules" ref="formRef" label-width="100px">
                <el-form-item label="分类名称" prop="categoryName">
                    <el-input v-model="formData.categoryName" placeholder="请输入分类名称" />
                </el-form-item>
                <el-form-item label="分类编码" prop="categoryCode">
                    <el-input v-model="formData.categoryCode" placeholder="请输入分类编码" />
                </el-form-item>
                <el-form-item label="父分类" prop="parentId">
                    <el-select v-model="formData.parentId" placeholder="请选择父分类" style="width: 100%">
                        <el-option label="顶级分类" :value="0" />
                        <el-option
                            v-for="item in parentCategories"
                            :key="item.categoryId"
                            :label="item.categoryName"
                            :value="item.categoryId"
                        />
                    </el-select>
                </el-form-item>
                <el-form-item label="分类描述" prop="description">
                    <el-input v-model="formData.description" type="textarea" placeholder="请输入分类描述" />
                </el-form-item>
                <el-form-item label="排序号" prop="sortOrder">
                    <el-input-number v-model="formData.sortOrder" :min="0" style="width: 100%" />
                </el-form-item>
                <el-form-item label="状态" prop="status">
                    <el-radio-group v-model="formData.status">
                        <el-radio :value="1">启用</el-radio>
                        <el-radio :value="0">禁用</el-radio>
                    </el-radio-group>
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
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { getCategoryList, addCategory, updateCategory, deleteCategory, getActiveCategories } from '@/api/category'

const loading = ref(false)
const tableData = ref([])
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formRef = ref(null)
const parentCategories = ref([])

const searchForm = ref({
    keyword: ''
})

const pagination = ref({
    page: 1,
    size: 10,
    total: 0
})

const formData = ref({
    categoryId: null,
    categoryName: '',
    categoryCode: '',
    parentId: 0,
    description: '',
    sortOrder: 0,
    status: 1
})

const formRules = {
    categoryName: [{ required: true, message: '请输入分类名称', trigger: 'blur' }],
    categoryCode: [{ required: true, message: '请输入分类编码', trigger: 'blur' }]
}

onMounted(() => {
    loadData()
    loadParentCategories()
})

async function loadData() {
    loading.value = true
    try {
        const res = await getCategoryList(pagination.value.page, pagination.value.size, searchForm.value.keyword)
        tableData.value = res.data.records
        pagination.value.total = res.data.total
    } catch (error) {
        ElMessage.error('加载数据失败')
    } finally {
        loading.value = false
    }
}

async function loadParentCategories() {
    try {
        const res = await getActiveCategories()
        parentCategories.value = res.data
    } catch (error) {
        console.error('加载父分类失败:', error)
    }
}

function handleSearch() {
    pagination.value.page = 1
    loadData()
}

function handleReset() {
    searchForm.value.keyword = ''
    pagination.value.page = 1
    loadData()
}

function handleSizeChange() {
    pagination.value.page = 1
    loadData()
}

function handleCurrentChange() {
    loadData()
}

function handleAdd() {
    dialogTitle.value = '新增分类'
    resetForm()
    dialogVisible.value = true
}

function handleEdit(row) {
    dialogTitle.value = '编辑分类'
    formData.value = { ...row }
    dialogVisible.value = true
}

async function handleDelete(row) {
    try {
        await ElMessageBox.confirm('确定要删除该分类吗？', '提示', {
            type: 'warning'
        })
        await deleteCategory(row.categoryId)
        ElMessage.success('删除成功')
        loadData()
    } catch (error) {
        if (error !== 'cancel') {
            ElMessage.error('删除失败')
        }
    }
}

async function handleSubmit() {
    try {
        await formRef.value.validate()
        if (formData.value.categoryId) {
            await updateCategory(formData.value)
            ElMessage.success('更新成功')
        } else {
            await addCategory(formData.value)
            ElMessage.success('新增成功')
        }
        dialogVisible.value = false
        loadData()
    } catch (error) {
        ElMessage.error('操作失败')
    }
}

function handleDialogClose() {
    formRef.value?.resetFields()
}

function resetForm() {
    formData.value = {
        categoryId: null,
        categoryName: '',
        categoryCode: '',
        parentId: 0,
        description: '',
        sortOrder: 0,
        status: 1
    }
}
</script>

<style scoped>
.data-category {
    padding: 20px;
}

h2 {
    margin-bottom: 20px;
    color: #333;
}
</style>
