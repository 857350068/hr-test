<template>
    <el-container class="layout-container">
        <el-aside width="220px" class="aside">
            <div class="logo">
                <h3>人力资源数据中心</h3>
            </div>
            <el-menu
                :default-active="activeMenu"
                :default-openeds="['analysis-group', 'system-group']"
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
                <el-menu-item index="/recruitment" v-if="showRecruitmentMenu">
                    <el-icon><User /></el-icon>
                    <span>招聘管理</span>
                </el-menu-item>

                <el-sub-menu index="analysis-group">
                    <template #title>
                        <el-icon><Histogram /></el-icon>
                        <span>数据分析</span>
                    </template>
                    <el-menu-item index="/analysis/dashboard">分析看板</el-menu-item>
                    <el-menu-item index="/analysis/org-efficiency">组织效能</el-menu-item>
                    <el-menu-item index="/analysis/talent-pipeline">人才梯队</el-menu-item>
                    <el-menu-item index="/analysis/salary">薪酬分析</el-menu-item>
                    <el-menu-item index="/analysis/warning">预警分析</el-menu-item>
                </el-sub-menu>

                <el-sub-menu index="system-group" v-if="showSystemGroup">
                    <template #title>
                        <el-icon><Setting /></el-icon>
                        <span>系统管理</span>
                    </template>
                    <el-menu-item index="/system/operation-log">操作日志</el-menu-item>
                    <el-menu-item index="/system/user" v-if="roleCode === 'ROLE_ADMIN'">用户管理</el-menu-item>
                    <el-menu-item index="/system/data-category">数据分类</el-menu-item>
                    <el-menu-item index="/system/message">消息通知</el-menu-item>
                    <el-menu-item index="/system/favorite">我的收藏</el-menu-item>
                    <el-menu-item index="/system/rule" v-if="showSystemGroup">规则管理</el-menu-item>
                    <el-menu-item index="/system/model" v-if="showSystemGroup">模型管理</el-menu-item>
                    <el-menu-item index="/system/report" v-if="showSystemGroup">报表中心</el-menu-item>
                </el-sub-menu>
            </el-menu>
        </el-aside>

        <el-container>
            <el-header class="header">
                <div class="header-left">
                    <span>欢迎, {{ userInfo.realName || '用户' }}</span>
                </div>
                <div class="header-right">
                    <el-badge :value="unreadCount" :hidden="unreadCount === 0" class="msg-badge">
                        <el-button circle @click="goMessage" title="消息通知">
                            <el-icon><Bell /></el-icon>
                        </el-button>
                    </el-badge>
                    <el-dropdown @command="handleCommand" style="margin-left: 12px">
                        <span class="el-dropdown-link">
                            <el-icon><User /></el-icon>
                            个人中心
                            <el-icon class="el-icon--right"><ArrowDown /></el-icon>
                        </span>
                        <template #dropdown>
                            <el-dropdown-menu>
                                <el-dropdown-item command="profile">个人资料</el-dropdown-item>
                                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
                            </el-dropdown-menu>
                        </template>
                    </el-dropdown>
                </div>
            </el-header>

            <el-main class="main">
                <router-view />
            </el-main>
        </el-container>
    </el-container>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
    DataLine,
    User,
    Clock,
    Document,
    Trophy,
    Wallet,
    Reading,
    Histogram,
    Setting,
    ArrowDown,
    Bell
} from '@element-plus/icons-vue'
import { getUnreadCount } from '@/api/message'

const router = useRouter()
const route = useRoute()

const userInfo = ref({})
const unreadCount = ref(0)

const activeMenu = computed(() => route.path)
const roleCode = computed(() => userInfo.value.roleCode || 'ROLE_EMPLOYEE')
const showSystemGroup = computed(() => ['ROLE_ADMIN', 'ROLE_HR_ADMIN'].includes(roleCode.value))
const showRecruitmentMenu = computed(() => ['ROLE_ADMIN', 'ROLE_HR_ADMIN', 'ROLE_MANAGER'].includes(roleCode.value))

function parseUser() {
    const userStr = localStorage.getItem('userInfo')
    if (userStr) {
        try {
            userInfo.value = JSON.parse(userStr)
        } catch {
            userInfo.value = {}
        }
    }
}

async function refreshUnread() {
    const uid = userInfo.value.userId
    if (!uid) {
        unreadCount.value = 0
        return
    }
    try {
        const res = await getUnreadCount(uid)
        unreadCount.value = res.data ?? 0
    } catch {
        unreadCount.value = 0
    }
}

function goMessage() {
    router.push('/system/message')
}

function onMessageRead() {
    refreshUnread()
}

onMounted(() => {
    parseUser()
    refreshUnread()
    window.addEventListener('message-read', onMessageRead)
})

onUnmounted(() => {
    window.removeEventListener('message-read', onMessageRead)
})

const handleCommand = (command) => {
    if (command === 'profile') {
        router.push('/profile')
        return
    }
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
    overflow-x: hidden;
    overflow-y: auto;
}

.logo {
    height: 60px;
    line-height: 60px;
    text-align: center;
    color: white;
    font-size: 16px;
    font-weight: bold;
    padding: 0 8px;
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
    display: flex;
    align-items: center;
    cursor: pointer;
}

.msg-badge {
    margin-right: 4px;
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

@media (max-width: 1024px) {
    .layout-container {
        flex-direction: column;
    }
    .aside {
        width: 100% !important;
        height: auto;
    }
    .main {
        padding: 12px;
    }
}
</style>
