<template>
    <div class="training-management">
        <h2>培训管理</h2>

        <!-- 功能标签页 -->
        <el-tabs v-model="activeTab" @tab-change="handleTabChange">
            <el-tab-pane label="培训课程管理" name="course">
                <div class="course-management">
                    <!-- 操作按钮 -->
                    <el-card style="margin-bottom: 20px">
                        <el-button type="primary" @click="handleAddCourse">
                            <el-icon><Plus /></el-icon>
                            新增课程
                        </el-button>
                        <el-button type="success" @click="handleExportTraining">
                            <el-icon><Download /></el-icon>
                            导出记录
                        </el-button>
                    </el-card>

                    <!-- 查询表单 -->
                    <el-card style="margin-bottom: 20px">
                        <el-form :inline="true" :model="searchForm">
                            <el-form-item label="课程名称">
                                <el-input v-model="searchForm.courseName" placeholder="请输入课程名称" clearable style="width: 150px" />
                            </el-form-item>
                            <el-form-item label="课程类型">
                                <el-select v-model="searchForm.courseType" placeholder="请选择" clearable style="width: 150px">
                                    <el-option label="新员工培训" :value="1" />
                                    <el-option label="技能培训" :value="2" />
                                    <el-option label="管理培训" :value="3" />
                                    <el-option label="安全培训" :value="4" />
                                    <el-option label="其他" :value="5" />
                                </el-select>
                            </el-form-item>
                            <el-form-item label="课程状态">
                                <el-select v-model="searchForm.courseStatus" placeholder="请选择" clearable style="width: 120px">
                                    <el-option label="未开始" :value="0" />
                                    <el-option label="进行中" :value="1" />
                                    <el-option label="已结束" :value="2" />
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
                            <el-table-column prop="courseName" label="课程名称" width="200" show-overflow-tooltip />
                            <el-table-column prop="courseType" label="课程类型" width="120">
                                <template #default="{ row }">
                                    {{ getCourseTypeText(row.courseType) }}
                                </template>
                            </el-table-column>
                            <el-table-column prop="instructor" label="培训讲师" width="100" />
                            <el-table-column prop="duration" label="培训时长" width="100">
                                <template #default="{ row }">{{ row.duration }}小时</template>
                            </el-table-column>
                            <el-table-column prop="location" label="培训地点" width="120" show-overflow-tooltip />
                            <el-table-column prop="startDate" label="开始时间" width="120" />
                            <el-table-column prop="capacity" label="名额" width="80">
                                <template #default="{ row }">{{ row.enrolledCount }}/{{ row.capacity }}</template>
                            </el-table-column>
                            <el-table-column prop="courseStatus" label="状态" width="100">
                                <template #default="{ row }">
                                    <el-tag v-if="row.courseStatus === 0" type="info">未开始</el-tag>
                                    <el-tag v-else-if="row.courseStatus === 1" type="warning">进行中</el-tag>
                                    <el-tag v-else type="success">已结束</el-tag>
                                </template>
                            </el-table-column>
                            <el-table-column label="操作" width="150" fixed="right">
                                <template #default="{ row }">
                                    <el-button type="primary" size="small" @click="handleEditCourse(row)">编辑</el-button>
                                    <el-button type="danger" size="small" @click="handleDeleteCourse(row)">删除</el-button>
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
                </div>
            </el-tab-pane>

            <el-tab-pane label="培训报名管理" name="enrollment">
                <div class="enrollment-management">
                    <!-- 操作按钮 -->
                    <el-card style="margin-bottom: 20px">
                        <el-button type="primary" @click="handleEnroll">
                            <el-icon><Plus /></el-icon>
                            报名培训
                        </el-button>
                        <el-button type="success" @click="handlePending">
                            <el-icon><DocumentChecked /></el-icon>
                            待审核({{ pendingCount }})
                        </el-button>
                    </el-card>

                    <!-- 查询表单 -->
                    <el-card style="margin-bottom: 20px">
                        <el-form :inline="true" :model="enrollmentSearchForm">
                            <el-form-item label="员工ID">
                                <el-input v-model="enrollmentSearchForm.empId" placeholder="请输入员工ID" clearable style="width: 120px" />
                            </el-form-item>
                            <el-form-item label="审核状态">
                                <el-select v-model="enrollmentSearchForm.approvalStatus" placeholder="请选择" clearable style="width: 120px">
                                    <el-option label="待审核" :value="0" />
                                    <el-option label="已通过" :value="1" />
                                    <el-option label="已拒绝" :value="2" />
                                </el-select>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" @click="handleEnrollmentSearch">查询</el-button>
                                <el-button @click="handleEnrollmentReset">重置</el-button>
                            </el-form-item>
                        </el-form>
                    </el-card>

                    <!-- 数据表格 -->
                    <el-card>
                        <el-table :data="enrollmentTableData" border style="width: 100%" v-loading="enrollmentLoading">
                            <el-table-column type="index" label="序号" width="60" />
                            <el-table-column prop="courseId" label="课程ID" width="80" />
                            <el-table-column prop="empId" label="员工ID" width="80" />
                            <el-table-column prop="enrollmentTime" label="报名时间" width="120" />
                            <el-table-column prop="approvalStatus" label="审核状态" width="100">
                                <template #default="{ row }">
                                    <el-tag v-if="row.approvalStatus === 0" type="warning">待审核</el-tag>
                                    <el-tag v-else-if="row.approvalStatus === 1" type="success">已通过</el-tag>
                                    <el-tag v-else type="danger">已拒绝</el-tag>
                                </template>
                            </el-table-column>
                            <el-table-column prop="attendanceStatus" label="出勤状态" width="100">
                                <template #default="{ row }">
                                    <el-tag v-if="row.attendanceStatus === 0" type="info">未出勤</el-tag>
                                    <el-tag v-else-if="row.attendanceStatus === 1" type="success">已出勤</el-tag>
                                    <el-tag v-else type="warning">请假</el-tag>
                                </template>
                            </el-table-column>
                            <el-table-column prop="score" label="成绩" width="80">
                                <template #default="{ row }">
                                    <span v-if="row.score !== null" style="font-weight: bold; color: #67C23A">{{ row.score }}分</span>
                                    <span v-else style="color: #999">-</span>
                                </template>
                            </el-table-column>
                            <el-table-column label="操作" width="250" fixed="right">
                                <template #default="{ row }">
                                    <el-button 
                                        v-if="row.approvalStatus === 0" 
                                        type="success" 
                                        size="small" 
                                        @click="handleApprove(row)"
                                    >
                                        审核
                                    </el-button>
                                    <el-button 
                                        v-if="row.approvalStatus === 1 && row.attendanceStatus === 0" 
                                        type="primary" 
                                        size="small" 
                                        @click="handleDoCheckIn(row)"
                                    >
                                        签到
                                    </el-button>
                                    <el-button 
                                        v-if="row.approvalStatus === 1 && row.score === null" 
                                        type="warning" 
                                        size="small" 
                                        @click="handleSubmitScore(row)"
                                    >
                                        成绩
                                    </el-button>
                                </template>
                            </el-table-column>
                        </el-table>

                        <!-- 分页 -->
                        <el-pagination
                            v-model:current-page="enrollmentPagination.page"
                            v-model:page-size="enrollmentPagination.size"
                            :page-sizes="[10, 20, 50, 100]"
                            :total="enrollmentPagination.total"
                            layout="total, sizes, prev, pager, next, jumper"
                            @size-change="handleEnrollmentSizeChange"
                            @current-change="handleEnrollmentCurrentChange"
                            style="margin-top: 20px; justify-content: flex-end"
                        />
                    </el-card>
                </div>
            </el-tab-pane>
        </el-tabs>

        <!-- 新增/编辑课程对话框 -->
        <el-dialog
            v-model="courseDialogVisible"
            :title="courseDialogTitle"
            width="600px"
            @close="handleCourseDialogClose"
        >
            <el-form :model="courseForm" :rules="courseRules" ref="courseFormRef" label-width="100px">
                <el-form-item label="课程名称" prop="courseName">
                    <el-input v-model="courseForm.courseName" placeholder="请输入课程名称" />
                </el-form-item>
                <el-form-item label="课程类型" prop="courseType">
                    <el-select v-model="courseForm.courseType" placeholder="请选择课程类型" style="width: 100%">
                        <el-option label="新员工培训" :value="1" />
                        <el-option label="技能培训" :value="2" />
                        <el-option label="管理培训" :value="3" />
                        <el-option label="安全培训" :value="4" />
                        <el-option label="其他" :value="5" />
                    </el-select>
                </el-form-item>
                <el-form-item label="课程描述" prop="courseDescription">
                    <el-input
                        v-model="courseForm.courseDescription"
                        type="textarea"
                        :rows="3"
                        placeholder="请输入课程描述"
                    />
                </el-form-item>
                <el-form-item label="培训讲师" prop="instructor">
                    <el-input v-model="courseForm.instructor" placeholder="请输入培训讲师" />
                </el-form-item>
                <el-form-item label="培训时长" prop="duration">
                    <el-input-number v-model="courseForm.duration" :min="0" style="width: 100%" />
                    <span style="margin-left: 10px">小时</span>
                </el-form-item>
                <el-form-item label="培训地点" prop="location">
                    <el-input v-model="courseForm.location" placeholder="请输入培训地点" />
                </el-form-item>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="开始时间" prop="startDate">
                            <el-date-picker
                                v-model="courseForm.startDate"
                                type="date"
                                placeholder="选择开始时间"
                                value-format="YYYY-MM-DD"
                                style="width: 100%"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="结束时间" prop="endDate">
                            <el-date-picker
                                v-model="courseForm.endDate"
                                type="date"
                                placeholder="选择结束时间"
                                value-format="YYYY-MM-DD"
                                style="width: 100%"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-form-item label="培训名额" prop="capacity">
                    <el-input-number v-model="courseForm.capacity" :min="1" style="width: 100%" />
                </el-form-item>
                <el-form-item label="课程状态" prop="courseStatus">
                    <el-radio-group v-model="courseForm.courseStatus">
                        <el-radio :value="0">未开始</el-radio>
                        <el-radio :value="1">进行中</el-radio>
                        <el-radio :value="2">已结束</el-radio>
                    </el-radio-group>
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="courseDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="handleCourseSubmit">保存</el-button>
            </template>
        </el-dialog>

        <!-- 报名对话框 -->
        <el-dialog
            v-model="enrollDialogVisible"
            title="培训报名"
            width="400px"
        >
            <el-form :model="enrollForm" :rules="enrollRules" ref="enrollFormRef" label-width="80px">
                <el-form-item label="课程ID" prop="courseId">
                    <el-input v-model="enrollForm.courseId" placeholder="请输入课程ID" />
                </el-form-item>
                <el-form-item label="员工ID" prop="empId">
                    <el-input v-model="enrollForm.empId" placeholder="请输入员工ID" />
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="enrollDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="handleEnrollSubmit">报名</el-button>
            </template>
        </el-dialog>

        <!-- 审核对话框 -->
        <el-dialog
            v-model="approveDialogVisible"
            title="审核培训报名"
            width="500px"
        >
            <el-form :model="approveForm" label-width="100px">
                <el-form-item label="审核结果">
                    <el-radio-group v-model="approveForm.approvalStatus">
                        <el-radio :value="1">通过</el-radio>
                        <el-radio :value="2">拒绝</el-radio>
                    </el-radio-group>
                </el-form-item>
                <el-form-item label="审核意见">
                    <el-input
                        v-model="approveForm.approvalComment"
                        type="textarea"
                        :rows="3"
                        placeholder="请输入审核意见"
                    />
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="approveDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="handleApproveSubmit">确定</el-button>
            </template>
        </el-dialog>

        <!-- 成绩对话框 -->
        <el-dialog
            v-model="scoreDialogVisible"
            title="提交培训成绩"
            width="500px"
        >
            <el-form :model="scoreForm" ref="scoreFormRef" label-width="100px">
                <el-form-item label="成绩" prop="score">
                    <el-input-number v-model="scoreForm.score" :min="0" :max="100" style="width: 100%" />
                    <span style="margin-left: 10px">满分100分</span>
                </el-form-item>
                <el-form-item label="培训反馈">
                    <el-input
                        v-model="scoreForm.feedback"
                        type="textarea"
                        :rows="3"
                        placeholder="请输入培训反馈"
                    />
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="scoreDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="handleScoreSubmit">提交</el-button>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, DocumentChecked, Download } from '@element-plus/icons-vue'
import { 
    getCourseList, 
    addCourse, 
    updateCourse, 
    deleteCourse,
    getEnrollmentList,
    enrollTraining,
    approveEnrollment,
    checkIn,
    submitScore
} from '@/api/training'

