<template>
    <div class="operation-log-page">
        <h2>操作日志</h2>

        <el-card class="mb">
            <el-form :inline="true" :model="query">
                <el-form-item label="模块">
                    <el-input v-model="query.module" placeholder="模块关键词" clearable style="width: 160px" />
                </el-form-item>
                <el-form-item label="操作人">
                    <el-input v-model="query.operator" placeholder="操作人" clearable style="width: 140px" />
                </el-form-item>
                <el-form-item label="状态">
                    <el-select v-model="query.status" placeholder="全部" clearable style="width: 110px">
                        <el-option label="失败" :value="0" />
                        <el-option label="成功" :value="1" />
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="loadList">查询</el-button>
                    <el-button @click="resetQuery">重置</el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <el-card class="mb">
            <el-button type="danger" :disabled="!selection.length" @click="handleBatchDelete">批量删除</el-button>
            <el-button type="warning" @click="openClear">按天数清空</el-button>
        </el-card>

        <el-card>
            <el-table
                :data="tableData"
                border
                v-loading="loading"
                @selection-change="(rows) => (selection = rows)"
            >
                <el-table-column type="selection" width="48" />
                <el-table-column prop="logId" label="ID" width="80" />
                <el-table-column prop="module" label="模块" width="120" show-overflow-tooltip />
                <el-table-column prop="operationType" label="类型" width="100" />
                <el-table-column prop="operationDesc" label="描述" min-width="160" show-overflow-tooltip />
                <el-table-column prop="operator" label="操作人" width="100" />
                <el-table-column prop="ipAddress" label="IP" width="130" />
                <el-table-column prop="executionTime" label="耗时(ms)" width="100" />
                <el-table-column label="状态" width="80">
                    <template #default="{ row }">
                        <el-tag :type="row.status === 1 ? 'success' : 'danger'">{{ row.status === 1 ? '成功' : '失败' }}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="operationTime" label="操作时间" width="170" />
                <el-table-column label="操作" width="160" fixed="right">
                    <template #default="{ row }">
                        <el-button type="primary" link @click="openDetail(row)">详情</el-button>
                        <el-button type="danger" link @click="handleDelete(row)">删除</el-button>
                    </template>
                </el-table-column>
            </el-table>
            <el-pagination
                v-model:current-page="page"
                v-model:page-size="size"
                :total="total"
                :page-sizes="[10, 20, 50]"
                layout="total, sizes, prev, pager, next"
                style="margin-top: 16px; justify-content: flex-end"
                @size-change="loadList"
                @current-change="loadList"
            />
        </el-card>

        <el-dialog v-model="detailVisible" title="日志详情" width="640px" destroy-on-close>
            <el-descriptions v-if="current" :column="1" border>
                <el-descriptions-item label="模块">{{ current.module }}</el-descriptions-item>
                <el-descriptions-item label="描述">{{ current.operationDesc }}</el-descriptions-item>
                <el-descriptions-item label="请求">{{ current.requestMethod }} {{ current.requestUrl }}</el-descriptions-item>
                <el-descriptions-item label="参数"><pre class="pre">{{ current.requestParams }}</pre></el-descriptions-item>
                <el-descriptions-item label="结果"><pre class="pre">{{ current.responseResult }}</pre></el-descriptions-item>
                <el-descriptions-item v-if="current.errorMsg" label="错误"><pre class="pre">{{ current.errorMsg }}</pre></el-descriptions-item>
            </el-descriptions>
        </el-dialog>

        <el-dialog v-model="clearVisible" title="清空日志" width="400px">
            <p>删除指定天数之前的所有日志（默认 30 天）。</p>
            <el-input-number v-model="clearDays" :min="1" :max="3650" />
            <template #footer>
                <el-button @click="clearVisible = false">取消</el-button>
                <el-button type="danger" @click="doClear">确定清空</el-button>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
    getOperationLogList,
    deleteOperationLog,
    batchDeleteOperationLogs,
    clearOperationLogs
} from '@/api/operationLog'

const loading = ref(false)
const tableData = ref([])
const selection = ref([])
const page = ref(1)
const size = ref(20)
const total = ref(0)
const query = ref({ module: '', operator: '', status: undefined })
const detailVisible = ref(false)
const current = ref(null)
const clearVisible = ref(false)
const clearDays = ref(30)

async function loadList() {
    loading.value = true
    try {
        const res = await getOperationLogList({
            page: page.value,
            size: size.value,
            module: query.value.module || undefined,
            operator: query.value.operator || undefined,
            status: query.value.status
        })
        const p = res.data
        tableData.value = p.records || p.list || []
        total.value = p.total || 0
    } catch (e) {
        ElMessage.error('加载失败')
    } finally {
        loading.value = false
    }
}

function resetQuery() {
    query.value = { module: '', operator: '', status: undefined }
    page.value = 1
    loadList()
}

function openDetail(row) {
    current.value = row
    detailVisible.value = true
}

async function handleDelete(row) {
    try {
        await ElMessageBox.confirm('确定删除该日志？', '提示', { type: 'warning' })
        await deleteOperationLog(row.logId)
        ElMessage.success('已删除')
        loadList()
    } catch (e) {
        if (e !== 'cancel') ElMessage.error('删除失败')
    }
}

async function handleBatchDelete() {
    if (!selection.value.length) return
    try {
        await ElMessageBox.confirm(`确定删除选中的 ${selection.value.length} 条？`, '提示', { type: 'warning' })
        const ids = selection.value.map((r) => r.logId)
        await batchDeleteOperationLogs(ids)
        ElMessage.success('已删除')
        loadList()
    } catch (e) {
        if (e !== 'cancel') ElMessage.error('删除失败')
    }
}

function openClear() {
    clearVisible.value = true
}

async function doClear() {
    try {
        await clearOperationLogs(clearDays.value)
        ElMessage.success('已清空')
        clearVisible.value = false
        loadList()
    } catch (e) {
        ElMessage.error('清空失败')
    }
}

onMounted(loadList)
</script>

<style scoped>
.operation-log-page {
    padding: 20px;
}
h2 {
    margin-bottom: 16px;
    color: #303133;
}
.mb {
    margin-bottom: 16px;
}
.pre {
    white-space: pre-wrap;
    word-break: break-all;
    font-size: 12px;
    max-height: 200px;
    overflow: auto;
}
</style>
