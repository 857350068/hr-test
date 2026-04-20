<template>
  <div class="page">
    <el-card class="mb">
      <el-form :inline="true">
        <el-form-item label="关键词">
          <el-input v-model="query.keyword" placeholder="用户名/姓名/手机号" clearable />
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="query.roleCode" clearable placeholder="全部角色" style="width: 160px">
            <el-option label="超级管理员" value="ROLE_ADMIN" />
            <el-option label="HR管理员" value="ROLE_HR_ADMIN" />
            <el-option label="部门经理" value="ROLE_MANAGER" />
            <el-option label="普通员工" value="ROLE_EMPLOYEE" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadData">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
          <el-button type="success" @click="openAdd">新增用户</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card>
      <el-table :data="tableData" border v-loading="loading">
        <el-table-column prop="username" label="用户名" width="140" />
        <el-table-column prop="realName" label="姓名" width="120" />
        <el-table-column prop="phone" label="手机号" width="140" />
        <el-table-column prop="email" label="邮箱" min-width="180" />
        <el-table-column prop="roleCode" label="角色" width="140" />
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '启用' : '禁用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="260" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="openEdit(row)">编辑</el-button>
            <el-button size="small" type="warning" @click="resetPwd(row)">重置密码</el-button>
            <el-button size="small" type="danger" @click="remove(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        class="mt"
        background
        layout="total, prev, pager, next, sizes"
        :total="total"
        v-model:current-page="query.page"
        v-model:page-size="query.size"
        @current-change="loadData"
        @size-change="loadData"
      />
    </el-card>

    <el-dialog v-model="dialogVisible" :title="form.userId ? '编辑用户' : '新增用户'" width="560px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="用户名">
          <el-input v-model="form.username" :disabled="!!form.userId" />
        </el-form-item>
        <el-form-item label="密码" v-if="!form.userId">
          <el-input v-model="form.password" type="password" />
        </el-form-item>
        <el-form-item label="姓名">
          <el-input v-model="form.realName" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="form.phone" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="form.email" />
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="form.roleCode" style="width: 100%">
            <el-option label="超级管理员" value="ROLE_ADMIN" />
            <el-option label="HR管理员" value="ROLE_HR_ADMIN" />
            <el-option label="部门经理" value="ROLE_MANAGER" />
            <el-option label="普通员工" value="ROLE_EMPLOYEE" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="form.status" :active-value="1" :inactive-value="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { addUser, deleteUser, getUserList, resetUserPassword, updateUser } from '@/api/user'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const dialogVisible = ref(false)
const query = reactive({ page: 1, size: 10, keyword: '', roleCode: '' })
const form = reactive({
  userId: null,
  username: '',
  password: '',
  realName: '',
  phone: '',
  email: '',
  roleCode: 'ROLE_EMPLOYEE',
  status: 1
})

async function loadData() {
  loading.value = true
  try {
    const res = await getUserList(query)
    tableData.value = res.data?.records || []
    total.value = res.data?.total || 0
  } finally {
    loading.value = false
  }
}

function resetQuery() {
  query.keyword = ''
  query.roleCode = ''
  query.page = 1
  loadData()
}

function openAdd() {
  Object.assign(form, {
    userId: null,
    username: '',
    password: '',
    realName: '',
    phone: '',
    email: '',
    roleCode: 'ROLE_EMPLOYEE',
    status: 1
  })
  dialogVisible.value = true
}

function openEdit(row) {
  Object.assign(form, { ...row, password: '' })
  dialogVisible.value = true
}

async function submit() {
  if (!form.userId && (!form.username || !form.password)) {
    ElMessage.warning('请填写用户名和密码')
    return
  }
  if (form.userId) {
    await updateUser(form)
  } else {
    await addUser(form)
  }
  ElMessage.success('保存成功')
  dialogVisible.value = false
  await loadData()
}

async function resetPwd(row) {
  await ElMessageBox.confirm(`确认重置用户 ${row.username} 的密码为 123456 吗？`, '提示', { type: 'warning' })
  await resetUserPassword(row.userId)
  ElMessage.success('密码已重置')
}

async function remove(row) {
  await ElMessageBox.confirm(`确认删除用户 ${row.username} 吗？`, '提示', { type: 'warning' })
  await deleteUser(row.userId)
  ElMessage.success('删除成功')
  await loadData()
}

onMounted(loadData)
</script>

<style scoped>
.page { padding: 20px; }
.mb { margin-bottom: 20px; }
.mt { margin-top: 14px; justify-content: flex-end; }
</style>
