<template>
  <div class="error-page">
    <h1>404</h1>
    <p>页面不存在</p>
    <el-button type="primary" @click="$router.push('/dashboard')">返回首页</el-button>
  </div>
</template>

<style scoped>
.error-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: var(--bg-page);
}
.error-page h1 { font-size: 72px; color: #909399; margin: 0; }
.error-page p { margin: 16px 0 24px; color: #606266; }
</style>
