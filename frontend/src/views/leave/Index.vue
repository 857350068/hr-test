<template>
    <div class="leave-management">
        <h2>请假管理</h2>

        <!-- 操作按钮 -->
        <el-card style="margin-bottom: 20px">
            <el-button type="primary" @click="handleApply">
                <el-icon><Plus /></el-icon>
                申请请假
            </el-button>
            <el-button type="success" @click="handlePending">
                <el-icon><Document /></el-icon>
                待审批({{ pendingCount }})
            </el-button>
        </el-card>

        <!-- 查询表单 -->
        <el-card style="margin-bottom: 20px">
            <el-form :inline="true" :model="searchForm">
                <el-form-item label="请假类型">
                    <el-select v-model="searchForm.leaveType" placeholder="请选择" clearable>
                        <el-option label="事假" :value="0" />
                        <el-option label="病假" :value="1" />
                        <el-option label="年假" :value="2" />
                        <el-option label="婚假" :value="3" />
                        <el-option label="产假" :value="4" />
                        <el-option label="丧假" :value="5" />
                        <el-option label="其他" :value="6" />
                    </el-select>
                </el-form-item>
                <el-form-item label="审批状态">
                    <el-select v-model="searchForm.approvalStatus" placeholder="请选择" clearable>
                        <el-option label="待审批" :value="0" />
                        <el-option label="已同意" :value="1" />
                        <el-option label="已拒绝" :value="2" />
                        <el-option label="已撤回" :value="3" />
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="handleSearch">查询</el-button>
                    <el-button @click="handleReset">重置</el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <!-- 数据表格 -->
        <el-card>
            <el-table :data="tableData" border style="width: 100%" v-loading="loading">
                <el-table-column type="index" label="序号" width="60" />
                <el-table-column prop="empId" label="员工ID" width="80" />
                <el-table-column prop="leaveType" label="请假类型" width="100">
                    <template #default="{ row }">
                        {{ getLeaveTypeText(row.leaveType) }}
                    </template>
                </el-table-column>
                <el-table-column prop="startTime" label="开始时间" width="180" />
                <el-table-column prop="endTime" label="结束时间" width="180" />
                <el-table-column prop="leaveDuration" label="请假时长(小时)" width="140" />
                <el-table-column prop="reason" label="请假原因" width="200" show-overflow-tooltip />
                <el-table-column prop="approvalStatus" label="审批状态" width="100">
                    <template #default="{ row }">
                        <el-tag v-if="row.approvalStatus === 0" type="warning">待审批</el-tag>
                        <el-tag v-else-if="row.approvalStatus === 1" type="success">已同意</el-tag>
                        <el-tag v-else-if="row.approvalStatus === 2" type="danger">已拒绝</el-tag>
                        <el-tag v-else type="info">已撤回</el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="create_time" label="申请时间" width="180" />
                <el-table-column label="操作" width="200" fixed="right">
                    <template #default="{ row }">
                        <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
                        <el-button 
                            v-if="row.approvalStatus === 0" 
                            type="success" 
                            size="small" 
                            @click="handleApprove(row)"
                        >
                            审批
                        </el-button>
                        <el-button 
                            v-if="row.approvalStatus === 0" 
                            type="danger" 
                            size="small" 
                            @click="handleWithdraw(row)"
                        >
                            撤回
                        </el-button>
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

        <!-- 申请请假对话框 -->
        <el-dialog
            v-model="applyDialogVisible"
            title="申请请假"
            width="600px"
            @close="handleApplyDialogClose"
        >
            <el-form :model="applyForm" :rules="applyRules" ref="applyFormRef" label-width="100px">
                <el-form-item label="请假类型" prop="leaveType">
                    <el-select v-model="applyForm.leaveType" placeholder="请选择请假类型" style="width: 100%">
                        <el-option label="事假" :value="0" />
                        <el-option label="病假" :value="1" />
                        <el-option label="年假" :value="2" />
                        <el-option label="婚假" :value="3" />
                        <el-option label="产假" :value="4" />
                        <el-option label="丧假" :value="5" />
                        <el-option label="其他" :value="6" />
                    </el-select>
                </el-form-item>
                <el-form-item label="开始时间" prop="startTime">
                    <el-date-picker
                        v-model="applyForm.startTime"
                        type="datetime"
                        placeholder="选择开始时间"
                        value-format="YYYY-MM-DD HH:mm:ss"
                        style="width: 100%"
                    />
                </el-form-item>
                <el-form-item label="结束时间" prop="endTime">
                    <el-date-picker
                        v-model="applyForm.endTime"
                        type="datetime"
                        placeholder="选择结束时间"
                        value-format="YYYY-MM-DD HH:mm:ss"
                        style="width: 100%"
                    />
                </el-form-item>
                <el-form-item label="请假原因" prop="reason">
                    <el-input
                        v-model="applyForm.reason"
                        type="textarea"
                        :rows="4"
                        placeholder="请输入请假原因"
                    />
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="applyDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="handleApplySubmit">提交申请</el-button>
            </template>
        </el-dialog>

        <!-- 审批对话框 -->
        <el-dialog
            v-model="approveDialogVisible"
            title="审批请假"
            width="500px"
        >
            <el-form :model="approveForm" label-width="100px">
                <el-form-item label="审批结果">
                    <el-radio-group v-model="approveForm.status">
                        <el-radio :value="1">同意</el-radio>
                        <el-radio :value="2">拒绝</el-radio>
                    </el-radio-group>
                </el-form-item>
                <el-form-item label="审批意见">
                    <el-input
                        v-model="approveForm.comment"
                        type="textarea"
                        :rows="3"
                        placeholder="请输入审批意见"
                    />
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="approveDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="handleApproveSubmit">确定</el-button>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getLeaveList, applyLeave, approveLeave, withdrawLeave } from '@/api/leave'

