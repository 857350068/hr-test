<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">用户管理</h2>
    </div>
    <el-card>
      <el-form inline class="mb-4">
        <el-form-item label="工号">
          <el-input v-model="query.username" placeholder="工号" clearable style="width: 120px" />
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="query.role" placeholder="角色" clearable style="width: 120px">
            <el-option label="HR管理员" value="HR_ADMIN" />
            <el-option label="部门主管" value="DEPT_HEAD" />
            <el-option label="管理层" value="MANAGEMENT" />
            <el-option label="普通员工" value="EMPLOYEE" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="tableData" stripe>
        <el-table-column prop="username" label="工号" width="100" />
        <el-table-column prop="name" label="姓名" width="100" />
        <el-table-column prop="role" label="角色" width="120" />
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">{{ row.status === 1 ? '启用' : '禁用' }}</template>
        </el-table-column>
        <el-table-column label="操作" width="150">
          <template #default="{ row }">
            <el-button type="primary" link @click="edit(row)">编辑</el-button>
            <el-button type="danger" link @click="del(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :total="page.total"
        layout="total, prev, pager, next"
        @current-change="load"
        style="margin-top: 16px"
      />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getUserPage, deleteUser } from '@/api/admin'
import { ElMessage, ElMessageBox } from 'element-plus'

const query = reactive({ username: '', role: '' })
const page = reactive({ current: 1, size: 10, total: 0 })
const tableData = ref([])

const load = async () => {
  try {
    const res = await getUserPage({ current: page.current, size: page.size, username: query.username, role: query.role })
    tableData.value = res.data.records || []
    page.total = res.data.total || 0
  } catch (e) {}
}

const edit = (row) => {
  ElMessage.info('请在后端扩展编辑弹窗或跳转编辑页')
}

const del = async (id) => {
  await ElMessageBox.confirm('确定删除该用户？', '提示', { type: 'warning' })
  try {
    await deleteUser(id)
    ElMessage.success('已删除')
    load()
  } catch (e) {}
}

onMounted(load)
</script>
