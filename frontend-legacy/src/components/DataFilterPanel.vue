<template>
  <div class="data-filter-panel">
    <el-collapse v-model="activeNames" @change="handleCollapseChange">
      <el-collapse-item title="数据筛选" name="filters">
        <el-form :model="filterForm" label-width="80px" size="small">
          <!-- 部门筛选 -->
          <el-form-item label="部门">
            <el-select 
              v-model="filterForm.deptId" 
              placeholder="全部部门" 
              clearable
              style="width: 100%"
              @change="handleFilterChange"
            >
              <el-option
                v-for="dept in departmentOptions"
                :key="dept.id"
                :label="dept.name"
                :value="dept.id"
              />
            </el-select>
          </el-form-item>

          <!-- 数据分类筛选 -->
          <el-form-item label="数据分类">
            <el-select 
              v-model="filterForm.categoryId" 
              placeholder="全部分类" 
              clearable
              style="width: 100%"
              @change="handleFilterChange"
            >
              <el-option
                v-for="category in categoryOptions"
                :key="category.id"
                :label="category.name"
                :value="category.id"
              />
            </el-select>
          </el-form-item>

          <!-- 时间周期筛选 -->
          <el-form-item label="时间周期">
            <el-select 
              v-model="filterForm.period" 
              placeholder="全部周期" 
              clearable
              style="width: 100%"
              @change="handleFilterChange"
            >
              <el-option
                v-for="period in periodOptions"
                :key="period.value"
                :label="period.label"
                :value="period.value"
              />
            </el-select>
          </el-form-item>

          <!-- 时间范围筛选 -->
          <el-form-item label="时间范围">
            <el-date-picker
              v-model="filterForm.periodRange"
              type="monthrange"
              range-separator="至"
              start-placeholder="开始月份"
              end-placeholder="结束月份"
              format="YYYYMM"
              value-format="YYYYMM"
              style="width: 100%"
              @change="handlePeriodRangeChange"
            />
          </el-form-item>

          <!-- 岗位筛选 -->
          <el-form-item label="岗位">
            <el-input 
              v-model="filterForm.job" 
              placeholder="输入岗位名称" 
              clearable
              @change="handleFilterChange"
            />
          </el-form-item>

          <!-- 员工编号筛选 -->
          <el-form-item label="员工编号">
            <el-input 
              v-model="filterForm.employeeNo" 
              placeholder="输入员工编号" 
              clearable
              @change="handleFilterChange"
            />
          </el-form-item>

          <!-- 姓名筛选 -->
          <el-form-item label="姓名">
            <el-input 
              v-model="filterForm.name" 
              placeholder="输入姓名" 
              clearable
              @change="handleFilterChange"
            />
          </el-form-item>

          <!-- 指标值范围筛选 -->
          <el-form-item label="指标值范围">
            <div class="value-range">
              <el-input-number
                v-model="filterForm.valueMin"
                placeholder="最小值"
                :controls="false"
                style="width: 45%"
                @change="handleFilterChange"
              />
              <span style="margin: 0 10px">-</span>
              <el-input-number
                v-model="filterForm.valueMax"
                placeholder="最大值"
                :controls="false"
                style="width: 45%"
                @change="handleFilterChange"
              />
            </div>
          </el-form-item>

          <!-- 排序设置 -->
          <el-form-item label="排序">
            <div class="sort-controls">
              <el-select 
                v-model="filterForm.sortBy" 
                placeholder="排序字段"
                style="width: 60%"
                @change="handleFilterChange"
              >
                <el-option label="创建时间" value="create_time" />
                <el-option label="指标值" value="value" />
                <el-option label="员工编号" value="employee_no" />
                <el-option label="姓名" value="name" />
              </el-select>
              <el-select 
                v-model="filterForm.sortOrder" 
                style="width: 35%; margin-left: 5%"
                @change="handleFilterChange"
              >
                <el-option label="降序" value="DESC" />
                <el-option label="升序" value="ASC" />
              </el-select>
            </div>
          </el-form-item>

          <!-- 操作按钮 -->
          <el-form-item>
            <el-button type="primary" @click="handleSearch" :icon="Search">
              查询
            </el-button>
            <el-button @click="handleReset" :icon="Refresh">
              重置
            </el-button>
            <el-button @click="handleSaveFilter" :icon="Star">
              保存筛选
            </el-button>
          </el-form-item>
        </el-form>
      </el-collapse-item>
    </el-collapse>

    <!-- 快速筛选标签 -->
    <div v-if="savedFilters.length > 0" class="saved-filters">
      <div class="filter-label">已保存的筛选：</div>
      <el-tag
        v-for="(filter, index) in savedFilters"
        :key="index"
        closable
        @close="handleRemoveSavedFilter(index)"
        @click="handleApplySavedFilter(filter)"
        style="margin-right: 8px; cursor: pointer"
      >
        {{ filter.name }}
      </el-tag>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh, Star } from '@element-plus/icons-vue'
