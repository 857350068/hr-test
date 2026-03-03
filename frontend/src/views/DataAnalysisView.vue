<template>
  <div class="page-header">
    <h2 class="page-title">数据分析</h2>
    <p class="page-description">选择下方分类查看对应分析数据</p>
    <el-row :gutter="16" style="margin-top: 20px">
      <el-col v-for="cat in categories" :key="cat.path" :xs="24" :sm="12" :md="8" :lg="6">
        <el-card shadow="hover" class="analysis-card" @click="$router.push(cat.path)">
          <div class="analysis-name">{{ cat.name }}</div>
          <div class="analysis-desc">{{ cat.desc }}</div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
const categories = [
  { name: '组织效能分析', path: '/analysis/organization-efficiency', desc: '人均产出、协作效率、流程效率' },
  { name: '人才梯队建设', path: '/analysis/talent-pipeline', desc: '人才储备、核心人才占比、晋升率' },
  { name: '薪酬福利分析', path: '/analysis/compensation-benefit', desc: '平均薪酬、福利覆盖率、公平性' },
  { name: '绩效管理体系', path: '/analysis/performance-management', desc: '绩效得分、完成率、改进计划' },
  { name: '员工流失预警', path: '/analysis/employee-turnover', desc: '流失率、高风险员工、司龄' },
  { name: '培训效果评估', path: '/analysis/training-effect', desc: '培训覆盖率、得分、满意度' },
  { name: '人力成本优化', path: '/analysis/human-cost-optimization', desc: '总成本、人均成本、效益指数' },
  { name: '人才发展预测', path: '/analysis/talent-development', desc: '需求增长、人才缺口、高潜人才' }
]
</script>

<style scoped>
.analysis-card { cursor: pointer; margin-bottom: 16px; }
.analysis-card:hover { border-color: var(--primary-color); }
.analysis-name { font-size: 16px; font-weight: bold; margin-bottom: 8px; }
.analysis-desc { font-size: 12px; color: var(--text-secondary); }
</style>
