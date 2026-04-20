<template>
    <div class="dashboard">
        <h2>首页看板</h2>

        <!-- 统计卡片 -->
        <el-row :gutter="20" class="stats-row">
            <el-col :span="6">
                <el-card class="stat-card">
                    <div class="stat-content">
                        <div class="stat-icon" style="background: #409EFF">
                            <el-icon><User /></el-icon>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value">{{ stats.totalCount }}</div>
                            <div class="stat-label">总人数</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="6">
                <el-card class="stat-card">
                    <div class="stat-content">
                        <div class="stat-icon" style="background: #67C23A">
                            <el-icon><CirclePlus /></el-icon>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value">{{ stats.monthlyHire }}</div>
                            <div class="stat-label">本月入职</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="6">
                <el-card class="stat-card">
                    <div class="stat-content">
                        <div class="stat-icon" style="background: #E6A23C">
                            <el-icon><Remove /></el-icon>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value">{{ stats.monthlyResign }}</div>
                            <div class="stat-label">本月离职</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="6">
                <el-card class="stat-card">
                    <div class="stat-content">
                        <div class="stat-icon" style="background: #F56C6C">
                            <el-icon><TrendCharts /></el-icon>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value">{{ stats.turnoverRate }}%</div>
                            <div class="stat-label">流失率</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
        </el-row>

        <!-- 快捷入口 -->
        <el-row :gutter="20" style="margin-top: 20px">
            <el-col :span="12">
                <el-card class="welcome-card" shadow="hover">
                    <h3>欢迎使用人力资源数据中心</h3>
                    <p>本系统基于 SpringBoot + Vue3 + Hadoop + Hive 构建，提供员工、考勤、绩效、薪酬、培训、数据分析与系统管理等功能。</p>
                </el-card>
            </el-col>
            <el-col :span="12">
                <el-card class="welcome-card link-card" shadow="hover" @click="goAnalysis">
                    <h3>数据分析中心</h3>
                    <p>查看组织效能、人才梯队、薪酬分析、流失与人才缺口预警等 Hive 分析报表。</p>
                    <div class="link-hint">点击进入数据分析 →</div>
                </el-card>
            </el-col>
        </el-row>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getDashboardStats } from '@/api/employee'

const router = useRouter()

const stats = ref({
    totalCount: 0,
    monthlyHire: 0,
    monthlyResign: 0,
    turnoverRate: 0
})

function goAnalysis() {
    router.push('/analysis/dashboard')
}

onMounted(async () => {
    try {
        const res = await getDashboardStats()
        Object.assign(stats.value, res.data || {})
    } catch (error) {
        console.error('获取统计数据失败:', error)
    }
})
</script>

<style scoped>
.dashboard {
    padding: 20px;
}

h2 {
    margin-bottom: 20px;
    color: #333;
}

.stats-row {
    margin-bottom: 20px;
}

.stat-card {
    cursor: pointer;
    transition: all 0.3s;
}

.stat-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.stat-content {
    display: flex;
    align-items: center;
}

.stat-icon {
    width: 60px;
    height: 60px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 30px;
    margin-right: 20px;
}

.stat-info {
    flex: 1;
}

.stat-value {
    font-size: 28px;
    font-weight: bold;
    color: #333;
    margin-bottom: 8px;
}

.stat-label {
    font-size: 14px;
    color: #999;
}

.welcome-card h3 {
    color: #333;
    margin-bottom: 10px;
}

.welcome-card p {
    color: #666;
    line-height: 1.6;
}

.link-card {
    cursor: pointer;
    transition: all 0.3s;
}

.link-card:hover {
    transform: translateY(-2px);
}

.link-hint {
    margin-top: 12px;
    color: #409eff;
    font-size: 14px;
}
</style>
