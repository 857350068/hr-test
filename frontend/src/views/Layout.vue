<template>
    <el-container class="layout-container">
        <el-aside width="220px" class="aside">
            <div class="logo">
                <h3>人力资源数据中心</h3>
            </div>
            <el-menu
                :default-active="activeMenu"
                :default-openeds="defaultOpeneds"
                router
                background-color="#304156"
                text-color="#bfcbd9"
                active-text-color="#409EFF"
            >
                <el-sub-menu index="overview-group">
                    <template #title>
                        <el-icon><DataLine /></el-icon>
                        <span>数据中心总览</span>
                    </template>
                    <el-menu-item index="/dashboard">首页看板</el-menu-item>
                    <el-menu-item index="/analysis/dashboard">分析看板</el-menu-item>
                    <el-menu-item index="/analysis/warning">预警分析</el-menu-item>
                </el-sub-menu>

                <el-sub-menu index="analysis-group">
                    <template #title>
                        <el-icon><Histogram /></el-icon>
                        <span>专题分析</span>
                    </template>
                    <el-sub-menu index="analysis-org-group">
                        <template #title>组织与人才</template>
                        <el-menu-item index="/analysis/org-efficiency">组织效能</el-menu-item>
                        <el-menu-item index="/analysis/talent-pipeline">人才梯队</el-menu-item>
                    </el-sub-menu>
                    <el-sub-menu index="analysis-salary-group">
                        <template #title>薪酬与风险</template>
                        <el-menu-item index="/analysis/salary">薪酬分析</el-menu-item>
                        <el-menu-item index="/analysis/warning">预警分析</el-menu-item>
                    </el-sub-menu>
                </el-sub-menu>

                <el-sub-menu index="governance-group" v-if="showSystemGroup">
                    <template #title>
                        <el-icon><Setting /></el-icon>
                        <span>数据治理</span>
                    </template>
                    <el-menu-item index="/system/data-category">数据分类</el-menu-item>
                    <el-menu-item index="/system/rule">规则管理</el-menu-item>
                    <el-menu-item index="/system/model">模型管理</el-menu-item>
                    <el-menu-item index="/system/report">报表中心</el-menu-item>
                    <el-menu-item index="/system/operation-log" v-if="roleCode === 'ROLE_ADMIN'">操作日志</el-menu-item>
                    <el-menu-item index="/system/user" v-if="roleCode === 'ROLE_ADMIN'">用户管理</el-menu-item>
                </el-sub-menu>

                <el-sub-menu index="business-group">
                    <template #title>
                        <el-icon><Reading /></el-icon>
                        <span>业务数据源</span>
                    </template>
                    <el-sub-menu index="business-employee-group">
                        <template #title>员工与组织</template>
                        <el-menu-item index="/employee" v-if="canManageEmployee">
                            <el-icon><User /></el-icon>
                            <span>员工管理</span>
                        </el-menu-item>
                        <el-menu-item index="/recruitment" v-if="showRecruitmentMenu">
                            <el-icon><User /></el-icon>
                            <span>招聘管理</span>
                        </el-menu-item>
                    </el-sub-menu>
                    <el-sub-menu index="business-process-group">
                        <template #title>过程数据</template>
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
                    </el-sub-menu>
                </el-sub-menu>

                <el-sub-menu index="collaboration-group">
                    <template #title>
                        <el-icon><Bell /></el-icon>
                        <span>个人与协同</span>
                    </template>
                    <el-menu-item index="/system/message">消息通知</el-menu-item>
                    <el-menu-item index="/system/favorite">我的收藏</el-menu-item>
                </el-sub-menu>
            </el-menu>
        </el-aside>

        <el-container>
            <el-header class="header">
                <div class="header-left">
                    <span>欢迎, {{ userInfo.realName || '用户' }}</span>
                </div>
                <div class="header-right">
                    <span class="runtime-mode-tag">
                        {{ runtimeProfile.modeName }} / {{ runtimeProfile.dataSourceMode }}
                    </span>
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
import { getRuntimeProfile } from '@/api/systemInfo'

const router = useRouter()
const route = useRoute()

const userInfo = ref({})
const unreadCount = ref(0)
const runtimeProfile = ref({
    modeName: '运行模式读取中',
    dataSourceMode: '数据源识别中'
})

const activeMenu = computed(() => route.path)
const roleCode = computed(() => userInfo.value.roleCode || 'ROLE_EMPLOYEE')
const showSystemGroup = computed(() => ['ROLE_ADMIN', 'ROLE_HR_ADMIN'].includes(roleCode.value))
const showRecruitmentMenu = computed(() => ['ROLE_ADMIN', 'ROLE_HR_ADMIN', 'ROLE_MANAGER'].includes(roleCode.value))
const canManageEmployee = computed(() => ['ROLE_ADMIN', 'ROLE_HR_ADMIN'].includes(roleCode.value))
const defaultOpeneds = computed(() => {
    const groups = ['overview-group', 'analysis-group']
    groups.push('analysis-org-group', 'analysis-salary-group')
    if (showSystemGroup.value) {
        groups.push('governance-group')
    }
    groups.push('business-group', 'business-employee-group', 'business-process-group', 'collaboration-group')
    return groups
})

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

async function loadRuntimeProfile() {
    if (!showSystemGroup.value) {
        runtimeProfile.value = {
            modeName: '业务用户',
            dataSourceMode: '无查看权限'
        }
        return
    }
    try {
        const res = await getRuntimeProfile()
        runtimeProfile.value = {
            modeName: res.data?.modeName || '标准模式',
            dataSourceMode: res.data?.dataSourceMode || '未知'
        }
    } catch {
        runtimeProfile.value = {
            modeName: '模式读取失败',
            dataSourceMode: '请检查后端接口'
        }
    }
}

onMounted(() => {
    parseUser()
    loadRuntimeProfile()
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

.runtime-mode-tag {
    background: #f0f9eb;
    color: #67c23a;
    border: 1px solid #b3e19d;
    border-radius: 4px;
    padding: 2px 8px;
    font-size: 12px;
    line-height: 20px;
    margin-right: 10px;
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
