<template>
    <div class="performance-management">
        <h2>绩效管理</h2>

        <!-- 功能标签页 -->
        <el-tabs v-model="activeTab" @tab-change="handleTabChange">
            <el-tab-pane label="绩效目标管理" name="goal">
                <div class="goal-management">
                    <!-- 操作按钮 -->
                    <el-card style="margin-bottom: 20px">
                        <el-button type="primary" @click="handleAddGoal">
                            <el-icon><Plus /></el-icon>
                            新增目标
                        </el-button>
                        <el-button type="success" @click="handleBatchComplete">
                            <el-icon><Check /></el-icon>
                            批量完成
                        </el-button>
                        <el-button type="success" @click="handleExportPerformance">
                            <el-icon><Download /></el-icon>
                            导出报告
                        </el-button>
                    </el-card>

                    <!-- 查询表单 -->
                    <el-card style="margin-bottom: 20px">
                        <el-form :inline="true" :model="searchForm">
                            <el-form-item label="员工ID">
                                <el-input v-model="searchForm.empId" placeholder="请输入员工ID" clearable style="width: 120px" />
                            </el-form-item>
                            <el-form-item label="评估年度">
                                <el-select v-model="searchForm.year" placeholder="请选择" clearable style="width: 120px">
                                    <el-option v-for="y in years" :key="y" :label="y" :value="y" />
                                </el-select>
                            </el-form-item>
                            <el-form-item label="评估周期">
                                <el-select v-model="searchForm.periodType" placeholder="请选择" clearable style="width: 120px">
                                    <el-option label="年度" :value="1" />
                                    <el-option label="季度" :value="2" />
                                    <el-option label="月度" :value="3" />
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
                        <el-table :data="goalTableData" border style="width: 100%" v-loading="loading" @selection-change="handleSelectionChange">
                            <el-table-column type="selection" width="55" />
                            <el-table-column type="index" label="序号" width="60" />
                            <el-table-column prop="empId" label="员工ID" width="80" />
                            <el-table-column prop="year" label="评估年度" width="100" />
                            <el-table-column prop="periodType" label="评估周期" width="100">
                                <template #default="{ row }">
                                    {{ getPeriodTypeText(row.periodType) }}
                                </template>
                            </el-table-column>
                            <el-table-column prop="goalDescription" label="目标描述" width="250" show-overflow-tooltip />
                            <el-table-column prop="weight" label="权重(%)" width="100" />
                            <el-table-column prop="completionStandard" label="完成标准" width="250" show-overflow-tooltip />
                            <el-table-column prop="goalStatus" label="目标状态" width="100">
                                <template #default="{ row }">
                                    <el-tag v-if="row.goalStatus === 0" type="info">草稿</el-tag>
                                    <el-tag v-else-if="row.goalStatus === 1" type="warning">进行中</el-tag>
                                    <el-tag v-else type="success">已完成</el-tag>
                                </template>
                            </el-table-column>
                            <el-table-column prop="createTime" label="创建时间" width="120" />
                            <el-table-column label="操作" width="200" fixed="right">
                                <template #default="{ row }">
                                    <el-button type="primary" size="small" @click="handleEditGoal(row)">编辑</el-button>
                                    <el-button type="success" size="small" @click="handleCompleteGoal(row)" v-if="row.goalStatus !== 2">完成</el-button>
                                    <el-button type="danger" size="small" @click="handleDeleteGoal(row)">删除</el-button>
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

            <el-tab-pane label="绩效评估" name="evaluation">
                <div class="evaluation-management">
                    <!-- 操作按钮 -->
                    <el-card style="margin-bottom: 20px">
                        <div style="display: flex; gap: 10px; align-items: center;">
                            <el-button type="primary" @click="handleSelfEvaluate">
                                <el-icon><Edit /></el-icon>
                                我要自评
                            </el-button>
                            <el-button type="success" @click="handleSupervisorEvaluate">
                                <el-icon><DocumentChecked /></el-icon>
                                上级评价
                            </el-button>
                            <el-button type="warning" @click="handleInterview">
                                <el-icon><ChatLineSquare /></el-icon>
                                绩效面谈
                            </el-button>
                            <el-divider direction="vertical" />
                            <span style="font-size: 14px; color: #666;">
                                待自评: <el-tag type="warning">{{ pendingSelfCount }}</el-tag>
                                待评价: <el-tag type="danger">{{ pendingSupervisorCount }}</el-tag>
                            </span>
                        </div>
                    </el-card>

                    <!-- 查询表单 -->
                    <el-card style="margin-bottom: 20px">
                        <el-form :inline="true" :model="evaluationSearchForm">
                            <el-form-item label="员工ID">
                                <el-input v-model="evaluationSearchForm.empId" placeholder="请输入员工ID" clearable style="width: 120px" />
                            </el-form-item>
                            <el-form-item label="评估年度">
                                <el-select v-model="evaluationSearchForm.year" placeholder="请选择" clearable style="width: 120px">
                                    <el-option v-for="y in years" :key="y" :label="y" :value="y" />
                                </el-select>
                            </el-form-item>
                            <el-form-item label="评估周期">
                                <el-select v-model="evaluationSearchForm.periodType" placeholder="请选择" clearable style="width: 120px">
                                    <el-option label="年度" :value="1" />
                                    <el-option label="季度" :value="2" />
                                    <el-option label="月度" :value="3" />
                                </el-select>
                            </el-form-item>
                            <el-form-item label="评估状态">
                                <el-select v-model="evaluationSearchForm.evaluationStatus" placeholder="请选择" clearable style="width: 120px">
                                    <el-option label="未评估" :value="0" />
                                    <el-option label="已自评" :value="1" />
                                    <el-option label="已评价" :value="2" />
                                    <el-option label="已完成" :value="3" />
                                </el-select>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" @click="handleEvaluationSearch">查询</el-button>
                                <el-button @click="handleEvaluationReset">重置</el-button>
                            </el-form-item>
                        </el-form>
                    </el-card>

                    <!-- 数据表格 -->
                    <el-card>
                        <el-table :data="evaluationTableData" border style="width: 100%" v-loading="evaluationLoading">
                            <el-table-column type="index" label="序号" width="60" />
                            <el-table-column prop="empId" label="员工ID" width="80" />
                            <el-table-column prop="year" label="评估年度" width="100" />
                            <el-table-column prop="periodType" label="评估周期" width="100">
                                <template #default="{ row }">
                                    {{ getPeriodTypeText(row.periodType) }}
                                </template>
                            </el-table-column>
                            <el-table-column prop="selfScore" label="自评分" width="100">
                                <template #default="{ row }">
                                    <span v-if="row.selfScore !== null">{{ row.selfScore }}分</span>
                                    <span v-else style="color: #999">-</span>
                                </template>
                            </el-table-column>
                            <el-table-column prop="supervisorScore" label="上级评分" width="100">
                                <template #default="{ row }">
                                    <span v-if="row.supervisorScore !== null">{{ row.supervisorScore }}分</span>
                                    <span v-else style="color: #999">-</span>
                                </template>
                            </el-table-column>
                            <el-table-column prop="finalScore" label="综合评分" width="100">
                                <template #default="{ row }">
                                    <span v-if="row.finalScore !== null" :style="{ color: getScoreColor(row.finalScore), fontWeight: 'bold' }">
                                        {{ row.finalScore }}分
                                    </span>
                                    <span v-else style="color: #999">-</span>
                                </template>
                            </el-table-column>
                            <el-table-column prop="performanceLevel" label="绩效等级" width="100">
                                <template #default="{ row }">
                                    <el-tag v-if="row.performanceLevel" :type="getLevelType(row.performanceLevel)">
                                        {{ row.performanceLevel }}级
                                    </el-tag>
                                    <span v-else style="color: #999">-</span>
                                </template>
                            </el-table-column>
                            <el-table-column prop="evaluationStatus" label="评估状态" width="100">
                                <template #default="{ row }">
                                    <el-tag v-if="row.evaluationStatus === 0" type="info">未评估</el-tag>
                                    <el-tag v-else-if="row.evaluationStatus === 1" type="warning">已自评</el-tag>
                                    <el-tag v-else-if="row.evaluationStatus === 2" type="primary">已评价</el-tag>
                                    <el-tag v-else type="success">已完成</el-tag>
                                </template>
                            </el-table-column>
                            <el-table-column label="操作" width="200" fixed="right">
                                <template #default="{ row }">
                                    <el-button type="primary" size="small" @click="handleViewEvaluation(row)">查看详情</el-button>
                                    <el-button 
                                        v-if="row.evaluationStatus === 0" 
                                        type="success" 
                                        size="small" 
                                        @click="handleDoSelfEvaluate(row)"
                                    >
                                        自评
                                    </el-button>
                                    <el-button 
                                        v-if="row.evaluationStatus === 1" 
                                        type="warning" 
                                        size="small" 
                                        @click="handleDoSupervisorEvaluate(row)"
                                    >
                                        评价
                                    </el-button>
                                </template>
                            </el-table-column>
                        </el-table>

                        <!-- 分页 -->
                        <el-pagination
                            v-model:current-page="evaluationPagination.page"
                            v-model:page-size="evaluationPagination.size"
                            :page-sizes="[10, 20, 50, 100]"
                            :total="evaluationPagination.total"
                            layout="total, sizes, prev, pager, next, jumper"
                            @size-change="handleEvaluationSizeChange"
                            @current-change="handleEvaluationCurrentChange"
                            style="margin-top: 20px; justify-content: flex-end"
                        />
                    </el-card>
                </div>
            </el-tab-pane>
        </el-tabs>

        <!-- 新增/编辑目标对话框 -->
        <el-dialog
            v-model="goalDialogVisible"
            :title="goalDialogTitle"
            width="600px"
            @close="handleGoalDialogClose"
        >
            <el-form :model="goalForm" :rules="goalRules" ref="goalFormRef" label-width="100px">
                <el-form-item label="员工ID" prop="empId">
                    <el-input v-model="goalForm.empId" placeholder="请输入员工ID" />
                </el-form-item>
                <el-form-item label="评估年度" prop="year">
                    <el-select v-model="goalForm.year" placeholder="请选择评估年度" style="width: 100%">
                        <el-option v-for="y in years" :key="y" :label="y" :value="y" />
                    </el-select>
                </el-form-item>
                <el-form-item label="评估周期" prop="periodType">
                    <el-select v-model="goalForm.periodType" placeholder="请选择评估周期" style="width: 100%">
                        <el-option label="年度" :value="1" />
                        <el-option label="季度" :value="2" />
                        <el-option label="月度" :value="3" />
                    </el-select>
                </el-form-item>
                <el-form-item label="目标描述" prop="goalDescription">
                    <el-input
                        v-model="goalForm.goalDescription"
                        type="textarea"
                        :rows="3"
                        placeholder="请输入目标描述"
                    />
                </el-form-item>
                <el-form-item label="权重(%)" prop="weight">
                    <el-input-number v-model="goalForm.weight" :min="0" :max="100" style="width: 100%" />
                </el-form-item>
                <el-form-item label="完成标准" prop="completionStandard">
                    <el-input
                        v-model="goalForm.completionStandard"
                        type="textarea"
                        :rows="3"
                        placeholder="请输入完成标准"
                    />
                </el-form-item>
                <el-form-item label="目标状态" prop="goalStatus">
                    <el-radio-group v-model="goalForm.goalStatus">
                        <el-radio :value="0">草稿</el-radio>
                        <el-radio :value="1">进行中</el-radio>
                        <el-radio :value="2">已完成</el-radio>
                    </el-radio-group>
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="goalDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="handleGoalSubmit">确定</el-button>
            </template>
        </el-dialog>

        <!-- 自评对话框 -->
        <el-dialog
            v-model="selfEvaluateDialogVisible"
            title="绩效自评"
            width="700px"
            @close="handleSelfEvaluateDialogClose"
        >
            <el-form :model="selfEvaluateForm" :rules="selfEvaluateRules" ref="selfEvaluateFormRef" label-width="100px">
                <el-form-item label="员工ID" prop="empId">
                    <el-input v-model="selfEvaluateForm.empId" placeholder="请输入员工ID" />
                </el-form-item>
                <el-form-item label="评估年度" prop="year">
                    <el-select v-model="selfEvaluateForm.year" placeholder="请选择评估年度" style="width: 100%">
                        <el-option v-for="y in years" :key="y" :label="y" :value="y" />
                    </el-select>
                </el-form-item>
                <el-form-item label="评估周期" prop="periodType">
                    <el-select v-model="selfEvaluateForm.periodType" placeholder="请选择评估周期" style="width: 100%">
                        <el-option label="年度" :value="1" />
                        <el-option label="季度" :value="2" />
                        <el-option label="月度" :value="3" />
                    </el-select>
                </el-form-item>
                <el-form-item label="自评分" prop="selfScore">
                    <el-input-number v-model="selfEvaluateForm.selfScore" :min="0" :max="100" :precision="2" style="width: 100%" />
                    <span style="margin-left: 10px; color: #666">满分100分</span>
                </el-form-item>
                <el-form-item label="自评说明" prop="selfComment">
                    <el-input
                        v-model="selfEvaluateForm.selfComment"
                        type="textarea"
                        :rows="5"
                        placeholder="请详细说明自评理由,包括完成情况、遇到的困难、改进措施等"
                    />
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="selfEvaluateDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="handleSelfEvaluateSubmit">提交自评</el-button>
            </template>
        </el-dialog>

        <!-- 上级评价对话框 -->
        <el-dialog
            v-model="supervisorEvaluateDialogVisible"
            title="上级绩效评价"
            width="700px"
            @close="handleSupervisorEvaluateDialogClose"
        >
            <el-form :model="supervisorEvaluateForm" :rules="supervisorEvaluateRules" ref="supervisorEvaluateFormRef" label-width="100px">
                <el-form-item label="员工ID" prop="empId">
                    <el-input v-model="supervisorEvaluateForm.empId" placeholder="请输入员工ID" />
                </el-form-item>
                <el-form-item label="评估年度" prop="year">
                    <el-select v-model="supervisorEvaluateForm.year" placeholder="请选择评估年度" style="width: 100%">
                        <el-option v-for="y in years" :key="y" :label="y" :value="y" />
                    </el-select>
                </el-form-item>
                <el-form-item label="评估周期" prop="periodType">
                    <el-select v-model="supervisorEvaluateForm.periodType" placeholder="请选择评估周期" style="width: 100%">
                        <el-option label="年度" :value="1" />
                        <el-option label="季度" :value="2" />
                        <el-option label="月度" :value="3" />
                    </el-select>
                </el-form-item>
                <el-form-item label="上级评分" prop="supervisorScore">
                    <el-input-number v-model="supervisorEvaluateForm.supervisorScore" :min="0" :max="100" :precision="2" style="width: 100%" />
                    <span style="margin-left: 10px; color: #666">满分100分</span>
                </el-form-item>
                <el-form-item label="评价意见" prop="supervisorComment">
                    <el-input
                        v-model="supervisorEvaluateForm.supervisorComment"
                        type="textarea"
                        :rows="5"
                        placeholder="请详细说明评价意见,包括工作表现、优点、不足、改进建议等"
                    />
                </el-form-item>
                <el-form-item label="改进计划" prop="improvementPlan">
                    <el-input
                        v-model="supervisorEvaluateForm.improvementPlan"
                        type="textarea"
                        :rows="3"
                        placeholder="请填写改进计划"
                    />
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="supervisorEvaluateDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="handleSupervisorEvaluateSubmit">提交评价</el-button>
            </template>
        </el-dialog>

        <!-- 面谈记录对话框 -->
        <el-dialog
            v-model="interviewDialogVisible"
            title="绩效面谈记录"
            width="600px"
            @close="handleInterviewDialogClose"
        >
            <el-form :model="interviewForm" ref="interviewFormRef" label-width="100px">
                <el-form-item label="评估ID" prop="evaluationId">
                    <el-input v-model="interviewForm.evaluationId" placeholder="请输入评估ID" />
                </el-form-item>
                <el-form-item label="面谈时间" prop="interviewDate">
                    <el-date-picker
                        v-model="interviewForm.interviewDate"
                        type="date"
                        placeholder="选择面谈时间"
                        value-format="YYYY-MM-DD"
                        style="width: 100%"
                    />
                </el-form-item>
                <el-form-item label="面谈记录" prop="interviewRecord">
                    <el-input
                        v-model="interviewForm.interviewRecord"
                        type="textarea"
                        :rows="8"
                        placeholder="请详细记录面谈内容,包括员工反馈、达成共识、后续行动计划等"
                    />
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="interviewDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="handleInterviewSubmit">保存记录</el-button>
            </template>
        </el-dialog>

        <!-- 评估详情对话框 -->
        <el-dialog
            v-model="detailDialogVisible"
            title="绩效评估详情"
            width="800px"
        >
            <div class="evaluation-detail" v-if="currentEvaluation">
                <el-descriptions :column="2" border>
                    <el-descriptions-item label="员工ID">{{ currentEvaluation.empId }}</el-descriptions-item>
                    <el-descriptions-item label="评估年度">{{ currentEvaluation.year }}</el-descriptions-item>
                    <el-descriptions-item label="评估周期">{{ getPeriodTypeText(currentEvaluation.periodType) }}</el-descriptions-item>
                    <el-descriptions-item label="评估状态">
                        <el-tag v-if="currentEvaluation.evaluationStatus === 0" type="info">未评估</el-tag>
                        <el-tag v-else-if="currentEvaluation.evaluationStatus === 1" type="warning">已自评</el-tag>
                        <el-tag v-else-if="currentEvaluation.evaluationStatus === 2" type="primary">已评价</el-tag>
                        <el-tag v-else type="success">已完成</el-tag>
                    </el-descriptions-item>
                    <el-descriptions-item label="自评分" :span="2">
                        <span v-if="currentEvaluation.selfScore !== null" style="font-size: 18px; font-weight: bold; color: #409EFF">
                            {{ currentEvaluation.selfScore }}分
                        </span>
                        <span v-else style="color: #999">未自评</span>
                    </el-descriptions-item>
                    <el-descriptions-item label="自评说明" :span="2">
                        {{ currentEvaluation.selfComment || '-' }}
                    </el-descriptions-item>
                    <el-descriptions-item label="上级评分" :span="2">
                        <span v-if="currentEvaluation.supervisorScore !== null" style="font-size: 18px; font-weight: bold; color: #67C23A">
                            {{ currentEvaluation.supervisorScore }}分
                        </span>
                        <span v-else style="color: #999">未评价</span>
                    </el-descriptions-item>
                    <el-descriptions-item label="上级评价" :span="2">
                        {{ currentEvaluation.supervisorComment || '-' }}
                    </el-descriptions-item>
                    <el-descriptions-item label="综合评分" :span="2">
                        <span v-if="currentEvaluation.finalScore !== null" :style="{ fontSize: '20px', fontWeight: 'bold', color: getScoreColor(currentEvaluation.finalScore) }">
                            {{ currentEvaluation.finalScore }}分
                        </span>
                        <span v-else style="color: #999">-</span>
                    </el-descriptions-item>
                    <el-descriptions-item label="绩效等级" :span="2">
                        <el-tag v-if="currentEvaluation.performanceLevel" :type="getLevelType(currentEvaluation.performanceLevel)" size="large">
                            {{ currentEvaluation.performanceLevel }}级
                        </el-tag>
                        <span v-else style="color: #999">-</span>
                    </el-descriptions-item>
                    <el-descriptions-item label="改进计划" :span="2">
                        {{ currentEvaluation.improvementPlan || '-' }}
                    </el-descriptions-item>
                    <el-descriptions-item label="面谈时间">
                        {{ currentEvaluation.interviewDate || '-' }}
                    </el-descriptions-item>
                    <el-descriptions-item label="面谈记录" :span="2">
                        {{ currentEvaluation.interviewRecord || '-' }}
                    </el-descriptions-item>
                </el-descriptions>
            </div>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Check, Edit, DocumentChecked, ChatLineSquare, Download } from '@element-plus/icons-vue'