const activeTab = ref('course')
const loading = ref(false)
const enrollmentLoading = ref(false)
const courseDialogVisible = ref(false)
const enrollDialogVisible = ref(false)
const approveDialogVisible = ref(false)
const scoreDialogVisible = ref(false)
const pendingCount = ref(0)

const courseFormRef = ref(null)
const enrollFormRef = ref(null)
const scoreFormRef = ref(null)

const searchForm = reactive({
    courseName: '',
    courseType: null,
    courseStatus: null
})

const pagination = reactive({
    page: 1,
    size: 10,
    total: 0
})

const tableData = ref([])

const courseForm = reactive({
    courseId: null,
    courseName: '',
    courseType: null,
    courseDescription: '',
    instructor: '',
    duration: 0,
    location: '',
    startDate: '',
    endDate: '',
    capacity: 10,
    courseStatus: 0
})

const courseRules = {
    courseName: [
        { required: true, message: '请输入课程名称', trigger: 'blur' }
    ],
    courseType: [
        { required: true, message: '请选择课程类型', trigger: 'change' }
    ],
    instructor: [
        { required: true, message: '请输入培训讲师', trigger: 'blur' }
    ],
    duration: [
        { required: true, message: '请输入培训时长', trigger: 'change' }
    ]
}

const enrollmentSearchForm = reactive({
    empId: null,
    approvalStatus: null
})

