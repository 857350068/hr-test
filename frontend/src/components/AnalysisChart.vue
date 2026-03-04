<template>
  <div class="analysis-chart">
    <div class="chart-header">
      <h3>{{ title }}</h3>
      <div class="chart-controls">
        <el-select v-model="currentChartType" placeholder="选择图表类型" size="small" @change="updateChartType">
          <el-option label="柱状图" value="bar"></el-option>
          <el-option label="折线图" value="line"></el-option>
          <el-option label="饼图" value="pie"></el-option>
          <el-option label="环形图" value="ring"></el-option>
        </el-select>
      </div>
    </div>

    <div ref="chartRef" class="chart-container" :style="{ height: height }"></div>

    <div class="chart-footer">
      <el-tag type="info" size="small">数据维度: {{ dimension }}</el-tag>
      <el-tag type="success" size="small">统计周期: {{ period }}</el-tag>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, onBeforeUnmount } from 'vue'
import * as echarts from 'echarts'

const props = defineProps({
  title: {
    type: String,
    default: '数据分析图表'
  },
  data: {
    type: Array,
    default: () => []
  },
  chartType: {
    type: String,
    default: 'bar'
  },
  dimension: {
    type: String,
    default: ''
  },
  period: {
    type: String,
    default: ''
  },
  height: {
    type: String,
    default: '400px'
  }
})

const chartRef = ref(null)
const currentChartType = ref(props.chartType)
let chartInstance = null

const initChart = () => {
  if (!chartRef.value) return

  chartInstance = echarts.init(chartRef.value)
  updateChart()
}

const updateChart = () => {
  if (!chartInstance || !props.data.length) return

  const categories = props.data.map(item => item.name || item.category || item.label)
  const values = props.data.map(item => item.value || item.count || item.score)

  let option = {
    tooltip: {
      trigger: currentChartType.value === 'pie' || currentChartType.value === 'ring' ? 'item' : 'axis',
      formatter: currentChartType.value === 'pie' || currentChartType.value === 'ring'
        ? '{b}: {c} ({d}%)'
        : '{b}: {c}'
    },
    legend: {
      data: categories,
      orient: currentChartType.value === 'pie' || currentChartType.value === 'ring' ? 'vertical' : 'horizontal',
      right: 10,
      top: 20
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    }
  }

  if (currentChartType.value === 'pie' || currentChartType.value === 'ring') {
    option.series = [{
      type: 'pie',
      radius: currentChartType.value === 'ring' ? ['40%', '70%'] : '70%',
      data: props.data.map(item => ({
        name: item.name || item.category || item.label,
        value: item.value || item.count || item.score
      })),
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetX: 0,
          shadowColor: 'rgba(0, 0, 0, 0.5)'
        }
      }
    }]
  } else {
    option.xAxis = {
      type: 'category',
      data: categories,
      axisLabel: {
        interval: 0,
        rotate: categories.length > 6 ? 30 : 0
      }
    }
    option.yAxis = {
      type: 'value'
    }
    option.series = [{
      name: props.title,
      type: currentChartType.value,
      data: values,
      itemStyle: {
        color: '#409EFF'
      },
      areaStyle: currentChartType.value === 'line' ? {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(64, 158, 255, 0.3)' },
          { offset: 1, color: 'rgba(64, 158, 255, 0.1)' }
        ])
      } : undefined
    }]
  }

  chartInstance.setOption(option, true)
}

const updateChartType = () => {
  updateChart()
}

const handleResize = () => {
  if (chartInstance) {
    chartInstance.resize()
  }
}

watch(() => props.data, () => {
  updateChart()
}, { deep: true })

watch(() => props.chartType, (newType) => {
  currentChartType.value = newType
  updateChart()
})

onMounted(() => {
  initChart()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  if (chartInstance) {
    chartInstance.dispose()
    chartInstance = null
  }
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.analysis-chart {
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 15px;
  margin-bottom: 20px;
  background: #fff;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.chart-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.chart-controls {
  display: flex;
  gap: 10px;
  align-items: center;
}

.chart-container {
  width: 100%;
}

.chart-footer {
  margin-top: 10px;
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}
</style>
