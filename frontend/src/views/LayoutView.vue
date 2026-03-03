<template>
  <el-container class="layout">
    <el-aside width="220px" class="aside">
      <div class="logo">HR 数据中心</div>
      <el-menu
        :default-active="activeMenu"
        router
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
      >
        <el-menu-item index="/dashboard">
          <el-icon><Odometer /></el-icon>
          <span>仪表盘</span>
        </el-menu-item>
        <el-menu-item index="/data-analysis">
          <el-icon><DataAnalysis /></el-icon>
          <span>数据分析</span>
        </el-menu-item>
        <el-sub-menu index="analysis">
          <template #title>
            <el-icon><TrendCharts /></el-icon>
            <span>八大分析</span>
          </template>
          <el-menu-item index="/analysis/organization-efficiency">组织效能</el-menu-item>
          <el-menu-item index="/analysis/talent-pipeline">人才梯队</el-menu-item>
          <el-menu-item index="/analysis/compensation-benefit">薪酬福利</el-menu-item>
          <el-menu-item index="/analysis/performance-management">绩效管理</el-menu-item>
          <el-menu-item index="/analysis/employee-turnover">员工流失预警</el-menu-item>
          <el-menu-item index="/analysis/training-effect">培训效果</el-menu-item>
          <el-menu-item index="/analysis/human-cost-optimization">人力成本</el-menu-item>
          <el-menu-item index="/analysis/talent-development">人才发展</el-menu-item>
        </el-sub-menu>
        <el-menu-item index="/my-favorites">
          <el-icon><Star /></el-icon>
          <span>我的收藏</span>
        </el-menu-item>
        <el-menu-item index="/profile">
          <el-icon><User /></el-icon>
          <span>个人中心</span>
        </el-menu-item>
        <el-sub-menu v-if="userStore.isAdmin" index="admin">
          <template #title>
            <el-icon><Setting /></el-icon>
            <span>管理后台</span>
          </template>
          <el-menu-item index="/admin/users">用户管理</el-menu-item>
          <el-menu-item index="/admin/categories">数据分类</el-menu-item>
          <el-menu-item index="/admin/data">数据管理</el-menu-item>
          <el-menu-item index="/admin/rules">预警规则</el-menu-item>
          <el-menu-item index="/admin/reports">报表管理</el-menu-item>
          <el-menu-item index="/admin/sync">数据同步</el-menu-item>
        </el-sub-menu>
      </el-menu>
    </el-aside>
    <el-container>
      <el-header class="header">
        <span class="title">{{ currentTitle }}</span>
        <div class="right">
          <span class="user-name">{{ userStore.userName }} ({{ userStore.userRole }})</span>
          <el-button type="danger" link @click="handleLogout">退出</el-button>
        </div>
      </el-header>
      <el-main class="main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const activeMenu = computed(() => route.path)
const currentTitle = computed(() => route.meta.title || '人力资源数据中心')

const handleLogout = () => {
  userStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.layout { height: 100vh; }
.aside {
  background: #304156;
  overflow-x: hidden;
}
.logo {
  height: 50px;
  line-height: 50px;
  text-align: center;
  color: #fff;
  font-weight: bold;
  font-size: 16px;
}
.header {
  background: #fff;
  border-bottom: 1px solid #e6e6e6;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
}
.title { font-size: 18px; font-weight: bold; }
.right { display: flex; align-items: center; gap: 16px; }
.user-name { color: #606266; font-size: 14px; }
.main {
  background: var(--bg-page);
  padding: 20px;
  overflow-y: auto;
}
</style>
