<template>
  <div class="data-comparison-view">
    <el-card>
      <template #header>
        <div class="card-header">
          <span class="title">数据对比分析</span>
          <div class="header-actions">
            <el-button :icon="Refresh" @click="refreshData">刷新</el-button>
            <data-export-button export-type="analysis-data" :category-id="comparisonForm.categoryId" />
          </div>
        </div>
      </template>

      <!-- 对比配置 -->
      <el-form :model="comparisonForm" label-width="100px" inline>
        <el-form-item label="数据分类">
          <el-select 
            v-model="comparisonForm.categoryId" 
            placeholder="选择数据分类"
            @change="handleCategoryChange"
            style="width: 200px"
          >
            <el-option
              v-for="item in categoryOptions"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="对比周期1">
          <el-select 
            v-model="comparisonForm.period1" 
            placeholder="选择时间周期"
            @change="handleComparison"
            style="width: 150px"
          >
            <el-option
              v-for="item in periodOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="对比周期2">
          <el-select 
            v-model="comparisonForm.period2" 
            placeholder="选择时间周期"
            @change="handleComparison"
            style="width: 150px"
          >
            <el-option
              v-for="item in periodOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleComparison" :loading="loading">
            开始对比
          </el-button>
        </el-form-item>
      </el-form>

      <!-- 对比结果展示 -->
      <div v-if="comparisonData.length > 0" class="comparison-results">
        <!-- 统计摘要 -->
        <el-row :gutter="20" class="summary-row">
          <el-col :span="6">
            <el-card shadow="hover">
              <div class="summary-item">
                <div class="summary-label">对比部门数</div>
                <div class="summary-value">{{ comparisonData.length }}</div>
              </div>
            </el-card>
          </el-col>
          <el-col :span="6">
            <el-card shadow="hover">
              <div class="summary-item">
                <div class="summary-label">平均变化率</div>
                <div class="summary-value" :class="getChangeRateClass(averageChangeRate)">
                  {{ formatPercent(averageChangeRate) }}
                </div>
              </div>
            </el-card>
          </el-col>
          <el-col :span="6">
            <el-card shadow="hover">
              <div class="summary-item">
                <div class="summary-label">提升部门</div>
                <div class="summary-value success">{{ improvedCount }} 个</div>
              </div>
            </el-card>
          </el-col>
          <el-col :span="6">
            <el-card shadow="hover">
              <div class="summary-item">
                <div class="summary-label">下降部门</div>
                <div class="summary-value danger">{{ declinedCount }} 个</div>
              </div>
            </el-card>
          </el-col>
        </el-row>

        <!-- 对比表格 -->
        <el-table 
          :data="comparisonData" 
          border 
          stripe
          style="width: 100%; margin-top: 20px"
          :default-sort="{ prop: 'changeRate', order: 'descending' }"
        >
          <el-table-column type="index" label="排名" width="60" align="center" />
          <el-table-column prop="deptName" label="部门" width="120" />
          <el-table-column label="周期1数据" width="120" align="right">
            <template #default="{ row }">
              <span>{{ formatNumber(row.period1Value) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="周期2数据" width="120" align="right">
            <template #default="{ row }">
              <span>{{ formatNumber(row.period2Value) }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="changeRate" label="变化率" width="100" align="right" sortable>
            <template #default="{ row }">
              <el-tag 
                :type="row.changeRate > 0 ? 'success' : (row.changeRate < 0 ? 'danger' : 'info')"
                size="small"
              >
                {{ row.changeRate !== null ? formatPercent(row.changeRate) : '-' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="changeDirection" label="变化趋势" width="100" align="center">
            <template #default="{ row }">
              <el-icon v-if="row.changeDirection === '上升'" color="#67C23A" :size="20">
                <arrow-up />
              </el-icon>
              <el-icon v-else-if="row.changeDirection === '下降'" color="#F56C6C" :size="20">
                <arrow-down />
              </el-icon>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="变化幅度" width="150">
            <template #default="{ row }">
              <div v-if="row.changeRate !== null" class="change-bar">
                <div 
                  class="bar-fill"
                  :style="{ 
                    width: Math.abs(row.changeRate) + '%',
                    backgroundColor: row.changeRate > 0 ? '#67C23A' : '#F56C6C'
                  }"
                />
              </div>
              <span v-else>-</span>
            </template>
          </el-table-column>
        </el-table>

        <!-- 对比图表 -->
        <div class="comparison-chart" style="margin-top: 20px">
          <analysis-chart 
            :chart-data="chartData" 
            :chart-type="'bar'"
            :chart-title="`${categoryName}数据对比分析`"
            height="400px"
          />
        </div>
      </div>

      <!-- 空状态 -->
      <el-empty 
        v-else 
        description="请选择数据分类和时间周期后点击开始对比"
        :image-size="200"
      />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Refresh, ArrowUp, ArrowDown } from '@element-plus/icons-vue'
import axios from 'axios'
import DataExportButton from './DataExportButton.vue'
import AnalysisChart from './AnalysisChart.vue'

const emit = defineEmits(['comparison-complete'])

const loading = ref(false)
const categoryOptions = ref([])
const periodOptions = ref([])
const comparisonData = ref([])
const categoryName = ref('')

const comparisonForm = reactive({
  categoryId: null,
  period1: '',
  period2: ''
})

// 计算统计数据
const averageChangeRate = computed(() => {
  if (comparisonData.value.length === 0) return 0
  const validRates = comparisonData.value
    .map(item => item.changeRate)
    .filter(rate => rate !== null)
  if (validRates.length === 0) return 0
  return validRates.reduce((sum, rate) => sum + rate, 0) / validRates.length
})

const improvedCount = computed(() => {
  return comparisonData.value.filter(item => item.changeRate > 0).length
})

const declinedCount = computed(() => {
  return comparisonData.value.filter(item => item.changeRate < 0).length
})

// 图表数据
const chartData = computed(() => {
  if (comparisonData.value.length === 0) return null

  return {
    xAxis: {
      type: 'category',
      data: comparisonData.value.map(item => item.deptName)
    },
    series: [
      {
        name: comparisonForm.period1,
        type: 'bar',
        data: comparisonData.value.map(item => item.period1Value),
        itemStyle: { color: '#409EFF' }
      },
      {
        name: comparisonForm.period2,
        type: 'bar',
        data: comparisonData.value.map(item => item.period2Value),
        itemStyle: { color: '#67C23A' }
      }
    ]
  }
})

// 初始化
onMounted(async () => {
  await loadCategoryOptions()
  await loadPeriodOptions()
})

// 加载分类选项
const loadCategoryOptions = async () => {
  try {
    const res = await axios.get('/api/query/filter-options/category')
    if (res.data.code === 200) {
      categoryOptions.value = res.data.data.options
    }
  } catch (error) {
    console.error('加载分类选项失败:', error)
  }
}

// 加载周期选项
const loadPeriodOptions = async () => {
  try {
    const res = await axios.get('/api/query/filter-options/period')
    if (res.data.code === 200) {
      periodOptions.value = res.data.data.options.map(p => ({
        value: p.value,
        label: p.value
      }))
    }
  } catch (error) {
    console.error('加载周期选项失败:', error)
  }
}

// 分类变化处理
const handleCategoryChange = () => {
  const category = categoryOptions.value.find(c => c.id === comparisonForm.categoryId)
  if (category) {
    categoryName.value = category.name
  }
}

// 执行对比
const handleComparison = async () => {
  if (!comparisonForm.categoryId || !comparisonForm.period1 || !comparisonForm.period2) {
    ElMessage.warning('请选择数据分类和两个对比周期')
    return
  }

  if (comparisonForm.period1 === comparisonForm.period2) {
    ElMessage.warning('两个对比周期不能相同')
    return
  }

  try {
    loading.value = true
    const res = await axios.get('/api/query/analysis-data/compare', {
      params: {
        categoryId: comparisonForm.categoryId,
        period1: comparisonForm.period1,
        period2: comparisonForm.period2
      }
    })

    if (res.data.code === 200 && res.data.data.success) {
      comparisonData.value = res.data.data.data
      emit('comparison-complete', comparisonData.value)
      ElMessage.success('对比分析完成')
    } else {
      ElMessage.error(res.data.data.message || '对比分析失败')
    }
  } catch (error) {
    console.error('对比分析失败:', error)
    ElMessage.error('对比分析失败：' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

// 刷新数据
const refreshData = () => {
  handleComparison()
}

// 格式化数字
const formatNumber = (value) => {
  if (value === null || value === undefined) return '-'
  return Number(value).toFixed(2)
}

// 格式化百分比
const formatPercent = (value) => {
  if (value === null || value === undefined) return '-'
  return (value > 0 ? '+' : '') + value.toFixed(2) + '%'
}

// 获取变化率样式类
const getChangeRateClass = (rate) => {
  if (rate > 0) return 'success'
  if (rate < 0) return 'danger'
  return ''
}
</script>

<style scoped>
.data-comparison-view {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header .title {
  font-size: 16px;
  font-weight: bold;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.summary-row {
  margin-bottom: 20px;
}

.summary-item {
  text-align: center;
}

.summary-label {
  font-size: 12px;
  color: #909399;
  margin-bottom: 8px;
}

.summary-value {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
}

.summary-value.success {
  color: #67C23A;
}

.summary-value.danger {
  color: #F56C6C;
}

.change-bar {
  width: 100%;
  height: 8px;
  background-color: #f0f0f0;
  border-radius: 4px;
  overflow: hidden;
}

.bar-fill {
  height: 100%;
  transition: width 0.3s ease;
}

.comparison-chart {
  background-color: #f5f7fa;
  border-radius: 4px;
  padding: 20px;
}
</style>
