<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">部门管理</h2>
      <el-button type="primary" @click="openDialog()">新增部门</el-button>
    </div>
    <el-card>
      <!-- 查询表单 -->
      <el-form :inline="true" :model="query" class="query-form">
        <el-form-item label="部门名称">
          <el-input v-model="query.name" placeholder="请输入部门名称" clearable @keyup.enter="load" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 数据表格 -->
      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="name" label="部门名称" width="200" />
        <el-table-column prop="parentId" label="父部门" width="120">
          <template #default="{ row }">
            {{ row.parentId === 0 ? '顶级' : getParentName(row.parentId) }}
          </template>
        </el-table-column>
        <el-table-column prop="sortOrder" label="排序" width="80" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="openDialog(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页组件 -->
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :page-sizes="[10, 20, 50, 100]"
        :total="page.total"
        layout="total, sizes, prev, pager, next, jumper"
        @current-change="load"
        @size-change="load"
        style="margin-top: 20px; justify-content: flex-end;"
      />
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="500px"
      @close="resetForm"
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="80px">
        <el-form-item label="部门名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入部门名称" />
        </el-form-item>
        <el-form-item label="父部门" prop="parentId">
          <el-select v-model="form.parentId" placeholder="请选择父部门" clearable>
            <el-option label="顶级部门" :value="0" />
            <el-option
              v-for="item in flatDepartments.filter(i => i.id !== form.id)"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="排序" prop="sortOrder">
          <el-input-number v-model="form.sortOrder" :min="0" :max="9999" />
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
import { ref, reactive, onMounted, computed } from 'vue'
import { getDepartmentList, getDepartmentPage, addDepartment, updateDepartment, deleteDepartment } from '@/api/department'
import { ElMessage, ElMessageBox } from 'element-plus'

const tableData = ref([])
const loading = ref(false)
const dialogVisible = ref(false)
const submitting = ref(false)
const dialogTitle = ref('')
const formRef = ref(null)

// 分页状态
const page = reactive({
  current: 1,
  size: 10,
  total: 0
})

// 查询条件
const query = reactive({
  name: ''
})

const form = reactive({
  id: null,
  name: '',
  parentId: 0,
  sortOrder: 0
})

const rules = {
  name: [{ required: true, message: '请输入部门名称', trigger: 'blur' }],
  parentId: [{ required: true, message: '请选择父部门', trigger: 'change' }],
  sortOrder: [{ required: true, message: '请输入排序', trigger: 'blur' }]
}

// 扁平化的部门列表，用于下拉选择
const flatDepartments = computed(() => {
  const result = []
  const flatten = (items) => {
    items.forEach(item => {
      result.push(item)
      if (item.children && item.children.length > 0) {
        flatten(item.children)
      }
    })
  }
  flatten(tableData.value)
  return result
})

const getParentName = (parentId) => {
  const dept = flatDepartments.value.find(item => item.id === parentId)
  return dept ? dept.name : ''
}

const loadList = async () => {
  loading.value = true
  try {
    const res = await getDepartmentList()
    const list = res.data || []
    // 构建树形结构
    tableData.value = buildTree(list, 0)
  } catch (e) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

// 分页加载数据
const load = async () => {
  loading.value = true
  try {
    const res = await getDepartmentPage({
      current: page.current,
      size: page.size,
      name: query.name || undefined
    })
    tableData.value = res.data.records || []
    page.total = res.data.total || 0
  } catch (e) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  query.name = ''
  page.current = 1
  load()
}

const buildTree = (list, parentId) => {
  return list
    .filter(item => item.parentId === parentId)
    .map(item => ({
      ...item,
      children: buildTree(list, item.id)
    }))
}

const openDialog = (row = null) => {
  if (row) {
    dialogTitle.value = '编辑部门'
    form.id = row.id
    form.name = row.name
    form.parentId = row.parentId
    form.sortOrder = row.sortOrder
  } else {
    dialogTitle.value = '新增部门'
    resetForm()
  }
  dialogVisible.value = true
}

const resetForm = () => {
  form.id = null
  form.name = ''
  form.parentId = 0
  form.sortOrder = 0
  formRef.value?.clearValidate()
}

const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate()
  submitting.value = true
  try {
    if (form.id) {
      await updateDepartment(form.id, form)
      ElMessage.success('更新成功')
    } else {
      await addDepartment(form)
      ElMessage.success('新增成功')
    }
    dialogVisible.value = false
    load()
  } catch (e) {
    ElMessage.error(form.id ? '更新失败' : '新增失败')
  } finally {
    submitting.value = false
  }
}

const handleDelete = async (id) => {
  try {
    await ElMessageBox.confirm('确定删除该部门吗？', '提示', { type: 'warning' })
    await deleteDepartment(id)
    ElMessage.success('删除成功')
    load()
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

onMounted(load)
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

.query-form {
  margin-bottom: 20px;
}
</style>