const enrollmentPagination = reactive({
    page: 1,
    size: 10,
    total: 0
})

const enrollmentTableData = ref([])

const enrollForm = reactive({
    courseId: null,
    empId: null
})

const enrollRules = {
    courseId: [
        { required: true, message: '请输入课程ID', trigger: 'blur' }
    ],
    empId: [
        { required: true, message: '请输入员工ID', trigger: 'blur' }
    ]
}

const approveForm = reactive({
    enrollmentId: null,
    approverId: null,
    approvalStatus: 1,
    approvalComment: ''
})

const scoreForm = reactive({
    enrollmentId: null,
    score: 0,
    feedback: ''
})

onMounted(() => {
    loadCourseList()
    loadEnrollmentList()
})

const courseDialogTitle = ref('新增课程')

const getCourseTypeText = (type) => {
    const types = {
        1: '新员工培训',
        2: '技能培训',
        3: '管理培训',
        4: '安全培训',
        5: '其他'
    }
    return types[type] || '未知'
}

const handleTabChange = (tabName) => {
    if (tabName === 'course') {
        loadCourseList()
    } else if (tabName === 'enrollment') {
        loadEnrollmentList()
    }
}

const loadCourseList = async () => {
    loading.value = true
    try {
        const params = {
            page: pagination.page,
            size: pagination.size,
            courseName: searchForm.courseName,
            courseType: searchForm.courseType,
            courseStatus: searchForm.courseStatus
        }
        const res = await getCourseList(params)
        tableData.value = res.data.records
        pagination.total = res.data.total
    } catch (error) {
        console.error('获取课程列表失败:', error)
        ElMessage.error('获取课程列表失败')
    } finally {
        loading.value = false
    }
}

