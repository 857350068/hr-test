<template>
    <div class="login-container">
        <div class="login-box">
            <h2>人力资源数据中心</h2>
            <el-form :model="loginForm" :rules="rules" ref="loginFormRef" class="login-form">
                <el-form-item prop="username">
                    <el-input v-model="loginForm.username" placeholder="请输入用户名" prefix-icon="User" />
                </el-form-item>
                <el-form-item prop="password">
                    <el-input
                        ref="passwordInputRef"
                        v-model="loginForm.password"
                        type="password"
                        placeholder="请输入密码"
                        prefix-icon="Lock"
                        @keyup.enter="handleLogin"
                    />
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" :loading="loading" @click="handleLogin" style="width: 100%">登录</el-button>
                </el-form-item>
            </el-form>
            <div class="auth-switch">
                <span>还没有账号？</span>
                <el-link type="primary" @click="goRegister">去注册</el-link>
            </div>
            <div class="tips">
                <p>测试账号: admin / 123456</p>
                <p>测试账号: hr001 / 123456</p>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { login } from '@/api/auth'

const router = useRouter()
const route = useRoute()
const loginFormRef = ref(null)
const passwordInputRef = ref(null)
const loading = ref(false)

const loginForm = reactive({
    username: '',
    password: ''
})

const rules = {
    username: [
        { required: true, message: '请输入用户名', trigger: 'blur' }
    ],
    password: [
        { required: true, message: '请输入密码', trigger: 'blur' }
    ]
}

onMounted(async () => {
    const presetUsername = typeof route.query.username === 'string' ? route.query.username : ''
    if (!presetUsername) return
    loginForm.username = presetUsername
    await nextTick()
    passwordInputRef.value?.focus?.()
})

const handleLogin = () => {
    loginFormRef.value.validate(async (valid) => {
        if (!valid) return

        loading.value = true
        try {
            const res = await login(loginForm)
            // 保存token和用户信息
            localStorage.setItem('token', res.data.token)
            localStorage.setItem('userInfo', JSON.stringify(res.data))

            ElMessage.success('登录成功')
            router.push('/')
        } catch (error) {
            console.error('登录失败:', error)
        } finally {
            loading.value = false
        }
    })
}

const goRegister = () => {
    router.push('/register')
}
</script>

<style scoped>
.login-container {
    width: 100%;
    height: 100vh;
    background: linear-gradient(135deg, #ffffff 100%);
    display: flex;
    justify-content: center;
    align-items: center;
}

.login-box {
    width: 400px;
    padding: 40px;
    background: white;
    border-radius: 10px;
    box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
}

.login-box h2 {
    text-align: center;
    margin-bottom: 30px;
    color: #333;
}

.login-form {
    margin-top: 20px;
}

.auth-switch {
    text-align: center;
    color: #666;
    font-size: 14px;
}

.tips {
    margin-top: 20px;
    text-align: center;
    color: #999;
    font-size: 14px;
}

.tips p {
    margin: 5px 0;
}
</style>
