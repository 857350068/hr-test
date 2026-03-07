import { createRouter, createWebHashHistory } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/LoginView.vue'),
    meta: { requiresAuth: false, title: '登录' }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/RegisterView.vue'),
    meta: { requiresAuth: false, title: '注册' }
  },
  {
    path: '/',
    name: 'Layout',
    component: () => import('@/views/LayoutView.vue'),
    meta: { requiresAuth: true, title: '首页' },
    redirect: '/dashboard',
    children: [
      { path: 'dashboard', name: 'Dashboard', component: () => import('@/views/DashboardView.vue'), meta: { title: '仪表盘' } },
      { path: 'data-analysis', name: 'DataAnalysis', component: () => import('@/views/DataAnalysisView.vue'), meta: { title: '数据分析' } },
      { path: 'analysis/organization-efficiency', name: 'OrganizationEfficiency', component: () => import('@/views/analysis/OrganizationEfficiencyView.vue'), meta: { title: '组织效能分析' } },
      { path: 'analysis/talent-pipeline', name: 'TalentPipeline', component: () => import('@/views/analysis/TalentPipelineView.vue'), meta: { title: '人才梯队建设' } },
      { path: 'analysis/compensation-benefit', name: 'CompensationBenefit', component: () => import('@/views/analysis/CompensationBenefitView.vue'), meta: { title: '薪酬福利分析' } },
      { path: 'analysis/performance-management', name: 'PerformanceManagement', component: () => import('@/views/analysis/PerformanceManagementView.vue'), meta: { title: '绩效管理体系' } },
      { path: 'analysis/employee-turnover', name: 'EmployeeTurnover', component: () => import('@/views/analysis/EmployeeTurnoverView.vue'), meta: { title: '员工流失预警' } },
      { path: 'analysis/training-effect', name: 'TrainingEffect', component: () => import('@/views/analysis/TrainingEffectView.vue'), meta: { title: '培训效果评估' } },
      { path: 'analysis/human-cost-optimization', name: 'HumanCostOptimization', component: () => import('@/views/analysis/HumanCostOptimizationView.vue'), meta: { title: '人力成本优化' } },
      { path: 'analysis/talent-development', name: 'TalentDevelopment', component: () => import('@/views/analysis/TalentDevelopmentView.vue'), meta: { title: '人才发展预测' } },
      { path: 'profile', name: 'Profile', component: () => import('@/views/ProfileView.vue'), meta: { title: '个人中心' } },
      { path: 'my-favorites', name: 'MyFavorites', component: () => import('@/views/MyFavoritesView.vue'), meta: { title: '我的收藏' } },
      { path: 'admin/users', name: 'UserManagement', component: () => import('@/views/admin/UserManagementView.vue'), meta: { requiresAdmin: true, title: '用户管理' } },
      { path: 'admin/departments', name: 'DepartmentManagement', component: () => import('@/views/admin/DepartmentManagementView.vue'), meta: { requiresAdmin: true, title: '部门管理' } },
      { path: 'admin/categories', name: 'CategoryManagement', component: () => import('@/views/admin/CategoryManagementView.vue'), meta: { requiresAdmin: true, title: '数据分类管理' } },
      { path: 'admin/data', name: 'DataManagement', component: () => import('@/views/admin/DataManagementView.vue'), meta: { requiresAdmin: true, title: '数据管理' } },
      { path: 'admin/rules', name: 'RuleManagement', component: () => import('@/views/admin/RuleManagementView.vue'), meta: { requiresAdmin: true, title: '预警规则管理' } },
      { path: 'admin/reports', name: 'ReportManagement', component: () => import('@/views/admin/ReportManagementView.vue'), meta: { requiresAdmin: true, title: '报表管理' } },
      { path: 'admin/sync', name: 'DataSync', component: () => import('@/views/admin/DataSyncView.vue'), meta: { requiresAdmin: true, title: '数据同步' } },
      { path: 'admin/logs', name: 'LogManagement', component: () => import('@/views/admin/LogManagementView.vue'), meta: { requiresAdmin: true, title: '操作日志' } }
    ]
  },
  { path: '/403', name: 'Forbidden', component: () => import('@/views/ForbiddenView.vue'), meta: { requiresAuth: false, title: '禁止访问' } },
  { path: '/404', name: 'NotFound', component: () => import('@/views/NotFoundView.vue'), meta: { requiresAuth: false, title: '页面不存在' } },
  { path: '/:pathMatch(.*)*', redirect: '/404' }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  document.title = to.meta.title ? `${to.meta.title} - 人力资源数据中心` : '人力资源数据中心'
  const userStore = useUserStore()

  if (to.meta.requiresAuth) {
    if (!userStore.isLoggedIn) {
      ElMessage.warning('请先登录')
      next('/login')
      return
    }
    if (to.meta.requiresAdmin && !userStore.isAdmin) {
      ElMessage.error('权限不足')
      next('/403')
      return
    }
  }

  if ((to.path === '/login' || to.path === '/register') && userStore.isLoggedIn) {
    next('/dashboard')
    return
  }

  next()
})

export default router