const handleSearch = () => {
    pagination.page = 1
    loadCourseList()
}

const handleReset = () => {
    searchForm.courseName = ''
    searchForm.courseType = null
    searchForm.courseStatus = null
    pagination.page = 1
    loadCourseList()
}

const handleSizeChange = (val) => {
    pagination.size = val
    pagination.page = 1
    loadCourseList()
}

const handleCurrentChange = (val) => {
    pagination.page = val
    loadCourseList()
}

const handleAddCourse = () => {
    courseDialogTitle.value = '新增课程'
    Object.assign(courseForm, {
        courseId: null,
        courseName: '',
        courseType: null,
        courseDescription: '',
        instructor: '',
        duration: 0,
        location: '',
        startDate: '',
        endDate: '',
        capacity: 10,
        courseStatus: 0
    })
    courseDialogVisible.value = true
}

// 导出培训记录
const handleExportTraining = async () => {
    try {
        const { exportToExcel } = await import('@/utils/excel')

        // 字段映射配置
        const fieldMapping = {
            courseName: '课程名称',
            courseType: '课程类型',
            courseDescription: '课程描述',
            instructor: '讲师',
            duration: '时长(小时)',
            location: '培训地点',
            startDate: '开始日期',
            endDate: '结束日期',
            capacity: '容量',
            enrolled: '已报名',
            courseStatus: '课程状态',
            createTime: '创建时间'
        }

        // 数据转换
        const exportData = tableData.value.map(row => ({
            ...row,
            courseType: row.courseType === 1 ? '新员工培训' : 
                       row.courseType === 2 ? '技能培训' : 
                       row.courseType === 3 ? '管理培训' : 
                       row.courseType === 4 ? '安全培训' : '其他',
            courseStatus: row.courseStatus === 0 ? '未开始' : 
                         row.courseStatus === 1 ? '进行中' : '已结束'
        }))

        // 导出Excel
        const filename = exportToExcel(exportData, '培训记录', { fieldMapping })
        ElMessage.success(`导出成功: ${filename}`)
    } catch (error) {
        console.error('导出失败:', error)
        ElMessage.error('导出失败: ' + error.message)
    }
}

const handleEditCourse = (row) => {
    courseDialogTitle.value = '编辑课程'
    Object.assign(courseForm, row)
    courseDialogVisible.value = true
}

