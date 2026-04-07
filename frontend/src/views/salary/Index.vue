<template>
    <div class="salary-management">
        <h2>薪酬管理</h2>

        <!-- 功能标签页 -->
        <el-tabs v-model="activeTab" @tab-change="handleTabChange">
            <el-tab-pane label="薪资发放管理" name="payment">
                <div class="payment-management">
                    <!-- 操作按钮 -->
                    <el-card style="margin-bottom: 20px">
                        <el-button type="primary" @click="handleAddPayment">
                            <el-icon><Plus /></el-icon>
                            新增薪资
                        </el-button>
                        <el-button type="success" @click="handleBatchRelease">
                            <el-icon><Check /></el-icon>
                            批量发放
                        </el-button>
                        <el-button type="success" @click="handleExportSalary">
                            <el-icon><Download /></el-icon>
                            批量导出
                        </el-button>
                    </el-card>

                    <!-- 查询表单 -->
                    <el-card style="margin-bottom: 20px">
                        <el-form :inline="true" :model="searchForm">
                            <el-form-item label="员工ID">
                                <el-input v-model="searchForm.empId" placeholder="请输入员工ID" clearable style="width: 120px" />
                            </el-form-item>
                            <el-form-item label="年度">
                                <el-select v-model="searchForm.year" placeholder="请选择" clearable style="width: 120px">
                                    <el-option v-for="y in years" :key="y" :label="y" :value="y" />
                                </el-select>
                            </el-form-item>
                            <el-form-item label="月份">
                                <el-select v-model="searchForm.month" placeholder="请选择" clearable style="width: 120px">
                                    <el-option v-for="m in months" :key="m" :label="m + '月'" :value="m" />
                                </el-select>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" @click="handleSearch">查询</el-button>
                                <el-button @click="handleReset">重置</el-button>
                            </el-form-item>
                        </el-form>
                    </el-card>

                    <!-- 数据表格 -->
                    <el-card>
                        <el-table :data="tableData" border style="width: 100%" v-loading="loading" @selection-change="handleSelectionChange">
                            <el-table-column type="selection" width="55" />
                            <el-table-column type="index" label="序号" width="60" />
                            <el-table-column prop="empId" label="员工ID" width="80" />
                            <el-table-column prop="year" label="年度" width="80" />
                            <el-table-column prop="month" label="月份" width="80" />
                            <el-table-column prop="basicSalary" label="基本工资" width="100">
                                <template #default="{ row }">
                                    <span v-if="row.basicSalary">¥{{ row.basicSalary.toFixed(2) }}</span>
                                    <span v-else>-</span>
                                </template>
                            </el-table-column>
                            <el-table-column prop="performanceSalary" label="绩效工资" width="100">
                                <template #default="{ row }">
                                    <span v-if="row.performanceSalary">¥{{ row.performanceSalary.toFixed(2) }}</span>
                                    <span v-else>-</span>
                                </template>
                            </el-table-column>
                            <el-table-column prop="totalGrossSalary" label="应发工资" width="110">
                                <template #default="{ row }">
                                    <span v-if="row.totalGrossSalary" style="color: #409EFF; font-weight: bold">¥{{ row.totalGrossSalary.toFixed(2) }}</span>
                                    <span v-else>-</span>
                                </template>
                            </el-table-column>
                            <el-table-column prop="totalNetSalary" label="实发工资" width="110">
                                <template #default="{ row }">
                                    <span v-if="row.totalNetSalary" style="color: #67C23A; font-weight: bold">¥{{ row.totalNetSalary.toFixed(2) }}</span>
                                    <span v-else>-</span>
                                </template>
                            </el-table-column>
                            <el-table-column prop="paymentStatus" label="发放状态" width="100">
                                <template #default="{ row }">
                                    <el-tag v-if="row.paymentStatus === 0" type="warning">未发放</el-tag>
                                    <el-tag v-else type="success">已发放</el-tag>
                                </template>
                            </el-table-column>
                            <el-table-column prop="paymentDate" label="发放时间" width="120" />
                            <el-table-column label="操作" width="250" fixed="right">
                                <template #default="{ row }">
                                    <el-button type="primary" size="small" @click="handleEditPayment(row)">编辑</el-button>
                                    <el-button 
                                        v-if="row.paymentStatus === 0" 
                                        type="success" 
                                        size="small" 
                                        @click="handleReleasePayment(row)"
                                    >
                                        发放
                                    </el-button>
                                    <el-button type="info" size="small" @click="handleViewDetail(row)">详情</el-button>
                                </template>
                            </el-table-column>
                        </el-table>

                        <!-- 分页 -->
                        <el-pagination
                            v-model:current-page="pagination.page"
                            v-model:page-size="pagination.size"
                            :page-sizes="[10, 20, 50, 100]"
                            :total="pagination.total"
                            layout="total, sizes, prev, pager, next, jumper"
                            @size-change="handleSizeChange"
                            @current-change="handleCurrentChange"
                            style="margin-top: 20px; justify-content: flex-end"
                        />
                    </el-card>
                </div>
            </el-tab-pane>

            <el-tab-pane label="薪资调整管理" name="adjustment">
                <div class="adjustment-management">
                    <!-- 操作按钮 -->
                    <el-card style="margin-bottom: 20px">
                        <el-button type="primary" @click="handleApplyAdjustment">
                            <el-icon><Plus /></el-icon>
                            申请调整
                        </el-button>
                        <el-button type="success" @click="handlePendingApproval">
                            <el-icon><DocumentChecked /></el-icon>
                            待审批({{ pendingCount }})
                        </el-button>
                    </el-card>

                    <!-- 查询表单 -->
                    <el-card style="margin-bottom: 20px">
                        <el-form :inline="true" :model="adjustmentSearchForm">
                            <el-form-item label="员工ID">
                                <el-input v-model="adjustmentSearchForm.empId" placeholder="请输入员工ID" clearable style="width: 120px" />
                            </el-form-item>
                            <el-form-item label="审批状态">
                                <el-select v-model="adjustmentSearchForm.approvalStatus" placeholder="请选择" clearable style="width: 120px">
                                    <el-option label="待审批" :value="0" />
                                    <el-option label="已同意" :value="1" />
                                    <el-option label="已拒绝" :value="2" />
                                </el-select>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" @click="handleAdjustmentSearch">查询</el-button>
                                <el-button @click="handleAdjustmentReset">重置</el-button>
                            </el-form-item>
                        </el-form>
                    </el-card>

                    <!-- 数据表格 -->
                    <el-card>
                        <el-table :data="adjustmentTableData" border style="width: 100%" v-loading="adjustmentLoading">
                            <el-table-column type="index" label="序号" width="60" />
                            <el-table-column prop="empId" label="员工ID" width="80" />
                            <el-table-column prop="adjustmentType" label="调整类型" width="100">
                                <template #default="{ row }">
                                    {{ getAdjustmentTypeText(row.adjustmentType) }}
                                </template>
                            </el-table-column>
                            <el-table-column prop="beforeSalary" label="调整前工资" width="120">
                                <template #default="{ row }">
                                    <span v-if="row.beforeSalary">¥{{ row.beforeSalary.toFixed(2) }}</span>
                                    <span v-else>-</span>
                                </template>
                            </el-table-column>
                            <el-table-column prop="afterSalary" label="调整后工资" width="120">
                                <template #default="{ row }">
                                    <span v-if="row.afterSalary" style="color: #67C23A; font-weight: bold">¥{{ row.afterSalary.toFixed(2) }}</span>
                                    <span v-else>-</span>
                                </template>
                            </el-table-column>
                            <el-table-column prop="adjustmentRate" label="调整幅度" width="100">
                                <template #default="{ row }">
                                    <span v-if="row.adjustmentRate">{{ row.adjustmentRate }}%</span>
                                    <span v-else>-</span>
                                </template>
                            </el-table-column>
                            <el-table-column prop="effectiveDate" label="生效日期" width="120" />
                            <el-table-column prop="reason" label="调整原因" width="200" show-overflow-tooltip />
                            <el-table-column prop="approvalStatus" label="审批状态" width="100">
                                <template #default="{ row }">
                                    <el-tag v-if="row.approvalStatus === 0" type="warning">待审批</el-tag>
                                    <el-tag v-else-if="row.approvalStatus === 1" type="success">已同意</el-tag>
                                    <el-tag v-else type="danger">已拒绝</el-tag>
                                </template>
                            </el-table-column>
                            <el-table-column label="操作" width="200" fixed="right">
                                <template #default="{ row }">
                                    <el-button type="primary" size="small" @click="handleViewAdjustment(row)">查看</el-button>
                                    <el-button 
                                        v-if="row.approvalStatus === 0" 
                                        type="success" 
                                        size="small" 
                                        @click="handleApproveAdjustment(row)"
                                    >
                                        审批
                                    </el-button>
                                </template>
                            </el-table-column>
                        </el-table>

                        <!-- 分页 -->
                        <el-pagination
                            v-model:current-page="adjustmentPagination.page"
                            v-model:page-size="adjustmentPagination.size"
                            :page-sizes="[10, 20, 50, 100]"
                            :total="adjustmentPagination.total"
                            layout="total, sizes, prev, pager, next, jumper"
                            @size-change="handleAdjustmentSizeChange"
                            @current-change="handleAdjustmentCurrentChange"
                            style="margin-top: 20px; justify-content: flex-end"
                        />
                    </el-card>
                </div>
            </el-tab-pane>
        </el-tabs>

        <!-- 新增/编辑薪资对话框 -->
        <el-dialog
            v-model="paymentDialogVisible"
            :title="paymentDialogTitle"
            width="800px"
            @close="handlePaymentDialogClose"
        >
            <el-form :model="paymentForm" :rules="paymentRules" ref="paymentFormRef" label-width="120px">
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="员工ID" prop="empId">
                            <el-input v-model="paymentForm.empId" placeholder="请输入员工ID" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="年度" prop="year">
                            <el-select v-model="paymentForm.year" placeholder="请选择年度" style="width: 100%">
                                <el-option v-for="y in years" :key="y" :label="y" :value="y" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="月份" prop="month">
                            <el-select v-model="paymentForm.month" placeholder="请选择月份" style="width: 100%">
                                <el-option v-for="m in months" :key="m" :label="m + '月'" :value="m" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="基本工资" prop="basicSalary">
                            <el-input-number v-model="paymentForm.basicSalary" :min="0" :precision="2" style="width: 100%" />
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="绩效工资">
                            <el-input-number v-model="paymentForm.performanceSalary" :min="0" :precision="2" style="width: 100%" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="岗位津贴">
                            <el-input-number v-model="paymentForm.positionAllowance" :min="0" :precision="2" style="width: 100%" />
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="交通补贴">
                            <el-input-number v-model="paymentForm.transportAllowance" :min="0" :precision="2" style="width: 100%" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="通讯补贴">
                            <el-input-number v-model="paymentForm.communicationAllowance" :min="0" :precision="2" style="width: 100%" />
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="餐补">
                            <el-input-number v-model="paymentForm.mealAllowance" :min="0" :precision="2" style="width: 100%" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="其他补贴">
                            <el-input-number v-model="paymentForm.otherAllowance" :min="0" :precision="2" style="width: 100%" />
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="加班费">
                            <el-input-number v-model="paymentForm.overtimePay" :min="0" :precision="2" style="width: 100%" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="社保个人">
                            <el-input-number v-model="paymentForm.socialInsurancePersonal" :min="0" :precision="2" style="width: 100%" />
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="公积金个人">
                            <el-input-number v-model="paymentForm.housingFundPersonal" :min="0" :precision="2" style="width: 100%" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="个人所得税">
                            <el-input-number v-model="paymentForm.incomeTax" :min="0" :precision="2" style="width: 100%" />
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="其他扣款">
                            <el-input-number v-model="paymentForm.otherDeduction" :min="0" :precision="2" style="width: 100%" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="备注">
                            <el-input v-model="paymentForm.remark" placeholder="请输入备注" />
                        </el-form-item>
                    </el-col>
                </el-row>
            </el-form>
            <template #footer>
                <el-button @click="paymentDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="handlePaymentSubmit">保存</el-button>
            </template>
        </el-dialog>

        <!-- 申请调整对话框 -->
        <el-dialog
            v-model="adjustmentDialogVisible"
            title="申请薪资调整"
            width="600px"
            @close="handleAdjustmentDialogClose"
        >
            <el-form :model="adjustmentForm" :rules="adjustmentRules" ref="adjustmentFormRef" label-width="120px">
                <el-form-item label="员工ID" prop="empId">
                    <el-input v-model="adjustmentForm.empId" placeholder="请输入员工ID" />
                </el-form-item>
                <el-form-item label="调整类型" prop="adjustmentType">
                    <el-select v-model="adjustmentForm.adjustmentType" placeholder="请选择调整类型" style="width: 100%">
                        <el-option label="晋升" :value="1" />
                        <el-option label="降职" :value="2" />
                        <el-option label="调薪" :value="3" />
                        <el-option label="转正" :value="4" />
                    </el-select>
                </el-form-item>
                <el-form-item label="调整前工资" prop="beforeSalary">
                    <el-input-number v-model="adjustmentForm.beforeSalary" :min="0" :precision="2" style="width: 100%" />
                </el-form-item>
                <el-form-item label="调整后工资" prop="afterSalary">
                    <el-input-number v-model="adjustmentForm.afterSalary" :min="0" :precision="2" style="width: 100%" />
                </el-form-item>
                <el-form-item label="生效日期" prop="effectiveDate">
                    <el-date-picker
                        v-model="adjustmentForm.effectiveDate"
                        type="date"
                        placeholder="选择生效日期"
                        value-format="YYYY-MM-DD"
                        style="width: 100%"
                    />
                </el-form-item>
                <el-form-item label="调整原因" prop="reason">
                    <el-input
                        v-model="adjustmentForm.reason"
                        type="textarea"
                        :rows="4"
                        placeholder="请输入调整原因"
                    />
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="adjustmentDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="handleAdjustmentSubmit">提交申请</el-button>
            </template>
        </el-dialog>

        <!-- 审批对话框 -->
        <el-dialog
            v-model="approveDialogVisible"
            title="审批薪资调整"
            width="500px"
        >
            <el-form :model="approveForm" label-width="100px">
                <el-form-item label="审批结果">
                    <el-radio-group v-model="approveForm.approvalStatus">
                        <el-radio :value="1">同意</el-radio>
                        <el-radio :value="2">拒绝</el-radio>
                    </el-radio-group>
                </el-form-item>
                <el-form-item label="审批意见">
                    <el-input
                        v-model="approveForm.approvalComment"
                        type="textarea"
                        :rows="3"
                        placeholder="请输入审批意见"
                    />
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="approveDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="handleApproveSubmit">确定</el-button>
            </template>
        </el-dialog>

        <!-- 薪资详情对话框 -->
        <el-dialog
            v-model="detailDialogVisible"
            title="薪资详情"
            width="700px"
        >
            <div class="salary-detail" v-if="currentPayment">
                <el-descriptions :column="2" border>
                    <el-descriptions-item label="员工ID">{{ currentPayment.empId }}</el-descriptions-item>
                    <el-descriptions-item label="期间">{{ currentPayment.year }}年{{ currentPayment.month }}月</el-descriptions-item>
                    <el-descriptions-item label="基本工资">¥{{ currentPayment.basicSalary?.toFixed(2) || '0.00' }}</el-descriptions-item>
                    <el-descriptions-item label="绩效工资">¥{{ currentPayment.performanceSalary?.toFixed(2) || '0.00' }}</el-descriptions-item>
                    <el-descriptions-item label="岗位津贴">¥{{ currentPayment.positionAllowance?.toFixed(2) || '0.00' }}</el-descriptions-item>
                    <el-descriptions-item label="交通补贴">¥{{ currentPayment.transportAllowance?.toFixed(2) || '0.00' }}</el-descriptions-item>
                    <el-descriptions-item label="通讯补贴">¥{{ currentPayment.communicationAllowance?.toFixed(2) || '0.00' }}</el-descriptions-item>
                    <el-descriptions-item label="餐补">¥{{ currentPayment.mealAllowance?.toFixed(2) || '0.00' }}</el-descriptions-item>
                    <el-descriptions-item label="其他补贴">¥{{ currentPayment.otherAllowance?.toFixed(2) || '0.00' }}</el-descriptions-item>
                    <el-descriptions-item label="加班费">¥{{ currentPayment.overtimePay?.toFixed(2) || '0.00' }}</el-descriptions-item>
                    <el-descriptions-item label="应发工资" :span="2">
                        <span style="font-size: 18px; font-weight: bold; color: #409EFF">
                            ¥{{ currentPayment.totalGrossSalary?.toFixed(2) || '0.00' }}
                        </span>
                    </el-descriptions-item>
                    <el-descriptions-item label="社保个人">¥{{ currentPayment.socialInsurancePersonal?.toFixed(2) || '0.00' }}</el-descriptions-item>
                    <el-descriptions-item label="公积金个人">¥{{ currentPayment.housingFundPersonal?.toFixed(2) || '0.00' }}</el-descriptions-item>
                    <el-descriptions-item label="个人所得税">¥{{ currentPayment.incomeTax?.toFixed(2) || '0.00' }}</el-descriptions-item>
                    <el-descriptions-item label="其他扣款">¥{{ currentPayment.otherDeduction?.toFixed(2) || '0.00' }}</el-descriptions-item>
                    <el-descriptions-item label="实发工资" :span="2">
                        <span style="font-size: 20px; font-weight: bold; color: #67C23A">
                            ¥{{ currentPayment.totalNetSalary?.toFixed(2) || '0.00' }}
                        </span>
                    </el-descriptions-item>
                    <el-descriptions-item label="发放状态">
                        <el-tag v-if="currentPayment.paymentStatus === 0" type="warning">未发放</el-tag>
                        <el-tag v-else type="success">已发放</el-tag>
                    </el-descriptions-item>
                    <el-descriptions-item label="发放时间">{{ currentPayment.paymentDate || '-' }}</el-descriptions-item>
                    <el-descriptions-item label="备注" :span="2">{{ currentPayment.remark || '-' }}</el-descriptions-item>
                </el-descriptions>
            </div>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Check, DocumentChecked, Download } from '@element-plus/icons-vue'