import { 
    getGoalList, 
    addGoal, 
    updateGoal, 
    deleteGoal,
    getEvaluationList,
    selfEvaluate,
    supervisorEvaluate,
    updateInterviewRecord
} from '@/api/performance'

const activeTab = ref('goal')
const loading = ref(false)
const evaluationLoading = ref(false)
const goalDialogVisible = ref(false)
const selfEvaluateDialogVisible = ref(false)
const supervisorEvaluateDialogVisible = ref(false)
const interviewDialogVisible = ref(false)
const detailDialogVisible = ref(false)
const selectedGoals = ref([])
const pendingSelfCount = ref(0)
const pendingSupervisorCount = ref(0)
const currentEvaluation = ref(null)

const goalFormRef = ref(null)
const selfEvaluateFormRef = ref(null)
const supervisorEvaluateFormRef = ref(null)
const interviewFormRef = ref(null)

const years = ref([2022, 2023, 2024, 2025])

const searchForm = reactive({
    empId: null,
    year: 2024,
    periodType: null
})

const pagination = reactive({
    page: 1,
    size: 10,
    total: 0
})

const goalTableData = ref([])

const goalForm = reactive({
    goalId: null,
    empId: null,
    year: 2024,
    periodType: 1,
    goalDescription: '',
    weight: 0,
    completionStandard: '',
    goalStatus: 0
})

