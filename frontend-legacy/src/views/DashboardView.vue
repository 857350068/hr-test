<template>
  <div class="dashboard-container">
    <div class="page-header">
      <h2 class="page-title">仪表盘</h2>
      <p class="page-description">人力资源数据中心概览</p>
    </div>

    <el-row :gutter="16" class="mb-4">
      <el-col :xs="24" :sm="12" :md="6">
        <div class="stat-card primary">
          <div class="stat-card-title">员工总数</div>
          <div class="stat-card-value">{{ statistics.totalEmployees }}</div>
          <div class="stat-card-footer">较上月 +{{ statistics.employeeGrowth }}%</div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <div class="stat-card success">
          <div class="stat-card-title">平均绩效</div>
          <div class="stat-card-value">{{ statistics.avgPerformance }}</div>
          <div class="stat-card-footer">较上月 +{{ statistics.performanceGrowth }}%</div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <div class="stat-card warning">
          <div class="stat-card-title">人力成本</div>
          <div class="stat-card-value">{{ statistics.totalCost }}</div>
          <div class="stat-card-footer">较上月 +{{ statistics.costGrowth }}%</div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <div class="stat-card danger">
          <div class="stat-card-title">流失率</div>
          <div class="stat-card-value">{{ statistics.turnoverRate }}%</div>
          <div class="stat-card-footer">较上月 {{ statistics.turnoverChange }}%</div>
        </div>
      </el-col>
    </el-row>

    <el-card class="mb-4" shadow="never">
      <template #header>
        <div class="card-header">
          <span class="card-title">数据分类</span>
        </div>
      </template>
      <el-row :gutter="16">
        <el-col v-for="cat in categoryRoutes" :key="cat.path" :xs="12" :sm="8" :md="6" :lg="3">
          <div class="category-card" @click="$router.push(cat.path)">
            <el-icon :size="32" :color="cat.color"><component :is="cat.icon" /></el-icon>
            <div class="category-name">{{ cat.name }}</div>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <el-row :gutter="16">
      <el-col :xs="24" :md="12">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span class="card-title">预警信息</span>
              <el-tag type="danger" size="small">{{ warnings.length }}</el-tag>
            </div>
          </template>
          <div v-if="!warnings.length" class="empty-state">暂无预警信息</div>
          <div v-else class="warning-list">
            <div v-for="w in warnings" :key="w.id" class="warning-item" :class="w.level">
              <span class="warning-text">{{ w.message }}</span>
              <el-tag :type="w.level === 'high' ? 'danger' : 'warning'" size="small">{{ w.level === 'high' ? '高' : '中' }}</el-tag>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :md="12">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span class="card-title">快捷入口</span>
            </div>
          </template>
          <el-row :gutter="12">
            <el-col :span="12">
              <el-button type="primary" style="width: 100%" @click="$router.push('/data-analysis')">数据分析</el-button>
            </el-col>
            <el-col :span="12">
              <el-button style="width: 100%" @click="$router.push('/my-favorites')">我的收藏</el-button>
            </el-col>
          </el-row>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getStatistics, getWarnings } from '@/api/dashboard'
import { DataAnalysis, UserFilled, Wallet, TrendCharts, Warning, Document, Money, Star } from '@element-plus/icons-vue'

const statistics = ref({
  totalEmployees: 0,
  employeeGrowth: 2.5,
  avgPerformance: '0',
  performanceGrowth: 3.2,
  totalCost: '¥1,258万',
  costGrowth: 1.8,
  turnoverRate: 5.2,
  turnoverChange: -0.3
})
const warnings = ref([])

const categoryRoutes = [
  { name: '组织效能', path: '/analysis/organization-efficiency', icon: DataAnalysis, color: '#409EFF' },
  { name: '人才梯队', path: '/analysis/talent-pipeline', icon: UserFilled, color: '#67C23A' },
  { name: '薪酬福利', path: '/analysis/compensation-benefit', icon: Wallet, color: '#E6A23C' },
  { name: '绩效管理', path: '/analysis/performance-management', icon: TrendCharts, color: '#F56C6C' },
  { name: '员工流失', path: '/analysis/employee-turnover', icon: Warning, color: '#909399' },
  { name: '培训效果', path: '/analysis/training-effect', icon: Document, color: '#606266' },
  { name: '人力成本', path: '/analysis/human-cost-optimization', icon: Money, color: '#409EFF' },
  { name: '人才发展', path: '/analysis/talent-development', icon: Star, color: '#67C23A' }
]

onMounted(async () => {
  try {
    const [s, w] = await Promise.all([getStatistics(), getWarnings()])
    if (s.data) Object.assign(statistics.value, s.data)
    if (w.data && w.data.list) warnings.value = w.data.list
  } catch (e) {
    // keep default
  }
})
</script>

<style scoped>
.dashboard-container {
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 24px;
}

.page-title {
  font-size: 24px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0 0 8px 0;
}

.page-description {
  font-size: 14px;
  color: var(--text-secondary);
  margin: 0;
}

.stat-card {
  padding: 20px;
  border-radius: var(--border-radius);
  background: var(--bg-card);
  box-shadow: var(--shadow-light);
  margin-bottom: 16px;
  transition: all var(--transition-time);
  border-left: 4px solid transparent;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-hover);
}

.stat-card.primary { border-left-color: var(--primary-color); }
.stat-card.success { border-left-color: var(--success-color); }
.stat-card.warning { border-left-color: var(--warning-color); }
.stat-card.danger { border-left-color: var(--danger-color); }

.stat-card-title {
  font-size: 14px;
  color: var(--text-secondary);
  margin-bottom: 8px;
}

.stat-card-value {
  font-size: 28px;
  font-weight: 600;
  color: var(--text-primary);
}

.stat-card-footer {
  font-size: 12px;
  color: var(--text-tertiary);
  margin-top: 8px;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
}

.category-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  border-radius: var(--border-radius);
  background: var(--bg-card);
  cursor: pointer;
  border: 1px solid var(--border-color);
  margin-bottom: 12px;
  transition: all var(--transition-time);
}

.category-card:hover {
  border-color: var(--primary-color);
  transform: translateY(-2px);
  box-shadow: var(--shadow-light);
}

.category-name {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
  margin-top: 12px;
}

.warning-list {
  max-height: 300px;
  overflow-y: auto;
}

.warning-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  border-radius: 4px;
  margin-bottom: 8px;
  background: var(--bg-page);
}

.warning-item.high { border-left: 3px solid var(--danger-color); }
.warning-item.medium { border-left: 3px solid var(--warning-color); }

.warning-text {
  font-size: 14px;
  color: var(--text-primary);
}

.empty-state {
  padding: 40px;
  text-align: center;
  color: var(--text-tertiary);
}

.mb-4 {
  margin-bottom: 16px;
}
</style>