import { 
    getPaymentList, 
    addPayment, 
    updatePayment, 
    releasePayment,
    getAdjustmentList,
    applyAdjustment,
    approveAdjustment,
    getPendingApprovalList
} from '@/api/salary'

const activeTab = ref('payment')
const loading = ref(false)
const adjustmentLoading = ref(false)
const paymentDialogVisible = ref(false)
const adjustmentDialogVisible = ref(false)
const approveDialogVisible = ref(false)
const detailDialogVisible = ref(false)
const selectedPayments = ref([])
const pendingCount = ref(0)
const currentPayment = ref(null)

const paymentFormRef = ref(null)
const adjustmentFormRef = ref(null)

const years = ref([2023, 2024, 2025])
const months = ref([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])

const searchForm = reactive({
    empId: null,
    year: 2024,
    month: null
})

const pagination = reactive({
    page: 1,
    size: 10,
    total: 0
})

const tableData = ref([])

const paymentForm = reactive({
    paymentId: null,
    empId: null,
    year: 2024,
    month: null,
    basicSalary: 0,
    performanceSalary: 0,
    positionAllowance: 0,
    transportAllowance: 0,
    communicationAllowance: 0,
    mealAllowance: 0,
    otherAllowance: 0,
    overtimePay: 0,
    socialInsurancePersonal: 0,
    housingFundPersonal: 0,
    incomeTax: 0,
    otherDeduction: 0,
    remark: ''
})

