<template>
    <div class="login-container">
        <div class="login-box">
            <h2>用户注册</h2>
            <el-form :model="registerForm" :rules="rules" ref="registerFormRef" class="login-form">
                <el-form-item prop="username">
                    <el-input v-model="registerForm.username" placeholder="请输入用户名（4-20位）" prefix-icon="User" />
                </el-form-item>
                <el-form-item prop="realName">
                    <el-input v-model="registerForm.realName" placeholder="请输入真实姓名" prefix-icon="UserFilled" />
                </el-form-item>
                <el-form-item prop="phone">
                    <el-input v-model="registerForm.phone" placeholder="请输入手机号" prefix-icon="Iphone" />
                </el-form-item>
                <el-form-item prop="email">
                    <el-input v-model="registerForm.email" placeholder="请输入邮箱" prefix-icon="Message" />
                </el-form-item>
                <el-form-item prop="roleCode">
                    <el-select v-model="registerForm.roleCode" placeholder="请选择角色" style="width: 100%">
                        <el-option label="普通员工" value="ROLE_EMPLOYEE" />
                        <el-option label="部门负责人" value="ROLE_MANAGER" />
                        <el-option label="HR管理员" value="ROLE_HR_ADMIN" />
                    </el-select>
                </el-form-item>
                <el-form-item prop="password">
                    <el-input
                        v-model="registerForm.password"
                        type="password"
                        show-password
                        placeholder="请输入密码（6-20位）"
                        prefix-icon="Lock"
                    />
                </el-form-item>
                <el-form-item prop="confirmPassword">
                    <el-input
                        v-model="registerForm.confirmPassword"
                        type="password"
                        show-password
                        placeholder="请再次输入密码"
                        prefix-icon="Lock"
                        @keyup.enter="handleRegister"
                    />
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" :loading="loading" @click="handleRegister" style="width: 100%">
                        注册
                    </el-button>
                </el-form-item>
            </el-form>
            <div class="auth-switch">
                <span>已有账号？</span>
                <el-link type="primary" @click="goLogin">去登录</el-link>
            </div>
        </div>
    </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { register } from '@/api/auth'

const router = useRouter()
const registerFormRef = ref(null)
const loading = ref(false)

const registerForm = reactive({
    username: '',
    realName: '',
    phone: '',
    email: '',
    roleCode: 'ROLE_EMPLOYEE',
    password: '',
    confirmPassword: ''
})

const validateConfirmPassword = (_, value, callback) => {
    if (!value) {
        callback(new Error('请再次输入密码'))
        return
    }
    if (value !== registerForm.password) {
        callback(new Error('两次输入密码不一致'))
        return
    }
    callback()
}

const rules = {
    username: [
        { required: true, message: '请输入用户名', trigger: 'blur' },
        { min: 4, max: 20, message: '用户名长度需在4-20位之间', trigger: 'blur' }
    ],
    realName: [{ required: true, message: '请输入真实姓名', trigger: 'blur' }],
    phone: [
        { required: true, message: '请输入手机号', trigger: 'blur' },
        { pattern: /^1\d{10}$/, message: '手机号格式不正确', trigger: 'blur' }
    ],
    email: [
        { required: true, message: '请输入邮箱', trigger: 'blur' },
        { type: 'email', message: '邮箱格式不正确', trigger: 'blur' }
    ],
    roleCode: [{ required: true, message: '请选择角色', trigger: 'change' }],
    password: [
        { required: true, message: '请输入密码', trigger: 'blur' },
        { min: 6, max: 20, message: '密码长度需在6-20位之间', trigger: 'blur' }
    ],
    confirmPassword: [{ validator: validateConfirmPassword, trigger: 'blur' }]
}

const handleRegister = () => {
    registerFormRef.value.validate(async (valid) => {
        if (!valid) return

        loading.value = true
        try {
            await register({
                username: registerForm.username,
                realName: registerForm.realName,
                phone: registerForm.phone,
                email: registerForm.email,
                roleCode: registerForm.roleCode,
                password: registerForm.password
            })
            ElMessage.success('注册成功，请登录')
            router.push({
                path: '/login',
                query: { username: registerForm.username }
            })
        } catch (error) {
            console.error('注册失败:', error)
        } finally {
            loading.value = false
        }
    })
}

const goLogin = () => {
    router.push('/login')
}
</script>

<style scoped>
.login-container {
    width: 100%;
    min-height: 100vh;
    padding: 32px 0;
    background: linear-gradient(135deg, #ffffff 100%);
    display: flex;
    justify-content: center;
    align-items: center;
}

.login-box {
    width: 420px;
    padding: 36px 40px;
    background: white;
    border-radius: 10px;
    box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
}

.login-box h2 {
    text-align: center;
    margin-bottom: 24px;
    color: #333;
}

.login-form {
    margin-top: 12px;
}

.auth-switch {
    margin-top: 14px;
    text-align: center;
    color: #666;
    font-size: 14px;
}
</style>
