<template>
    <div class="profile-page">
        <h2>个人中心</h2>
        <el-row :gutter="20">
            <el-col :span="12">
                <el-card>
                    <template #header>个人资料</template>
                    <el-form :model="profileForm" label-width="90px">
                        <el-form-item label="用户名">
                            <el-input v-model="profileForm.username" disabled />
                        </el-form-item>
                        <el-form-item label="姓名">
                            <el-input v-model="profileForm.realName" />
                        </el-form-item>
                        <el-form-item label="手机号">
                            <el-input v-model="profileForm.phone" />
                        </el-form-item>
                        <el-form-item label="邮箱">
                            <el-input v-model="profileForm.email" />
                        </el-form-item>
                        <el-form-item>
                            <el-button type="primary" @click="handleSaveProfile">保存资料</el-button>
                        </el-form-item>
                    </el-form>
                </el-card>
            </el-col>
            <el-col :span="12">
                <el-card>
                    <template #header>修改密码</template>
                    <el-form :model="passwordForm" label-width="90px">
                        <el-form-item label="原密码">
                            <el-input v-model="passwordForm.oldPassword" type="password" show-password />
                        </el-form-item>
                        <el-form-item label="新密码">
                            <el-input v-model="passwordForm.newPassword" type="password" show-password />
                        </el-form-item>
                        <el-form-item label="确认密码">
                            <el-input v-model="passwordForm.confirmPassword" type="password" show-password />
                        </el-form-item>
                        <el-form-item>
                            <el-button type="primary" @click="handleChangePassword">修改密码</el-button>
                        </el-form-item>
                    </el-form>
                </el-card>
            </el-col>
        </el-row>
    </div>
</template>

<script setup>
import { onMounted, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import { changePassword, getProfile, updateProfile } from '@/api/auth'

const profileForm = reactive({
    username: '',
    realName: '',
    phone: '',
    email: ''
})

const passwordForm = reactive({
    oldPassword: '',
    newPassword: '',
    confirmPassword: ''
})

async function loadProfile() {
    const res = await getProfile()
    Object.assign(profileForm, res.data || {})
}

async function handleSaveProfile() {
    await updateProfile({
        realName: profileForm.realName,
        phone: profileForm.phone,
        email: profileForm.email
    })
    const old = JSON.parse(localStorage.getItem('userInfo') || '{}')
    localStorage.setItem('userInfo', JSON.stringify({ ...old, realName: profileForm.realName }))
    ElMessage.success('个人资料已更新')
}

async function handleChangePassword() {
    if (!passwordForm.oldPassword || !passwordForm.newPassword) {
        ElMessage.warning('请完整填写密码信息')
        return
    }
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
        ElMessage.warning('两次新密码输入不一致')
        return
    }
    await changePassword({
        oldPassword: passwordForm.oldPassword,
        newPassword: passwordForm.newPassword
    })
    passwordForm.oldPassword = ''
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''
    ElMessage.success('密码修改成功')
}

onMounted(() => {
    loadProfile()
})
</script>

<style scoped>
.profile-page {
    padding: 20px;
}
h2 {
    margin-bottom: 20px;
}
</style>