const adjustmentSearchForm = reactive({
    empId: null,
    approvalStatus: null
})

const adjustmentPagination = reactive({
    page: 1,
    size: 10,
    total: 0
})

const adjustmentTableData = ref([])

const adjustmentForm = reactive({
    adjustmentId: null,
    empId: null,
    adjustmentType: null,
    beforeSalary: 0,
    afterSalary: 0,
    effectiveDate: '',
    reason: ''
})

const approveForm = reactive({
    adjustmentId: null,
    approverId: null,
    approvalStatus: 1,
    approvalComment: ''
})

const paymentRules = {
    empId: [
        { required: true, message: '请输入员工ID', trigger: 'blur' }
    ],
    year: [
        { required: true, message: '请选择年度', trigger: 'change' }
    ],
    month: [
        { required: true, message: '请选择月份', trigger: 'change' }
    ],
    basicSalary: [
        { required: true, message: '请输入基本工资', trigger: 'change' }
    ]
}

const adjustmentRules = {
    empId: [
        { required: true, message: '请输入员工ID', trigger: 'blur' }
    ],
    adjustmentType: [
        { required: true, message: '请选择调整类型', trigger: 'change' }
    ],
    beforeSalary: [
        { required: true, message: '请输入调整前工资', trigger: 'change' }
    ],
    afterSalary: [
        { required: true, message: '请输入调整后工资', trigger: 'change' }
    ],
    effectiveDate: [
        { required: true, message: '请选择生效日期', trigger: 'change' }
    ],
    reason: [
        { required: true, message: '请输入调整原因', trigger: 'blur' }
    ]
}

