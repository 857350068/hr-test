import { createRouter, createWebHistory } from 'vue-router'

const routes = [
    {
        path: '/login',
        name: 'Login',
        component: () => import('@/views/auth/Login.vue')
    },
    {
        path: '/register',
        name: 'Register',
        component: () => import('@/views/auth/Register.vue')
    },
    {
        path: '/',
        name: 'Layout',
        component: () => import('@/views/Layout.vue'),
        redirect: '/dashboard',
        children: [
            {
                path: '/dashboard',
                name: 'Dashboard',
                component: () => import('@/views/dashboard/Index.vue')
            },
            {
                path: '/employee',
                name: 'Employee',
                component: () => import('@/views/employee/Index.vue'),
                meta: { roles: ['ROLE_ADMIN', 'ROLE_HR_ADMIN'] }
            },
            {
                path: '/attendance',
                name: 'Attendance',
                component: () => import('@/views/attendance/Index.vue')
            },
            {
                path: '/leave',
                name: 'Leave',
                component: () => import('@/views/leave/Index.vue')
            },
            {
                path: '/performance',
                name: 'Performance',
                component: () => import('@/views/performance/Index.vue')
            },
            {
                path: '/salary',
                name: 'Salary',
                component: () => import('@/views/salary/Index.vue')
            },
            {
                path: '/training',
                name: 'Training',
                component: () => import('@/views/training/Index.vue')
            },
            {
                path: '/recruitment',
                name: 'Recruitment',
                component: () => import('@/views/recruitment/Index.vue'),
                meta: { roles: ['ROLE_ADMIN', 'ROLE_HR_ADMIN', 'ROLE_MANAGER'] }
            },
            {
                path: '/analysis/dashboard',
                name: 'AnalysisDashboard',
                component: () => import('@/views/analysis/Dashboard.vue')
            },
            {
                path: '/analysis/org-efficiency',
                name: 'OrgEfficiency',
                component: () => import('@/views/analysis/OrgEfficiency.vue')
            },
            {
                path: '/analysis/talent-pipeline',
                name: 'TalentPipeline',
                component: () => import('@/views/analysis/TalentPipeline.vue')
            },
            {
                path: '/analysis/salary',
                name: 'SalaryAnalysis',
                component: () => import('@/views/analysis/SalaryAnalysis.vue')
            },
            {
                path: '/analysis/warning',
                name: 'WarningAnalysis',
                component: () => import('@/views/analysis/WarningAnalysis.vue')
            },
            {
                path: '/system/user',
                name: 'UserManager',
                component: () => import('@/views/system/UserManager.vue'),
                meta: { roles: ['ROLE_ADMIN'] }
            },
            {
                path: '/system/operation-log',
                name: 'OperationLog',
                component: () => import('@/views/system/OperationLog.vue'),
                meta: { roles: ['ROLE_ADMIN'] }
            },
            {
                path: '/system/data-category',
                name: 'DataCategory',
                component: () => import('@/views/category/Index.vue'),
                meta: { roles: ['ROLE_ADMIN', 'ROLE_HR_ADMIN'] }
            },
            {
                path: '/system/message',
                name: 'MessageCenter',
                component: () => import('@/views/system/MessageCenter.vue')
            },
            {
                path: '/system/favorite',
                name: 'FavoriteCenter',
                component: () => import('@/views/system/FavoriteCenter.vue')
            },
            {
                path: '/system/rule',
                name: 'RuleManager',
                component: () => import('@/views/system/RuleManager.vue'),
                meta: { roles: ['ROLE_ADMIN', 'ROLE_HR_ADMIN'] }
            },
            {
                path: '/system/model',
                name: 'ModelManager',
                component: () => import('@/views/system/ModelManager.vue'),
                meta: { roles: ['ROLE_ADMIN', 'ROLE_HR_ADMIN'] }
            },
            {
                path: '/system/report',
                name: 'ReportCenter',
                component: () => import('@/views/system/ReportCenter.vue'),
                meta: { roles: ['ROLE_ADMIN', 'ROLE_HR_ADMIN'] }
            },
            {
                path: '/profile',
                name: 'Profile',
                component: () => import('@/views/profile/Index.vue')
            }
        ]
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

router.beforeEach((to, from, next) => {
    const token = localStorage.getItem('token')

    if (to.path === '/login' || to.path === '/register') {
        if (token) {
            next('/')
        } else {
            next()
        }
    } else {
        if (token) {
            const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')
            const roleCode = userInfo.roleCode || 'ROLE_EMPLOYEE'
            const roles = to.meta?.roles || []
            if (roles.length > 0 && !roles.includes(roleCode)) {
                next('/dashboard')
                return
            }
            next()
        } else {
            next('/login')
        }
    }
})

export default router
