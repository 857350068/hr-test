<template>
    <div class="attendance-clock">
        <h2>考勤打卡</h2>

        <el-card class="clock-card">
            <div class="clock-info">
                <div class="user-info">
                    <el-avatar :size="80" src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png" />
                    <div class="user-detail">
                        <h3>{{ userInfo.realName || '用户' }}</h3>
                        <p>{{ userInfo.deptId ? '技术部' : '部门' }}</p>
                    </div>
                </div>

                <div class="clock-buttons">
                    <el-button
                        type="primary"
                        size="large"
                        :disabled="todayAttendance.clockInTime || loading"
                        @click="handleClockIn"
                        class="clock-btn"
                    >
                        <el-icon><Clock /></el-icon>
                        上班打卡
                    </el-button>

                    <el-button
                        type="success"
                        size="large"
                        :disabled="!todayAttendance.clockInTime || todayAttendance.clockOutTime || loading"
                        @click="handleClockOut"
                        class="clock-btn"
                    >
                        <el-icon><Clock /></el-icon>
                        下班打卡
                    </el-button>

                    <el-button
                        type="warning"
                        size="large"
                        @click="handleExportAttendance"
                        class="clock-btn"
                    >
                        <el-icon><Download /></el-icon>
                        导出报表
                    </el-button>
                </div>

                <div class="clock-status">
                    <el-row :gutter="20">
                        <el-col :span="12">
                            <div class="status-item">
                                <span class="label">上班时间:</span>
                                <span class="value">{{ todayAttendance.clockInTime || '--:--' }}</span>
                            </div>
                            <div class="status-item">
                                <span class="label">状态:</span>
                                <el-tag v-if="todayAttendance.clockInTime && !todayAttendance.clockOutTime" type="success">已上班</el-tag>
                                <el-tag v-else-if="todayAttendance.clockOutTime" type="info">已下班</el-tag>
                                <el-tag v-else type="info">未打卡</el-tag>
                            </div>
                        </el-col>
                        <el-col :span="12">
                            <div class="status-item">
                                <span class="label">下班时间:</span>
                                <span class="value">{{ todayAttendance.clockOutTime || '--:--' }}</span>
                            </div>
                            <div class="status-item">
                                <span class="label">工作时长:</span>
                                <span class="value">{{ todayAttendance.workDuration ? (todayAttendance.workDuration / 60).toFixed(1) + '小时' : '--' }}</span>
                            </div>
                        </el-col>
                    </el-row>
                </div>
            </div>
        </el-card>

        <el-card class="stats-card" style="margin-top: 20px">
            <template #header>
                <span>本月考勤统计</span>
            </template>
            <el-row :gutter="20">
                <el-col :span="6">
                    <div class="stat-item">
                        <div class="stat-value">{{ stats.totalCount || 0 }}</div>
                        <div class="stat-label">出勤天数</div>
                    </div>
                </el-col>
                <el-col :span="6">
                    <div class="stat-item">
                        <div class="stat-value" style="color: #E6A23C">{{ stats.lateCount || 0 }}</div>
                        <div class="stat-label">迟到次数</div>
                    </div>
                </el-col>
                <el-col :span="6">
                    <div class="stat-item">
                        <div class="stat-value" style="color: #F56C6C">{{ stats.earlyLeaveCount || 0 }}</div>
                        <div class="stat-label">早退次数</div>
                    </div>
                </el-col>
                <el-col :span="6">
                    <div class="stat-item">
                        <div class="stat-value" style="color: #67C23A">{{ stats.normalCount || 0 }}</div>
                        <div class="stat-label">正常天数</div>
                    </div>
                </el-col>
            </el-row>
        </el-card>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Clock, Download } from '@element-plus/icons-vue'
import { getTodayAttendance, clockIn, clockOut, getAttendanceStats } from '@/api/attendance'

const loading = ref(false)
const userInfo = ref({})
const todayAttendance = ref({})
const stats = reactive({
    totalCount: 0,
    lateCount: 0,
    earlyLeaveCount: 0,
    normalCount: 0
})

onMounted(() => {
    loadUserInfo()
    loadTodayAttendance()
    loadStats()
})

const loadUserInfo = () => {
    const userStr = localStorage.getItem('userInfo')
    if (userStr) {
        userInfo.value = JSON.parse(userStr)
    }
}