const loading = ref(false)
const applyDialogVisible = ref(false)
const approveDialogVisible = ref(false)
const pendingCount = ref(0)
const applyFormRef = ref(null)

const searchForm = reactive({
    leaveType: null,
    approvalStatus: null
})

const pagination = reactive({
    page: 1,
    size: 10,
    total: 0
})

const tableData = ref([])

const applyForm = reactive({
    empId: null,
    leaveType: null,
    startTime: '',
    endTime: '',
    reason: ''
})

const approveForm = reactive({
    leaveId: null,
    approverId: null,
    status: 1,
    comment: ''
})

const applyRules = {
    leaveType: [
        { required: true, message: '请选择请假类型', trigger: 'change' }
    ],
    startTime: [
        { required: true, message: '请选择开始时间', trigger: 'change' }
    ],
    endTime: [
        { required: true, message: '请选择结束时间', trigger: 'change' }
    ],
    reason: [
        { required: true, message: '请输入请假原因', trigger: 'blur' }
    ]
}

onMounted(() => {
    loadLeaveList()
})

const getLeaveTypeText = (type) => {
    const types = {
        0: '事假',
        1: '病假',
        2: '年假',
        3: '婚假',
        4: '产假',
        5: '丧假',
        6: '其他'
    }
    return types[type] || '未知'
}

const loadLeaveList = async () => {
    loading.value = true
    try {
        const params = {
            page: pagination.page,
            size: pagination.size,
            leaveType: searchForm.leaveType,
            approvalStatus: searchForm.approvalStatus
        }
        const res = await getLeaveList(params)
        tableData.value = res.data.records
        pagination.total = res.data.total
        
        // 统计待审批数量
        pendingCount.value = tableData.value.filter(item => item.approvalStatus === 0).length
    } catch (error) {
        console.error('获取请假列表失败:', error)
        ElMessage.error('获取请假列表失败')
    } finally {
        loading.value = false
    }
}

const handleSearch = () => {
    pagination.page = 1
    loadLeaveList()
}

const handleReset = () => {
    searchForm.leaveType = null
    searchForm.approvalStatus = null
    pagination.page = 1
    loadLeaveList()
}

const handleSizeChange = (val) => {
    pagination.size = val
    pagination.page = 1
    loadLeaveList()
}

const handleCurrentChange = (val) => {
    pagination.page = val
    loadLeaveList()
}

const handleApply = () => {
    applyDialogVisible.value = true
    applyForm.empId = JSON.parse(localStorage.getItem('userInfo')).userId
}

const handleApplyDialogClose = () => {
    applyFormRef.value?.resetFields()
    Object.assign(applyForm, {
        empId: null,
        leaveType: null,
        startTime: '',
        endTime: '',
        reason: ''
    })
}

const handleApplySubmit = () => {
    applyFormRef.value.validate(async (valid) => {
        if (!valid) return

        try {
            await applyLeave(applyForm)
            ElMessage.success('申请成功')
            applyDialogVisible.value = false
            loadLeaveList()
        } catch (error) {
            console.error('申请失败:', error)
            ElMessage.error('申请失败')
        }
    })
}

const handleView = (row) => {
    ElMessageBox.alert(`
        请假类型: ${getLeaveTypeText(row.leaveType)}
        开始时间: ${row.startTime}
        结束时间: ${row.endTime}
        请假时长: ${row.leaveDuration}小时
        请假原因: ${row.reason}
        审批状态: ${row.approvalStatus === 0 ? '待审批' : row.approvalStatus === 1 ? '已同意' : row.approvalStatus === 2 ? '已拒绝' : '已撤回'}
        ${row.approvalComment ? '审批意见: ' + row.approvalComment : ''}
    `, '请假详情')
}

const handleApprove = (row) => {
    approveForm.leaveId = row.leaveId
    approveForm.approverId = JSON.parse(localStorage.getItem('userInfo')).userId
    approveForm.status = 1
    approveForm.comment = ''
    approveDialogVisible.value = true
}

const handleApproveSubmit = async () => {
    try {
        await approveLeave(approveForm)
        ElMessage.success('审批成功')
        approveDialogVisible.value = false
        loadLeaveList()
    } catch (error) {
        console.error('审批失败:', error)
        ElMessage.error('审批失败')
    }
}

const handleWithdraw = (row) => {
    ElMessageBox.confirm(`确定要撤回该请假申请吗?`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(async () => {
        try {
            await withdrawLeave({
                leaveId: row.leaveId,
                empId: row.empId
            })
            ElMessage.success('撤回成功')
            loadLeaveList()
        } catch (error) {
            console.error('撤回失败:', error)
            ElMessage.error('撤回失败')
        }
    }).catch(() => {})
}

const handlePending = () => {
    searchForm.approvalStatus = 0
    handleSearch()
}
</script>

<style scoped>
.leave-management {
    padding: 20px;
}

h2 {
    margin-bottom: 20px;
    color: #333;
}
</style>