const evaluationSearchForm = reactive({
    empId: null,
    year: 2024,
    periodType: null,
    evaluationStatus: null
})

const evaluationPagination = reactive({
    page: 1,
    size: 10,
    total: 0
})

const evaluationTableData = ref([])

const selfEvaluateForm = reactive({
    empId: null,
    year: 2024,
    periodType: 1,
    selfScore: 0,
    selfComment: ''
})

const supervisorEvaluateForm = reactive({
    evaluationId: null,
    empId: null,
    year: 2024,
    periodType: 1,
    supervisorScore: 0,
    supervisorComment: '',
    improvementPlan: ''
})

const interviewForm = reactive({
    evaluationId: null,
    interviewDate: '',
    interviewRecord: ''
})

const goalRules = {
    empId: [
        { required: true, message: '请输入员工ID', trigger: 'blur' }
    ],
    year: [
        { required: true, message: '请选择评估年度', trigger: 'change' }
    ],
    periodType: [
        { required: true, message: '请选择评估周期', trigger: 'change' }
    ],
    goalDescription: [
        { required: true, message: '请输入目标描述', trigger: 'blur' }
    ],
    weight: [
        { required: true, message: '请输入权重', trigger: 'change' }
    ]
}

const selfEvaluateRules = {
    empId: [
        { required: true, message: '请输入员工ID', trigger: 'blur' }
    ],
    year: [
        { required: true, message: '请选择评估年度', trigger: 'change' }
    ],
    periodType: [
        { required: true, message: '请选择评估周期', trigger: 'change' }
    ],
    selfScore: [
        { required: true, message: '请输入自评分', trigger: 'change' }
    ],
    selfComment: [
        { required: true, message: '请输入自评说明', trigger: 'blur' }
    ]
}

