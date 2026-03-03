<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">个人中心</h2>
    </div>
    <el-card>
      <el-form :model="form" label-width="100px" style="max-width: 500px">
        <el-form-item label="工号">{{ userInfo.username }}</el-form-item>
        <el-form-item label="姓名">{{ userInfo.name }}</el-form-item>
        <el-form-item label="角色">{{ userInfo.role }}</el-form-item>
        <el-form-item label="部门">{{ userInfo.deptName }}</el-form-item>
        <el-form-item label="修改密码">
          <el-input v-model="form.oldPassword" type="password" placeholder="原密码" show-password />
          <el-input v-model="form.newPassword" type="password" placeholder="新密码" show-password style="margin-top: 8px" />
          <el-button type="primary" style="margin-top: 8px" @click="changePassword">确认修改</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { changePassword as changePasswordApi } from '@/api/auth'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const userInfo = ref({})
const form = reactive({ oldPassword: '', newPassword: '' })

onMounted(async () => {
  try {
    await userStore.getUserInfo()
    userInfo.value = userStore.userInfo
  } catch (e) {}
})

const changePassword = async () => {
  if (!form.oldPassword || !form.newPassword) {
    ElMessage.warning('请填写原密码和新密码')
    return
  }
  try {
    await changePasswordApi(form)
    ElMessage.success('密码已修改')
    form.oldPassword = ''
    form.newPassword = ''
  } catch (e) {}
}
</script>
