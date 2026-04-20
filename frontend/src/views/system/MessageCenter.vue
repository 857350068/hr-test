<template>
    <div class="message-center">
        <h2>消息通知</h2>

        <el-tabs v-model="tab">
            <el-tab-pane label="我的消息" name="inbox">
                <el-card>
                    <div class="toolbar">
                        <el-button type="primary" @click="loadInbox">刷新</el-button>
                        <el-button @click="markAllRead" :disabled="!userId">全部标为已读</el-button>
                    </div>
                    <el-table :data="messages" border v-loading="loading">
                        <el-table-column prop="title" label="标题" min-width="160" show-overflow-tooltip />
                        <el-table-column prop="content" label="内容" min-width="220" show-overflow-tooltip />
                        <el-table-column label="类型" width="100">
                            <template #default="{ row }">
                                <el-tag v-if="row.messageType === 1">系统</el-tag>
                                <el-tag v-else-if="row.messageType === 2" type="warning">审批</el-tag>
                                <el-tag v-else type="info">个人</el-tag>
                            </template>
                        </el-table-column>
                        <el-table-column label="状态" width="90">
                            <template #default="{ row }">
                                <el-tag :type="row.isRead === 1 ? 'info' : 'danger'">{{ row.isRead === 1 ? '已读' : '未读' }}</el-tag>
                            </template>
                        </el-table-column>
                        <el-table-column prop="createTime" label="时间" width="170" />
                        <el-table-column label="操作" width="160" fixed="right">
                            <template #default="{ row }">
                                <el-button v-if="row.isRead === 0" type="primary" link @click="markOne(row)">标为已读</el-button>
                                <el-button type="danger" link @click="remove(row)">删除</el-button>
                            </template>
                        </el-table-column>
                    </el-table>
                </el-card>
            </el-tab-pane>

            <el-tab-pane label="发送个人消息" name="send">
                <el-card>
                    <el-form :model="sendForm" label-width="100px" style="max-width: 520px">
                        <el-form-item label="接收者ID" required>
                            <el-input-number v-model="sendForm.receiverId" :min="1" style="width: 100%" />
                        </el-form-item>
                        <el-form-item label="标题" required>
                            <el-input v-model="sendForm.title" maxlength="200" show-word-limit />
                        </el-form-item>
                        <el-form-item label="内容" required>
                            <el-input v-model="sendForm.content" type="textarea" :rows="4" />
                        </el-form-item>
                        <el-form-item>
                            <el-button type="primary" :loading="sending" @click="submitSend">发送</el-button>
                        </el-form-item>
                    </el-form>
                </el-card>
            </el-tab-pane>

            <el-tab-pane label="系统公告" name="broadcast">
                <el-card>
                    <el-alert
                        title="公告将写入消息表并尝试通过 WebSocket 广播；数据库要求接收者非空，此处将接收者设为当前用户以便在「我的消息」中可见。"
                        type="info"
                        show-icon
                        style="margin-bottom: 16px"
                    />
                    <el-form :model="bcForm" label-width="100px" style="max-width: 520px">
                        <el-form-item label="标题" required>
                            <el-input v-model="bcForm.title" maxlength="200" />
                        </el-form-item>
                        <el-form-item label="内容" required>
                            <el-input v-model="bcForm.content" type="textarea" :rows="5" />
                        </el-form-item>
                        <el-form-item>
                            <el-button type="primary" :loading="sending" @click="submitBroadcast">发布公告</el-button>
                        </el-form-item>
                    </el-form>
                </el-card>
            </el-tab-pane>
        </el-tabs>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
    getMessageList,
    sendMessage,
    broadcastMessage,
    markMessageRead,
    markAllMessagesRead,
    deleteMessage
} from '@/api/message'

const tab = ref('inbox')
const loading = ref(false)
const sending = ref(false)
const messages = ref([])

const userInfo = computed(() => {
    try {
        return JSON.parse(localStorage.getItem('userInfo') || '{}')
    } catch {
        return {}
    }
})

const userId = computed(() => userInfo.value.userId)

const sendForm = ref({
    receiverId: undefined,
    title: '',
    content: ''
})

const bcForm = ref({
    title: '',
    content: ''
})

async function loadInbox() {
    if (!userId.value) {
        ElMessage.warning('未获取到用户ID，请重新登录')
        return
    }
    loading.value = true
    try {
        const res = await getMessageList({ userId: userId.value, page: 1, size: 200 })
        messages.value = res.data || []
    } finally {
        loading.value = false
    }
}

async function markOne(row) {
    await markMessageRead(row.messageId)
    ElMessage.success('已标记')
    loadInbox()
    window.dispatchEvent(new Event('message-read'))
}

async function markAllRead() {
    if (!userId.value) return
    await markAllMessagesRead(userId.value)
    ElMessage.success('已全部标为已读')
    loadInbox()
    window.dispatchEvent(new Event('message-read'))
}

async function remove(row) {
    try {
        await ElMessageBox.confirm('确定删除？', '提示', { type: 'warning' })
        await deleteMessage(row.messageId)
        ElMessage.success('已删除')
        loadInbox()
        window.dispatchEvent(new Event('message-read'))
    } catch (e) {
        if (e !== 'cancel') ElMessage.error('删除失败')
    }
}

async function submitSend() {
    if (!userId.value || !sendForm.value.receiverId) {
        ElMessage.warning('请填写接收者ID')
        return
    }
    sending.value = true
    try {
        await sendMessage({
            senderId: userId.value,
            receiverId: sendForm.value.receiverId,
            title: sendForm.value.title,
            content: sendForm.value.content,
            messageType: 3
        })
        ElMessage.success('已发送')
        sendForm.value = { receiverId: undefined, title: '', content: '' }
    } finally {
        sending.value = false
    }
}

async function submitBroadcast() {
    if (!userId.value) {
        ElMessage.warning('请重新登录')
        return
    }
    sending.value = true
    try {
        await broadcastMessage({
            senderId: userId.value,
            receiverId: userId.value,
            title: bcForm.value.title,
            content: bcForm.value.content,
            messageType: 1
        })
        ElMessage.success('公告已发布')
        bcForm.value = { title: '', content: '' }
        loadInbox()
        window.dispatchEvent(new Event('message-read'))
    } finally {
        sending.value = false
    }
}

onMounted(loadInbox)
</script>

<style scoped>
.message-center {
    padding: 20px;
}
h2 {
    margin-bottom: 16px;
}
.toolbar {
    margin-bottom: 12px;
}
</style>