const handleDeleteCourse = (row) => {
    ElMessageBox.confirm(`确定要删除该课程吗?`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(async () => {
        try {
            await deleteCourse(row.courseId)
            ElMessage.success('删除成功')
            loadCourseList()
        } catch (error) {
            console.error('删除失败:', error)
            ElMessage.error('删除失败')
        }
    }).catch(() => {})
}

const handleCourseDialogClose = () => {
    courseFormRef.value?.resetFields()
}

const handleCourseSubmit = () => {
    courseFormRef.value.validate(async (valid) => {
        if (!valid) return

        try {
            if (courseForm.courseId) {
                await updateCourse(courseForm)
                ElMessage.success('更新成功')
            } else {
                await addCourse(courseForm)
                ElMessage.success('添加成功')
            }
            courseDialogVisible.value = false
            loadCourseList()
        } catch (error) {
            console.error('操作失败:', error)
            ElMessage.error('操作失败')
        }
    })
}

const loadEnrollmentList = async () => {
    enrollmentLoading.value = true
    try {
        const params = {
            page: enrollmentPagination.page,
            size: enrollmentPagination.size,
            empId: enrollmentSearchForm.empId,
            approvalStatus: enrollmentSearchForm.approvalStatus
        }
        const res = await getEnrollmentList(params)
        enrollmentTableData.value = res.data.records
        enrollmentPagination.total = res.data.total
        
        pendingCount.value = enrollmentTableData.value.filter(item => item.approvalStatus === 0).length
    } catch (error) {
        console.error('获取报名列表失败:', error)
        ElMessage.error('获取报名列表失败')
    } finally {
        enrollmentLoading.value = false
    }
}

const handleEnrollmentSearch = () => {
    enrollmentPagination.page = 1
    loadEnrollmentList()
}

const handleEnrollmentReset = () => {
    enrollmentSearchForm.empId = null
    enrollmentSearchForm.approvalStatus = null
    enrollmentPagination.page = 1
    loadEnrollmentList()
}

const handleEnrollmentSizeChange = (val) => {
    enrollmentPagination.size = val
    enrollmentPagination.page = 1
    loadEnrollmentList()
}

const handleEnrollmentCurrentChange = (val) => {
    enrollmentPagination.page = val
    loadEnrollmentList()
}

const handleEnroll = () => {
    enrollDialogVisible.value = true
}

const handleEnrollSubmit = () => {
    enrollFormRef.value.validate(async (valid) => {
        if (!valid) return

        try {
            await enrollTraining(enrollForm)
            ElMessage.success('报名成功')
            enrollDialogVisible.value = false
            loadEnrollmentList()
        } catch (error) {
            console.error('报名失败:', error)
            ElMessage.error('报名失败')
        }
    })
}

const handleApprove = (row) => {
    approveForm.enrollmentId = row.enrollmentId
    approveForm.approverId = JSON.parse(localStorage.getItem('userInfo')).userId
    approveForm.approvalStatus = 1
    approveForm.approvalComment = ''
    approveDialogVisible.value = true
}

const handleApproveSubmit = async () => {
    try {
        await approveEnrollment(approveForm)
        ElMessage.success('审核成功')
        approveDialogVisible.value = false
        loadEnrollmentList()
    } catch (error) {
        console.error('审核失败:', error)
        ElMessage.error('审核失败')
    }
}

const handleDoCheckIn = (row) => {
    ElMessageBox.confirm(`确定要为该员工签到吗?`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(async () => {
        try {
            await checkIn(row.enrollmentId)
            ElMessage.success('签到成功')
            loadEnrollmentList()
        } catch (error) {
            console.error('签到失败:', error)
            ElMessage.error('签到失败')
        }
    }).catch(() => {})
}

const handleSubmitScore = (row) => {
    scoreForm.enrollmentId = row.enrollmentId
    scoreForm.score = 0
    scoreForm.feedback = ''
    scoreDialogVisible.value = true
}

const handleScoreSubmit = () => {
    scoreFormRef.value.validate(async (valid) => {
        if (!valid) return

        try {
            await submitScore(scoreForm)
            ElMessage.success('提交成功')
            scoreDialogVisible.value = false
            loadEnrollmentList()
        } catch (error) {
            console.error('提交失败:', error)
            ElMessage.error('提交失败')
        }
    })
}

const handlePending = () => {
    enrollmentSearchForm.approvalStatus = 0
    handleEnrollmentSearch()
}
</script>

<style scoped>
.training-management {
    padding: 20px;
}

h2 {
    margin-bottom: 20px;
    color: #333;
}
</style>