const supervisorEvaluateRules = {
    empId: [
        { required: true, message: '请输入员工ID', trigger: 'blur' }
    ],
    year: [
        { required: true, message: '请选择评估年度', trigger: 'change' }
    ],
    periodType: [
        { required: true, message: '请选择评估周期', trigger: 'change' }
    ],
    supervisorScore: [
        { required: true, message: '请输入上级评分', trigger: 'change' }
    ],
    supervisorComment: [
        { required: true, message: '请输入评价意见', trigger: 'blur' }
    ]
}

onMounted(() => {
    loadGoalList()
    loadEvaluationList()
})

const goalDialogTitle = ref('新增目标')

const getPeriodTypeText = (type) => {
    const types = {
        1: '年度',
        2: '季度',
        3: '月度'
    }
    return types[type] || '未知'
}

const getScoreColor = (score) => {
    if (score >= 90) return '#67C23A'
    if (score >= 80) return '#409EFF'
    if (score >= 70) return '#E6A23C'
    if (score >= 60) return '#F56C6C'
    return '#909399'
}

const getLevelType = (level) => {
    const types = {
        'S': 'success',
        'A': 'primary',
        'B': 'warning',
        'C': 'danger',
        'D': 'info'
    }
    return types[level] || ''
}

const handleTabChange = (tabName) => {
    if (tabName === 'goal') {
        loadGoalList()
    } else if (tabName === 'evaluation') {
        loadEvaluationList()
    }
}