import axios from 'axios'

const emit = defineEmits(['filter-change', 'search', 'reset'])

const activeNames = ref(['filters'])
const departmentOptions = ref([])
const categoryOptions = ref([])
const periodOptions = ref([])
const savedFilters = ref([])

const filterForm = reactive({
  deptId: null,
  categoryId: null,
  period: '',
  periodRange: null,
  job: '',
  employeeNo: '',
  name: '',
  valueMin: null,
  valueMax: null,
  sortBy: 'create_time',
  sortOrder: 'DESC'
})

// 初始化
onMounted(async () => {
  await loadFilterOptions()
  loadSavedFilters()
})

// 加载筛选选项
const loadFilterOptions = async () => {
  try {
    // 并行加载所有筛选选项
    const [deptRes, categoryRes, periodRes] = await Promise.all([
      axios.get('/api/query/filter-options/dept'),
      axios.get('/api/query/filter-options/category'),
      axios.get('/api/query/filter-options/period')
    ])

    if (deptRes.data.code === 200) {
      departmentOptions.value = deptRes.data.data.options
    }

    if (categoryRes.data.code === 200) {
      categoryOptions.value = categoryRes.data.data.options
    }

    if (periodRes.data.code === 200) {
      periodOptions.value = periodRes.data.data.options.map(p => ({
        value: p.value,
        label: p.value
      }))
    }
  } catch (error) {
    console.error('加载筛选选项失败:', error)
  }
}

// 加载已保存的筛选
const loadSavedFilters = () => {
  const saved = localStorage.getItem('savedFilters')
  if (saved) {
    savedFilters.value = JSON.parse(saved)
  }
}

// 折叠面板变化处理
const handleCollapseChange = (activeNames) => {
  // 可以在这里处理折叠状态变化
}

// 筛选条件变化处理
const handleFilterChange = () => {
  emit('filter-change', { ...filterForm })
}

// 时间范围变化处理
const handlePeriodRangeChange = (value) => {
  if (value && value.length === 2) {
    filterForm.periodStart = value[0]
    filterForm.periodEnd = value[1]
  } else {
    filterForm.periodStart = null
    filterForm.periodEnd = null
  }
  emit('filter-change', { ...filterForm })
}

// 执行查询
const handleSearch = () => {
  emit('search', { ...filterForm })
}

// 重置筛选条件
const handleReset = () => {
  Object.assign(filterForm, {
    deptId: null,
    categoryId: null,
    period: '',
    periodRange: null,
    job: '',
    employeeNo: '',
    name: '',
    valueMin: null,
    valueMax: null,
    sortBy: 'create_time',
    sortOrder: 'DESC'
  })
  emit('reset')
}

// 保存筛选条件
const handleSaveFilter = () => {
  const filterName = prompt('请输入筛选条件名称：')
  if (filterName) {
    const filterConfig = {
      name: filterName,
      config: JSON.parse(JSON.stringify(filterForm))
    }
    savedFilters.value.push(filterConfig)
    localStorage.setItem('savedFilters', JSON.stringify(savedFilters.value))
    ElMessage.success('筛选条件已保存')
  }
}

// 删除已保存的筛选
const handleRemoveSavedFilter = (index) => {
  savedFilters.value.splice(index, 1)
  localStorage.setItem('savedFilters', JSON.stringify(savedFilters.value))
  ElMessage.success('已删除筛选条件')
}

// 应用已保存的筛选
const handleApplySavedFilter = (filter) => {
  Object.assign(filterForm, filter.config)
  emit('filter-change', { ...filterForm })
  ElMessage.success('已应用筛选条件：' + filter.name)
}

// 暴露方法供父组件调用
defineExpose({
  getFilters: () => ({ ...filterForm }),
  setFilters: (filters) => {
    Object.assign(filterForm, filters)
  },
  resetFilters: handleReset
})
</script>

<style scoped>
.data-filter-panel {
  margin-bottom: 20px;
}

.data-filter-panel :deep(.el-collapse-item__header) {
  font-weight: bold;
  font-size: 14px;
}

.value-range {
  display: flex;
  align-items: center;
}

.sort-controls {
  display: flex;
  align-items: center;
}

.saved-filters {
  margin-top: 15px;
  padding: 10px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.filter-label {
  font-size: 12px;
  color: #606266;
  margin-bottom: 8px;
}
</style>
