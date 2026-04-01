<template>
    <el-container class="layout-container">
        <!-- 侧边栏 -->
        <el-aside width="200px" class="aside">
            <div class="logo">
                <h3>人力资源数据中心</h3>
            </div>
            <el-menu
                :default-active="activeMenu"
                router
                background-color="#304156"
                text-color="#bfcbd9"
                active-text-color="#409EFF"
            >
                <el-menu-item index="/dashboard">
                    <el-icon><DataLine /></el-icon>
                    <span>首页看板</span>
                </el-menu-item>
                <el-menu-item index="/employee">
                    <el-icon><User /></el-icon>
                    <span>员工管理</span>
                </el-menu-item>
                <el-menu-item index="/attendance">
                    <el-icon><Clock /></el-icon>
                    <span>考勤打卡</span>
                </el-menu-item>
                <el-menu-item index="/leave">
                    <el-icon><Document /></el-icon>
                    <span>请假管理</span>
                </el-menu-item>
                <el-menu-item index="/performance">
                    <el-icon><Trophy /></el-icon>
                    <span>绩效管理</span>
                </el-menu-item>
                <el-menu-item index="/salary">
                    <el-icon><Wallet /></el-icon>
                    <span>薪酬管理</span>
                </el-menu-item>
                <el-menu-item index="/training">
                    <el-icon><Reading /></el-icon>
                    <span>培训管理</span>
                </el-menu-item>
            </el-menu>
        </el-aside>

        <!-- 主体内容 -->
        <el-container>
            <!-- 顶部导航 -->
            <el-header class="header">
                <div class="header-left">
                    <span>欢迎, {{ userInfo.realName || '用户' }}</span>
                </div>
                <div class="header-right">
                    <el-dropdown @command="handleCommand">
                        <span class="el-dropdown-link">
                            <el-icon><User /></el-icon>
                            个人中心
                            <el-icon class="el-icon--right"><ArrowDown /></el-icon>
                        </span>
                        <template #dropdown>
                            <el-dropdown-menu>
                                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
                            </el-dropdown-menu>
                        </template>
                    </el-dropdown>
                </div>
            </el-header>

            <!-- 内容区域 -->
            <el-main class="main">
                <router-view />
            </el-main>
        </el-container>
    </el-container>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'

const router = useRouter()
const route = useRoute()

const userInfo = ref({})
const activeMenu = computed(() => route.path)

onMounted(() => {
    const userStr = localStorage.getItem('userInfo')
    if (userStr) {
        userInfo.value = JSON.parse(userStr)
    }
})

const handleCommand = (command) => {
    if (command === 'logout') {
        handleLogout()
    }
}

const handleLogout = () => {
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
    ElMessage.success('退出成功')
    router.push('/login')
}
</script>

<style scoped>
.layout-container {
    width: 100%;
    height: 100vh;
}

.aside {
    background-color: #304156;
    overflow: hidden;
}

.logo {
    height: 60px;
    line-height: 60px;
    text-align: center;
    color: white;
    font-size: 18px;
    font-weight: bold;
}

.header {
    background-color: #fff;
    box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 20px;
}

.header-left {
    font-size: 16px;
    color: #333;
}

.header-right {
    cursor: pointer;
}

.el-dropdown-link {
    display: flex;
    align-items: center;
    color: #333;
}

.main {
    background-color: #f0f2f5;
    padding: 20px;
}
</style>