const loadGoalList = async () => {
    loading.value = true
    try {
        const params = {
            page: pagination.page,
            size: pagination.size,
            empId: searchForm.empId,
            year: searchForm.year,
            periodType: searchForm.periodType
        }
        const res = await getGoalList(params)
        goalTableData.value = res.data.records
        pagination.total = res.data.total
    } catch (error) {
        console.error('获取绩效目标列表失败:', error)
        ElMessage.error('获取绩效目标列表失败')
    } finally {
        loading.value = false
    }
}

const handleSearch = () => {
    pagination.page = 1
    loadGoalList()
}

const handleReset = () => {
    searchForm.empId = null
    searchForm.year = 2024
    searchForm.periodType = null
    pagination.page = 1
    loadGoalList()
}

const handleSizeChange = (val) => {
    pagination.size = val
    pagination.page = 1
    loadGoalList()
}

const handleCurrentChange = (val) => {
    pagination.page = val
    loadGoalList()
}

const handleSelectionChange = (selection) => {
    selectedGoals.value = selection
}

const handleAddGoal = () => {
    goalDialogTitle.value = '新增目标'
    Object.assign(goalForm, {
        goalId: null,
        empId: null,
        year: 2024,
        periodType: 1,
        goalDescription: '',
        weight: 0,
        completionStandard: '',
        goalStatus: 0
    })
    goalDialogVisible.value = true
}