onMounted(() => {
    loadPaymentList()
    loadAdjustmentList()
})

const paymentDialogTitle = ref('新增薪资')

const getAdjustmentTypeText = (type) => {
    const types = {
        1: '晋升',
        2: '降职',
        3: '调薪',
        4: '转正'
    }
    return types[type] || '未知'
}

const handleTabChange = (tabName) => {
    if (tabName === 'payment') {
        loadPaymentList()
    } else if (tabName === 'adjustment') {
        loadAdjustmentList()
    }
}

const loadPaymentList = async () => {
    loading.value = true
    try {
        const params = {
            page: pagination.page,
            size: pagination.size,
            empId: searchForm.empId,
            year: searchForm.year,
            month: searchForm.month
        }
        const res = await getPaymentList(params)
        tableData.value = res.data.records
        pagination.total = res.data.total
    } catch (error) {
        console.error('获取薪资发放列表失败:', error)
        ElMessage.error('获取薪资发放列表失败')
    } finally {
        loading.value = false
    }
}

const handleSearch = () => {
    pagination.page = 1
    loadPaymentList()
}

const handleReset = () => {
    searchForm.empId = null
    searchForm.year = 2024
    searchForm.month = null
    pagination.page = 1
    loadPaymentList()
}

const handleSizeChange = (val) => {
    pagination.size = val
    pagination.page = 1
    loadPaymentList()
}

