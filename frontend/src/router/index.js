import { createRouter, createWebHistory } from 'vue-router'

const routes = [
    {
        path: '/login',
        name: 'Login',
        component: () => import('@/views/auth/Login.vue')
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
                component: () => import('@/views/employee/Index.vue')
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
            }
        ]
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
    const token = localStorage.getItem('token')

    if (to.path === '/login') {
        if (token) {
            next('/')
        } else {
            next()
        }
    } else {
        if (token) {
            next()
        } else {
            next('/login')
        }
    }
})

export default router
