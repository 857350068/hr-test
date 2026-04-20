<template>
  <div class="page">
    <el-card class="mb">
      <el-form :inline="true">
        <el-form-item label="关键词">
          <el-input v-model="query.keyword" placeholder="计划编号/部门/岗位/负责人" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="query.status" clearable placeholder="全部状态" style="width: 150px">
            <el-option label="草稿" :value="0" />
            <el-option label="招聘中" :value="1" />
            <el-option label="已完成" :value="2" />
            <el-option label="已关闭" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadData">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
          <el-button type="success" @click="openAdd">新增招聘计划</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card>
      <el-table :data="tableData" border v-loading="loading">
        <el-table-column prop="recruitCode" label="计划编号" width="130" />
        <el-table-column prop="department" label="部门" width="120" />
        <el-table-column prop="position" label="岗位" width="150" />
        <el-table-column prop="planCount" label="计划人数" width="90" />
        <el-table-column prop="hiredCount" label="已入职" width="90" />
        <el-table-column prop="budget" label="预算" width="120" />
        <el-table-column prop="owner" label="负责人" width="110" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusMap[row.status]?.type || 'info'">{{ statusMap[row.status]?.label || row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="startDate" label="开始日期" width="120" />
        <el-table-column prop="endDate" label="结束日期" width="120" />
        <el-table-column prop="remark" label="备注" min-width="180" show-overflow-tooltip />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="openEdit(row)">编辑</el-button>
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

    <el-dialog v-model="dialogVisible" :title="form.recruitId ? '编辑招聘计划' : '新增招聘计划'" width="640px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="计划编号"><el-input v-model="form.recruitCode" /></el-form-item>
        <el-form-item label="部门"><el-input v-model="form.department" /></el-form-item>
        <el-form-item label="岗位"><el-input v-model="form.position" /></el-form-item>
        <el-form-item label="计划人数"><el-input-number v-model="form.planCount" :min="1" /></el-form-item>
        <el-form-item label="已入职"><el-input-number v-model="form.hiredCount" :min="0" /></el-form-item>
        <el-form-item label="预算"><el-input-number v-model="form.budget" :min="0" :precision="2" /></el-form-item>
        <el-form-item label="负责人"><el-input v-model="form.owner" /></el-form-item>
        <el-form-item label="状态">
          <el-select v-model="form.status" style="width: 100%">
            <el-option label="草稿" :value="0" />
            <el-option label="招聘中" :value="1" />
            <el-option label="已完成" :value="2" />
            <el-option label="已关闭" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="起止日期">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="备注"><el-input v-model="form.remark" type="textarea" /></el-form-item>
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
import { addRecruitment, deleteRecruitment, getRecruitmentList, updateRecruitment } from '@/api/recruitment'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const dialogVisible = ref(false)
const dateRange = ref([])
const query = reactive({ page: 1, size: 10, keyword: '', status: undefined })
const form = reactive({
  recruitId: null,
  recruitCode: '',
  department: '',
  position: '',
  planCount: 1,
  hiredCount: 0,
  budget: 0,
  status: 0,
  owner: '',
  startDate: '',
  endDate: '',
  remark: ''
})

const statusMap = {
  0: { label: '草稿', type: 'info' },
  1: { label: '招聘中', type: 'warning' },
  2: { label: '已完成', type: 'success' },
  3: { label: '已关闭', type: 'danger' }
}

async function loadData() {
  loading.value = true
  try {
    const res = await getRecruitmentList(query)
    tableData.value = res.data?.records || []
    total.value = res.data?.total || 0
  } finally {
    loading.value = false
  }
}

function resetQuery() {
  query.keyword = ''
  query.status = undefined
  query.page = 1
  loadData()
}

function openAdd() {
  Object.assign(form, {
    recruitId: null,
    recruitCode: '',
    department: '',
    position: '',
    planCount: 1,
    hiredCount: 0,
    budget: 0,
    status: 0,
    owner: '',
    startDate: '',
    endDate: '',
    remark: ''
  })
  dateRange.value = []
  dialogVisible.value = true
}

function openEdit(row) {
  Object.assign(form, row)
  dateRange.value = [row.startDate, row.endDate]
  dialogVisible.value = true
}

async function submit() {
  if (dateRange.value?.length === 2) {
    form.startDate = dateRange.value[0]
    form.endDate = dateRange.value[1]
  }
  if (!form.recruitCode || !form.department || !form.position) {
    ElMessage.warning('请填写计划编号、部门和岗位')
    return
  }
  if (form.recruitId) {
    await updateRecruitment(form)
  } else {
    await addRecruitment(form)
  }
  ElMessage.success('保存成功')
  dialogVisible.value = false
  await loadData()
}

async function remove(row) {
  await ElMessageBox.confirm(`确认删除招聘计划 ${row.recruitCode} 吗？`, '提示', { type: 'warning' })
  await deleteRecruitment(row.recruitId)
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