const handleCurrentChange = (val) => {
    pagination.page = val
    loadPaymentList()
}

const handleSelectionChange = (selection) => {
    selectedPayments.value = selection
}

const handleAddPayment = () => {
    paymentDialogTitle.value = '新增薪资'
    Object.assign(paymentForm, {
        paymentId: null,
        empId: null,
        year: 2024,
        month: null,
        basicSalary: 0,
        performanceSalary: 0,
        positionAllowance: 0,
        transportAllowance: 0,
        communicationAllowance: 0,
        mealAllowance: 0,
        otherAllowance: 0,
        overtimePay: 0,
        socialInsurancePersonal: 0,
        housingFundPersonal: 0,
        incomeTax: 0,
        otherDeduction: 0,
        remark: ''
    })
    paymentDialogVisible.value = true
}

const handleEditPayment = (row) => {
    paymentDialogTitle.value = '编辑薪资'
    Object.assign(paymentForm, row)
    paymentDialogVisible.value = true
}

const handleReleasePayment = (row) => {
    ElMessageBox.confirm(`确定要发放该薪资吗?`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(async () => {
        try {
            await releasePayment(row.paymentId)
            ElMessage.success('发放成功')
            loadPaymentList()
        } catch (error) {
            console.error('发放失败:', error)
            ElMessage.error('发放失败')
        }
    }).catch(() => {})
}

const handleBatchRelease = () => {
    if (selectedPayments.value.length === 0) {
        ElMessage.warning('请先选择要发放的薪资')
        return
    }
    ElMessageBox.confirm(`确定要批量发放选中的${selectedPayments.value.length}条薪资吗?`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(async () => {
        try {
            for (const payment of selectedPayments.value) {
                if (payment.paymentStatus === 0) {
                    await releasePayment(payment.paymentId)
                }
            }
            ElMessage.success('批量发放成功')
            loadPaymentList()
        } catch (error) {
            console.error('批量发放失败:', error)
            ElMessage.error('批量发放失败')
        }
    }).catch(() => {})
}

// 批量导出薪资单
const handleExportSalary = async () => {
    try {
        const { exportToExcel } = await import('@/utils/excel')

        // 字段映射配置
        const fieldMapping = {
            empId: '员工ID',
            year: '年度',
            month: '月份',
            basicSalary: '基本工资',
            performanceSalary: '绩效工资',
            bonus: '奖金',
            allowance: '补贴',
            totalGrossSalary: '应发工资',
            socialInsurancePersonal: '社保个人',
            housingFundPersonal: '公积金个人',
            incomeTax: '个人所得税',
            otherDeduction: '其他扣款',
            totalNetSalary: '实发工资',
            paymentStatus: '发放状态',
            paymentDate: '发放时间'
        }

        // 数据转换
        const exportData = tableData.value.map(row => ({
            ...row,
            basicSalary: row.basicSalary ? `¥${row.basicSalary.toFixed(2)}` : '¥0.00',
            performanceSalary: row.performanceSalary ? `¥${row.performanceSalary.toFixed(2)}` : '¥0.00',
            bonus: row.bonus ? `¥${row.bonus.toFixed(2)}` : '¥0.00',
            allowance: row.allowance ? `¥${row.allowance.toFixed(2)}` : '¥0.00',
            totalGrossSalary: row.totalGrossSalary ? `¥${row.totalGrossSalary.toFixed(2)}` : '¥0.00',
            socialInsurancePersonal: row.socialInsurancePersonal ? `¥${row.socialInsurancePersonal.toFixed(2)}` : '¥0.00',
            housingFundPersonal: row.housingFundPersonal ? `¥${row.housingFundPersonal.toFixed(2)}` : '¥0.00',
            incomeTax: row.incomeTax ? `¥${row.incomeTax.toFixed(2)}` : '¥0.00',
            otherDeduction: row.otherDeduction ? `¥${row.otherDeduction.toFixed(2)}` : '¥0.00',
            totalNetSalary: row.totalNetSalary ? `¥${row.totalNetSalary.toFixed(2)}` : '¥0.00',
            paymentStatus: row.paymentStatus === 0 ? '未发放' : '已发放'
        }))

        // 导出Excel
        const filename = exportToExcel(exportData, '薪资单', { fieldMapping })
        ElMessage.success(`导出成功: ${filename}`)
    } catch (error) {
        console.error('导出失败:', error)
        ElMessage.error('导出失败: ' + error.message)
    }
}

const handleViewDetail = (row) => {
    currentPayment.value = row
    detailDialogVisible.value = true
}

const handlePaymentDialogClose = () => {
    paymentFormRef.value?.resetFields()
}

const handlePaymentSubmit = () => {
    paymentFormRef.value.validate(async (valid) => {
        if (!valid) return

        try {
            if (paymentForm.paymentId) {
                await updatePayment(paymentForm)
                ElMessage.success('更新成功')
            } else {
                await addPayment(paymentForm)
                ElMessage.success('添加成功')
            }
            paymentDialogVisible.value = false
            loadPaymentList()
        } catch (error) {
            console.error('操作失败:', error)
            ElMessage.error('操作失败')
        }
    })
}

const loadAdjustmentList = async () => {
    adjustmentLoading.value = true
    try {
        const params = {
            page: adjustmentPagination.page,
            size: adjustmentPagination.size,
            empId: adjustmentSearchForm.empId,
            approvalStatus: adjustmentSearchForm.approvalStatus
        }
        const res = await getAdjustmentList(params)
        adjustmentTableData.value = res.data.records
        adjustmentPagination.total = res.data.total
        
        pendingCount.value = adjustmentTableData.value.filter(item => item.approvalStatus === 0).length
    } catch (error) {
        console.error('获取薪资调整列表失败:', error)
        ElMessage.error('获取薪资调整列表失败')
    } finally {
        adjustmentLoading.value = false
    }
}

const handleAdjustmentSearch = () => {
    adjustmentPagination.page = 1
    loadAdjustmentList()
}

const handleAdjustmentReset = () => {
    adjustmentSearchForm.empId = null
    adjustmentSearchForm.approvalStatus = null
    adjustmentPagination.page = 1
    loadAdjustmentList()
}

const handleAdjustmentSizeChange = (val) => {
    adjustmentPagination.size = val
    adjustmentPagination.page = 1
    loadAdjustmentList()
}

const handleAdjustmentCurrentChange = (val) => {
    adjustmentPagination.page = val
    loadAdjustmentList()
}

const handleApplyAdjustment = () => {
    adjustmentDialogVisible.value = true
}

const handleAdjustmentDialogClose = () => {
    adjustmentFormRef.value?.resetFields()
    Object.assign(adjustmentForm, {
        adjustmentId: null,
        empId: null,
        adjustmentType: null,
        beforeSalary: 0,
        afterSalary: 0,
        effectiveDate: '',
        reason: ''
    })
}

const handleAdjustmentSubmit = () => {
    adjustmentFormRef.value.validate(async (valid) => {
        if (!valid) return

        try {
            await applyAdjustment(adjustmentForm)
            ElMessage.success('申请成功')
            adjustmentDialogVisible.value = false
            loadAdjustmentList()
        } catch (error) {
            console.error('申请失败:', error)
            ElMessage.error('申请失败')
        }
    })
}

const handleViewAdjustment = (row) => {
    ElMessageBox.alert(`
        员工ID: ${row.empId}
        调整类型: ${getAdjustmentTypeText(row.adjustmentType)}
        调整前工资: ¥${row.beforeSalary?.toFixed(2)}
        调整后工资: ¥${row.afterSalary?.toFixed(2)}
        调整幅度: ${row.adjustmentRate}%
        生效日期: ${row.effectiveDate}
        调整原因: ${row.reason}
        审批状态: ${row.approvalStatus === 0 ? '待审批' : row.approvalStatus === 1 ? '已同意' : '已拒绝'}
        ${row.approvalComment ? '审批意见: ' + row.approvalComment : ''}
    `, '薪资调整详情')
}

const handleApproveAdjustment = (row) => {
    approveForm.adjustmentId = row.adjustmentId
    approveForm.approverId = JSON.parse(localStorage.getItem('userInfo')).userId
    approveForm.approvalStatus = 1
    approveForm.approvalComment = ''
    approveDialogVisible.value = true
}

const handleApproveSubmit = async () => {
    try {
        await approveAdjustment(approveForm)
        ElMessage.success('审批成功')
        approveDialogVisible.value = false
        loadAdjustmentList()
    } catch (error) {
        console.error('审批失败:', error)
        ElMessage.error('审批失败')
    }
}

const handlePendingApproval = () => {
    adjustmentSearchForm.approvalStatus = 0
    handleAdjustmentSearch()
}
</script>

<style scoped>
.salary-management {
    padding: 20px;
}

h2 {
    margin-bottom: 20px;
    color: #333;
}

.salary-detail {
    padding: 10px;
}
</style>