const handleEditGoal = (row) => {
    goalDialogTitle.value = '编辑目标'
    Object.assign(goalForm, row)
    goalDialogVisible.value = true
}

const handleCompleteGoal = (row) => {
    ElMessageBox.confirm(`确定要完成该目标吗?`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(async () => {
        try {
            const updatedGoal = { ...row, goalStatus: 2 }
            await updateGoal(updatedGoal)
            ElMessage.success('操作成功')
            loadGoalList()
        } catch (error) {
            console.error('操作失败:', error)
            ElMessage.error('操作失败')
        }
    }).catch(() => {})
}

const handleDeleteGoal = (row) => {
    ElMessageBox.confirm(`确定要删除该目标吗?`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(async () => {
        try {
            await deleteGoal(row.goalId)
            ElMessage.success('删除成功')
            loadGoalList()
        } catch (error) {
            console.error('删除失败:', error)
            ElMessage.error('删除失败')
        }
    }).catch(() => {})
}

const handleBatchComplete = () => {
    if (selectedGoals.value.length === 0) {
        ElMessage.warning('请先选择要完成的目标')
        return
    }
    ElMessageBox.confirm(`确定要批量完成选中的${selectedGoals.value.length}个目标吗?`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(async () => {
        try {
            for (const goal of selectedGoals.value) {
                await updateGoal({ ...goal, goalStatus: 2 })
            }
            ElMessage.success('操作成功')
            loadGoalList()
        } catch (error) {
            console.error('操作失败:', error)
            ElMessage.error('操作失败')
        }
    }).catch(() => {})
}

// 导出绩效报告
const handleExportPerformance = async () => {
    try {
        const { exportToExcel } = await import('@/utils/excel')

        // 字段映射配置
        const fieldMapping = {
            empId: '员工ID',
            year: '评估年度',
            periodType: '评估周期',
            goalName: '目标名称',
            goalWeight: '目标权重',
            targetValue: '目标值',
            actualValue: '实际值',
            completionRate: '完成率',
            selfScore: '自评得分',
            managerScore: '上级评分',
            finalScore: '最终得分',
            goalStatus: '目标状态',
            createTime: '创建时间'
        }

        // 数据转换
        const exportData = goalTableData.value.map(row => ({
            ...row,
            periodType: row.periodType === 1 ? '年度' : row.periodType === 2 ? '季度' : '月度',
            goalWeight: row.goalWeight ? `${row.goalWeight}%` : '0%',
            completionRate: row.completionRate ? `${row.completionRate.toFixed(2)}%` : '0%',
            goalStatus: row.goalStatus === 1 ? '进行中' : row.goalStatus === 2 ? '已完成' : '未开始'
        }))

        // 导出Excel
        const filename = exportToExcel(exportData, '绩效评估报告', { fieldMapping })
        ElMessage.success(`导出成功: ${filename}`)
    } catch (error) {
        console.error('导出失败:', error)
        ElMessage.error('导出失败: ' + error.message)
    }
}

const handleGoalDialogClose = () => {
    goalFormRef.value?.resetFields()
}

const handleGoalSubmit = () => {
    goalFormRef.value.validate(async (valid) => {
        if (!valid) return

        try {
            if (goalForm.goalId) {
                await updateGoal(goalForm)
                ElMessage.success('更新成功')
            } else {
                await addGoal(goalForm)
                ElMessage.success('添加成功')
            }
            goalDialogVisible.value = false
            loadGoalList()
        } catch (error) {
            console.error('操作失败:', error)
            ElMessage.error('操作失败')
        }
    })
}

const loadEvaluationList = async () => {
    evaluationLoading.value = true
    try {
        const params = {
            page: evaluationPagination.page,
            size: evaluationPagination.size,
            empId: evaluationSearchForm.empId,
            year: evaluationSearchForm.year,
            periodType: evaluationSearchForm.periodType
        }
        const res = await getEvaluationList(params)
        evaluationTableData.value = res.data.records
        evaluationPagination.total = res.data.total
        
        // 统计待自评和待评价数量
        pendingSelfCount.value = evaluationTableData.value.filter(item => item.evaluationStatus === 0).length
        pendingSupervisorCount.value = evaluationTableData.value.filter(item => item.evaluationStatus === 1).length
    } catch (error) {
        console.error('获取绩效评估列表失败:', error)
        ElMessage.error('获取绩效评估列表失败')
    } finally {
        evaluationLoading.value = false
    }
}

const handleEvaluationSearch = () => {
    evaluationPagination.page = 1
    loadEvaluationList()
}

const handleEvaluationReset = () => {
    evaluationSearchForm.empId = null
    evaluationSearchForm.year = 2024
    evaluationSearchForm.periodType = null
    evaluationSearchForm.evaluationStatus = null
    evaluationPagination.page = 1
    loadEvaluationList()
}

const handleEvaluationSizeChange = (val) => {
    evaluationPagination.size = val
    evaluationPagination.page = 1
    loadEvaluationList()
}

const handleEvaluationCurrentChange = (val) => {
    evaluationPagination.page = val
    loadEvaluationList()
}

const handleSelfEvaluate = () => {
    selfEvaluateDialogVisible.value = true
    selfEvaluateForm.empId = JSON.parse(localStorage.getItem('userInfo')).userId
}

const handleDoSelfEvaluate = (row) => {
    selfEvaluateDialogVisible.value = true
    selfEvaluateForm.empId = row.empId
    selfEvaluateForm.year = row.year
    selfEvaluateForm.periodType = row.periodType
}

const handleSelfEvaluateDialogClose = () => {
    selfEvaluateFormRef.value?.resetFields()
    Object.assign(selfEvaluateForm, {
        empId: null,
        year: 2024,
        periodType: 1,
        selfScore: 0,
        selfComment: ''
    })
}

const handleSelfEvaluateSubmit = () => {
    selfEvaluateFormRef.value.validate(async (valid) => {
        if (!valid) return

        try {
            await selfEvaluate(selfEvaluateForm)
            ElMessage.success('自评成功')
            selfEvaluateDialogVisible.value = false
            loadEvaluationList()
        } catch (error) {
            console.error('自评失败:', error)
            ElMessage.error('自评失败')
        }
    })
}

const handleSupervisorEvaluate = () => {
    supervisorEvaluateDialogVisible.value = true
}

const handleDoSupervisorEvaluate = (row) => {
    supervisorEvaluateDialogVisible.value = true
    supervisorEvaluateForm.evaluationId = row.evaluationId
    supervisorEvaluateForm.empId = row.empId
    supervisorEvaluateForm.year = row.year
    supervisorEvaluateForm.periodType = row.periodType
    supervisorEvaluateForm.supervisorScore = row.supervisorScore || 0
    supervisorEvaluateForm.supervisorComment = row.supervisorComment || ''
    supervisorEvaluateForm.improvementPlan = row.improvementPlan || ''
}

const handleSupervisorEvaluateDialogClose = () => {
    supervisorEvaluateFormRef.value?.resetFields()
    Object.assign(supervisorEvaluateForm, {
        evaluationId: null,
        empId: null,
        year: 2024,
        periodType: 1,
        supervisorScore: 0,
        supervisorComment: '',
        improvementPlan: ''
    })
}

const handleSupervisorEvaluateSubmit = () => {
    supervisorEvaluateFormRef.value.validate(async (valid) => {
        if (!valid) return

        try {
            await supervisorEvaluate(supervisorEvaluateForm)
            ElMessage.success('评价成功')
            supervisorEvaluateDialogVisible.value = false
            loadEvaluationList()
        } catch (error) {
            console.error('评价失败:', error)
            ElMessage.error('评价失败')
        }
    })
}

const handleInterview = () => {
    interviewDialogVisible.value = true
}

const handleInterviewDialogClose = () => {
    interviewFormRef.value?.resetFields()
    Object.assign(interviewForm, {
        evaluationId: null,
        interviewDate: '',
        interviewRecord: ''
    })
}

const handleInterviewSubmit = () => {
    interviewFormRef.value.validate(async (valid) => {
        if (!valid) return

        try {
            await updateInterviewRecord(interviewForm)
            ElMessage.success('保存成功')
            interviewDialogVisible.value = false
            loadEvaluationList()
        } catch (error) {
            console.error('保存失败:', error)
            ElMessage.error('保存失败')
        }
    })
}

const handleViewEvaluation = (row) => {
    currentEvaluation.value = row
    detailDialogVisible.value = true
}
</script>

<style scoped>
.performance-management {
    padding: 20px;
}

h2 {
    margin-bottom: 20px;
    color: #333;
}

.evaluation-detail {
    padding: 10px;
}
</style>