const loadTodayAttendance = async () => {
    try {
        const res = await getTodayAttendance(userInfo.value.userId)
        todayAttendance.value = res.data || {}
    } catch (error) {
        console.error('获取今日考勤失败:', error)
    }
}

const loadStats = async () => {
    try {
        const now = new Date()
        const startDate = new Date(now.getFullYear(), now.getMonth(), 1)
        const res = await getAttendanceStats({
            startDate: formatDate(startDate),
            endDate: formatDate(now)
        })
        Object.assign(stats, res.data)
    } catch (error) {
        console.error('获取考勤统计失败:', error)
    }
}

const handleClockIn = async () => {
    loading.value = true
    try {
        await clockIn(userInfo.value.userId)
        ElMessage.success('上班打卡成功')
        loadTodayAttendance()
    } catch (error) {
        console.error('上班打卡失败:', error)
        ElMessage.error(error.message || '打卡失败')
    } finally {
        loading.value = false
    }
}

const handleClockOut = async () => {
    loading.value = true
    try {
        await clockOut(userInfo.value.userId)
        ElMessage.success('下班打卡成功')
        loadTodayAttendance()
    } catch (error) {
        console.error('下班打卡失败:', error)
        ElMessage.error(error.message || '打卡失败')
    } finally {
        loading.value = false
    }
}

// 导出考勤报表
const handleExportAttendance = async () => {
    try {
        const { exportToExcel } = await import('@/utils/excel')

        // 获取考勤统计数据
        const now = new Date()
        const startDate = new Date(now.getFullYear(), now.getMonth(), 1)
        const res = await getAttendanceStats({
            startDate: formatDate(startDate),
            endDate: formatDate(now)
        })

        // 构造导出数据
        const exportData = [{
            month: `${now.getFullYear()}年${now.getMonth() + 1}月`,
            totalCount: stats.totalCount,
            normalCount: stats.normalCount,
            lateCount: stats.lateCount,
            earlyLeaveCount: stats.earlyLeaveCount,
            absentCount: stats.totalCount - stats.normalCount - stats.lateCount - stats.earlyLeaveCount,
            normalRate: stats.totalCount > 0 ? ((stats.normalCount / stats.totalCount) * 100).toFixed(2) + '%' : '0%'
        }]

        // 字段映射配置
        const fieldMapping = {
            month: '月份',
            totalCount: '总打卡次数',
            normalCount: '正常打卡',
            lateCount: '迟到次数',
            earlyLeaveCount: '早退次数',
            absentCount: '缺勤次数',
            normalRate: '正常率'
        }

        // 导出Excel
        const filename = exportToExcel(exportData, '考勤统计报表', { fieldMapping })
        ElMessage.success(`导出成功: ${filename}`)
    } catch (error) {
        console.error('导出失败:', error)
        ElMessage.error('导出失败: ' + error.message)
    }
}

const formatDate = (date) => {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
}
</script>

<style scoped>
.attendance-clock {
    padding: 20px;
}

h2 {
    margin-bottom: 20px;
    color: #333;
}

.clock-card {
    max-width: 800px;
    margin: 0 auto;
}

.clock-info {
    text-align: center;
}

.user-info {
    margin-bottom: 40px;
}

.user-detail h3 {
    margin: 10px 0 5px 0;
    color: #333;
}

.user-detail p {
    margin: 0;
    color: #999;
}

.clock-buttons {
    display: flex;
    justify-content: center;
    gap: 20px;
    margin-bottom: 40px;
}

.clock-btn {
    width: 150px;
    height: 60px;
    font-size: 18px;
}

.clock-status {
    background: #f5f7fa;
    padding: 20px;
    border-radius: 8px;
}

.status-item {
    margin-bottom: 15px;
    display: flex;
    justify-content: space-between;
}

.status-item:last-child {
    margin-bottom: 0;
}

.status-item .label {
    color: #666;
}

.status-item .value {
    color: #333;
    font-weight: bold;
}

.stats-card {
    max-width: 800px;
    margin: 20px auto 0;
}

.stat-item {
    text-align: center;
    padding: 20px 0;
}

.stat-value {
    font-size: 32px;
    font-weight: bold;
    color: #409EFF;
    margin-bottom: 10px;
}

.stat-label {
    color: #999;
    font-size: 14px;
}
</style>
