# **1. 实现模型**

## **1.1 上下文视图**

本项目采用Vue 3 + Element Plus架构，前端UI重新设计将在现有架构基础上进行样式优化和视觉升级。

```
┌─────────────────────────────────────────────────────────┐
│                    前端应用层                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ 登录页面  │  │ 仪表盘   │  │ 整体布局  │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                    样式系统层                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ CSS变量  │  │ 公共样式  │  │ 组件样式  │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                  Element Plus组件库                      │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                    Vue 3框架                             │
└─────────────────────────────────────────────────────────┘
```

## **1.2 服务/组件总体架构**

### **1.2.1 样式架构**

```
frontend-legacy/src/assets/styles/
├── variables.css          # CSS变量定义（配色系统）
├── common.css             # 公共样式
├── login.css              # 登录页样式
├── dashboard.css          # 仪表盘样式
└── layout.css             # 布局样式
```

### **1.2.2 组件架构**

```
frontend-legacy/src/views/
├── LoginView.vue          # 登录页面组件
├── DashboardView.vue      # 仪表盘页面组件
└── LayoutView.vue         # 整体布局组件
```

## **1.3 实现设计文档**

### **1.3.1 配色系统实现**

**CSS变量定义（variables.css）**

```css
:root {
  /* 主色系 - Element Plus蓝色 */
  --primary-color: #409EFF;
  --primary-light: #66b1ff;
  --primary-lighter: #ecf5ff;
  --primary-dark: #3a8ee6;

  /* 功能色系 */
  --success-color: #67C23A;
  --success-light: #85ce61;
  --success-lighter: #f0f9eb;

  --warning-color: #E6A23C;
  --warning-light: #ebb563;
  --warning-lighter: #fdf6ec;

  --danger-color: #F56C6C;
  --danger-light: #f78989;
  --danger-lighter: #fef0f0;

  /* 中性色系 - 60%占比 */
  --text-primary: #303133;
  --text-secondary: #606266;
  --text-tertiary: #909399;
  --text-placeholder: #C0C4CC;

  --border-color: #DCDFE6;
  --border-light: #E4E7ED;
  --border-lighter: #EBEEF5;

  /* 背景色系 */
  --bg-page: #f5f7fa;
  --bg-card: #ffffff;
  --bg-hover: #ecf5ff;
  --bg-disabled: #f0f0f0;

  /* 侧边栏 */
  --sidebar-bg: #304156;
  --sidebar-text: #bfcbd9;
  --sidebar-active-text: #409EFF;

  /* 阴影 */
  --shadow-base: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  --shadow-light: 0 2px 4px rgba(0, 0, 0, 0.12);
  --shadow-hover: 0 4px 12px rgba(0, 0, 0, 0.15);

  /* 尺寸 */
  --border-radius: 8px;
  --transition-time: 0.3s;
}
```

**配色原则说明：**

1. **主色（10%）**：#409EFF蓝色，用于按钮、链接、激活状态
2. **辅助色（30%）**：功能色（绿、橙、红）用于状态标识
3. **中性色（60%）**：灰阶色系，用于文本、边框、背景

