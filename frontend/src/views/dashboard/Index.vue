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
                            <div class="stat-value">12</div>
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
                            <div class="stat-value">5</div>
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
                            <div class="stat-value">2.1%</div>
                            <div class="stat-label">流失率</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
        </el-row>

        <!-- 欢迎信息 -->
        <el-card class="welcome-card" style="margin-top: 20px">
            <h3>欢迎使用人力资源数据中心</h3>
            <p>本系统基于SpringBoot + Vue3 + Hadoop + Hive构建,提供员工管理、考勤管理、绩效管理、薪酬管理、数据分析等功能。</p>
        </el-card>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getTotalCount } from '@/api/employee'

const stats = ref({
    totalCount: 0
})

onMounted(async () => {
    try {
        const res = await getTotalCount()
        stats.value.totalCount = res.data
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
</style>
