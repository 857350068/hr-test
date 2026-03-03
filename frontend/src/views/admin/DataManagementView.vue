<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">数据管理（员工档案）</h2>
    </div>
    <el-card>
      <el-form inline class="mb-4">
        <el-form-item label="员工编号">
          <el-input v-model="query.employeeNo" placeholder="员工编号" clearable style="width: 120px" />
        </el-form-item>
        <el-form-item label="部门">
          <el-input v-model="query.deptName" placeholder="部门" clearable style="width: 120px" />
        </el-form-item>
        <el-form-item label="周期">
          <el-input v-model="query.period" placeholder="如202601" clearable style="width: 100px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="tableData" stripe>
        <el-table-column prop="employeeNo" label="员工编号" width="100" />
        <el-table-column prop="name" label="姓名" width="80" />
        <el-table-column prop="deptName" label="部门" width="100" />
        <el-table-column prop="job" label="岗位" width="100" />
        <el-table-column prop="categoryId" label="分类ID" width="80" />
        <el-table-column prop="value" label="指标值" width="80" />
        <el-table-column prop="period" label="周期" width="80" />
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
import { getEmployeePage } from '@/api/data'

const query = reactive({ employeeNo: '', deptName: '', period: '' })
const page = reactive({ current: 1, size: 10, total: 0 })
const tableData = ref([])

const load = async () => {
  try {
    const res = await getEmployeePage({
      current: page.current,
      size: page.size,
      employeeNo: query.employeeNo,
      deptName: query.deptName,
      period: query.period
    })
    tableData.value = res.data.records || []
    page.total = res.data.total || 0
  } catch (e) {}
}

onMounted(load)
</script>