**禁止使用的颜色：**
- ❌ 紫色系：#8B5CF6, #6366F1, #A855F7, #7C3AED
- ❌ Indigo系：#4F46E5, #4338CA
- ❌ 紫蓝渐变：linear-gradient(135deg, #667eea 0%, #764ba2 100%)

### **1.3.2 登录页面实现**

**设计要点：**

1. **布局**：居中卡片式，左右分栏（左侧品牌展示，右侧登录表单）
2. **背景**：纯色背景#f5f7fa，可添加细微网格纹理
3. **卡片**：白色背景，圆角8px，轻微阴影
4. **表单**：Element Plus Form组件，输入框带图标
5. **按钮**：主色#409EFF，悬停加深

**关键样式：**

```css
.login-container {
  min-height: 100vh;
  background: var(--bg-page);
  /* 可选：添加网格纹理 */
  background-image: 
    linear-gradient(rgba(0,0,0,0.03) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0,0,0,0.03) 1px, transparent 1px);
  background-size: 20px 20px;
}

.login-card {
  background: var(--bg-card);
  border-radius: var(--border-radius);
  box-shadow: var(--shadow-base);
  transition: all var(--transition-time);
}

.login-card:hover {
  box-shadow: var(--shadow-hover);
}

.login-button {
  background: var(--primary-color);
  border-color: var(--primary-color);
  transition: all var(--transition-time);
}

.login-button:hover {
  background: var(--primary-light);
  border-color: var(--primary-light);
}
```

### **1.3.3 仪表盘页面实现**

**设计要点：**

1. **统计卡片**：白色背景，圆角8px，轻微阴影，悬停上浮
2. **数据展示**：数值大字号深色，标签小字号次要色
3. **图标**：Element Plus图标，颜色与功能对应
4. **表格**：Element Plus Table，斑马纹，悬停高亮
5. **图表**：可选，使用ECharts，配色与系统一致

**关键样式：**

```css
.stat-card {
  background: var(--bg-card);
  border-radius: var(--border-radius);
  box-shadow: var(--shadow-light);
  padding: 20px;
  transition: all var(--transition-time);
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-hover);
}

.stat-value {
  font-size: 28px;
  font-weight: 600;
  color: var(--text-primary);
}

.stat-label {
  font-size: 14px;
  color: var(--text-secondary);
}

.stat-icon {
  font-size: 48px;
  opacity: 0.8;
}

.stat-icon.success { color: var(--success-color); }
.stat-icon.warning { color: var(--warning-color); }
.stat-icon.danger { color: var(--danger-color); }
.stat-icon.primary { color: var(--primary-color); }
```

### **1.3.4 整体布局实现**

**设计要点：**

1. **侧边栏**：深色背景#304156，宽度200px，可折叠
2. **顶部栏**：白色背景，高度60px，面包屑+用户信息
3. **内容区**：浅灰背景#f5f7fa，内边距20px
4. **响应式**：小屏幕侧边栏自动折叠

**关键样式：**

```css
.layout-container {
  display: flex;
  min-height: 100vh;
}

.sidebar {
  width: 200px;
  background: var(--sidebar-bg);
  transition: width var(--transition-time);
}

.sidebar.collapsed {
  width: 64px;
}

.sidebar-menu-item {
  color: var(--sidebar-text);
  transition: all var(--transition-time);
}

.sidebar-menu-item.active {
  color: var(--sidebar-active-text);
  background: rgba(64, 158, 255, 0.1);
}

.header {
  height: 60px;
  background: var(--bg-card);
  border-bottom: 1px solid var(--border-lighter);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
}

.main-content {
  flex: 1;
  background: var(--bg-page);
  padding: 20px;
  overflow-y: auto;
}
```

# **2. 接口设计**

## **2.1 总体设计**

本次UI重新设计主要涉及样式文件修改，不涉及API接口变更。所有样式通过CSS变量和CSS类实现，组件通过props和slots进行配置。

## **2.2 接口清单**

### **2.2.1 CSS变量接口**

| 变量名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| --primary-color | Color | #409EFF | 主色 |
| --success-color | Color | #67C23A | 成功色 |
| --warning-color | Color | #E6A23C | 警告色 |
| --danger-color | Color | #F56C6C | 危险色 |
| --text-primary | Color | #303133 | 主要文本色 |
| --text-secondary | Color | #606266 | 次要文本色 |
| --bg-page | Color | #f5f7fa | 页面背景色 |
| --bg-card | Color | #ffffff | 卡片背景色 |
| --border-radius | Size | 8px | 圆角大小 |
| --transition-time | Time | 0.3s | 过渡时间 |

### **2.2.2 组件Props接口**

**LoginView组件：**
- 无新增props，使用Element Plus Form组件默认props

**DashboardView组件：**
- stats: Array - 统计数据数组
- tables: Array - 表格数据数组

**LayoutView组件：**
- collapsed: Boolean - 侧边栏折叠状态
- menuItems: Array - 菜单项数组

# **3. 数据模型**

## **3.1 设计目标**

本次UI重新设计不涉及数据模型变更，使用现有数据结构。

## **3.2 模型实现**

### **3.2.1 统计数据模型**

```typescript
interface StatItem {
  id: string;
  label: string;
  value: number | string;
  icon: string;
  type: 'primary' | 'success' | 'warning' | 'danger';
  trend?: {
    value: number;
    direction: 'up' | 'down';
  };
}
```

### **3.2.2 菜单项模型**

```typescript
interface MenuItem {
  id: string;
  label: string;
  icon: string;
  path: string;
  children?: MenuItem[];
}
```

# **4. 实现策略**

## **4.1 分阶段实施**

### **阶段一：配色系统统一**
1. 更新variables.css，定义完整的CSS变量
2. 检查并替换所有硬编码颜色值
3. 删除所有紫色渐变相关代码

### **阶段二：登录页面重构**
1. 重新设计登录页布局
2. 优化表单样式
3. 添加网格纹理背景（可选）

### **阶段三：仪表盘页面重构**
1. 重新设计统计卡片
2. 优化数据展示样式
3. 统一图表配色

### **阶段四：整体布局优化**
1. 优化侧边栏样式
2. 优化顶部栏样式
3. 完善响应式设计

## **4.2 质量保证**

### **4.2.1 视觉检查清单**

- [ ] 无紫色渐变
- [ ] 无indigo色系
- [ ] 配色符合60-30-10法则
- [ ] 背景为纯色或细微纹理
- [ ] 所有颜色使用CSS变量
- [ ] 悬停效果流畅
- [ ] 响应式布局正常

### **4.2.2 性能检查清单**

- [ ] CSS文件大小 < 100KB
- [ ] 无重复样式定义
- [ ] 过渡动画流畅
- [ ] 首屏渲染 < 2秒

## **4.3 风险控制**

### **4.3.1 兼容性风险**

**风险**：CSS变量在旧浏览器不支持
**应对**：提供降级方案，使用固定颜色值

### **4.3.2 样式冲突风险**

**风险**：新样式与Element Plus默认样式冲突
**应对**：使用CSS变量覆盖，避免直接修改组件库样式

### **4.3.3 业务影响风险**

**风险**：样式变更影响业务功能
**应对**：分阶段实施，每阶段进行功能测试
