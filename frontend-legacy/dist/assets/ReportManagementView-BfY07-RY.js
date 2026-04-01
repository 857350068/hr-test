import{j as Y,_ as re,H as ue,r as u,o as d,c as S,a as e,w as t,M as Q,O as Z,f as s,F as U,k as w,t as k,l as H,e as v,p as ee,h as m,q as de,E as T,D as pe,P as ce,s as se,B as me,y as _e,Q as Ee,A as ve,R as ye,S as Se,z as fe,i as Ne,g as Ae,L as ge,N as Ce}from"./index-DVPGCXeP.js";function Te(){return Y({url:"/report/list",method:"get"})}function Ve(q){return Y({url:"/report",method:"post",data:q})}function be(q,W){return Y({url:`/report/${q}`,method:"put",data:W})}function Re(q){return Y({url:`/report/${q}`,method:"delete"})}function De(q){return Y({url:"/report/preview",method:"post",data:{sql:q}})}const Ie={class:"query-builder"},He={class:"step-content"},Le={class:"table-item"},Oe={class:"table-name"},Ue={class:"table-desc"},we={class:"step-content"},qe={class:"field-name"},he={class:"field-type"},ke={class:"field-desc"},Me={class:"step-content"},We={class:"conditions-container"},$e={class:"sort-container"},Be={class:"group-container"},Ge={class:"step-content"},xe={class:"sql-actions"},Qe={key:0,class:"data-preview"},Fe={class:"step-actions"},Ye={__name:"QueryBuilder",emits:["confirm"],setup(q,{emit:W}){const B=W,c=m(0),f=m([]),V=m({}),b=m([]),A=m("AND"),_=m([]),L=m([]),I=m(""),$=m([]),l=m([]),P=[{name:"employee_profile",description:"员工档案表"},{name:"hr_department",description:"部门表"},{name:"hr_data_category",description:"数据分类表"},{name:"warning_rule",description:"预警规则表"},{name:"report_template",description:"报表模板表"}],F={employee_profile:[{name:"id",type:"BIGINT",description:"主键ID"},{name:"employee_no",type:"VARCHAR",description:"员工编号"},{name:"name",type:"VARCHAR",description:"姓名"},{name:"gender",type:"VARCHAR",description:"性别"},{name:"age",type:"INT",description:"年龄"},{name:"dept_id",type:"BIGINT",description:"部门ID"},{name:"dept_name",type:"VARCHAR",description:"部门名称"},{name:"position",type:"VARCHAR",description:"职位"},{name:"level",type:"VARCHAR",description:"职级"},{name:"category_id",type:"INT",description:"数据分类ID"},{name:"period",type:"VARCHAR",description:"周期"},{name:"value",type:"DECIMAL",description:"数值"},{name:"unit",type:"VARCHAR",description:"单位"},{name:"create_time",type:"DATETIME",description:"创建时间"},{name:"update_time",type:"DATETIME",description:"更新时间"},{name:"is_deleted",type:"INT",description:"是否删除"}],hr_department:[{name:"id",type:"BIGINT",description:"主键ID"},{name:"dept_name",type:"VARCHAR",description:"部门名称"},{name:"dept_code",type:"VARCHAR",description:"部门编码"},{name:"parent_id",type:"BIGINT",description:"上级部门ID"},{name:"level",type:"INT",description:"层级"},{name:"manager",type:"VARCHAR",description:"负责人"},{name:"create_time",type:"DATETIME",description:"创建时间"}],hr_data_category:[{name:"id",type:"INT",description:"主键ID"},{name:"category_name",type:"VARCHAR",description:"分类名称"},{name:"category_code",type:"VARCHAR",description:"分类编码"},{name:"description",type:"VARCHAR",description:"描述"}],warning_rule:[{name:"id",type:"BIGINT",description:"主键ID"},{name:"rule_name",type:"VARCHAR",description:"规则名称"},{name:"category_id",type:"INT",description:"分类ID"},{name:"threshold_type",type:"VARCHAR",description:"阈值类型"},{name:"threshold_value",type:"DECIMAL",description:"阈值"},{name:"enabled",type:"INT",description:"是否启用"}],report_template:[{name:"id",type:"BIGINT",description:"主键ID"},{name:"name",type:"VARCHAR",description:"模板名称"},{name:"category",type:"VARCHAR",description:"分类"},{name:"description",type:"VARCHAR",description:"描述"},{name:"query_sql",type:"TEXT",description:"查询SQL"},{name:"enabled",type:"INT",description:"是否启用"}]},j=p=>F[p]||[],x=de(()=>{const p=[];return Object.keys(V.value).forEach(a=>{V.value[a].forEach(E=>{p.push(`${a}.${E}`)})}),p}),le=()=>{b.value.push({field:"",operator:"=",value:""})},te=p=>{b.value.splice(p,1)},ae=()=>{_.value.push({field:"",order:"ASC"})},oe=p=>{_.value.splice(p,1)},ne=()=>{if(f.value.length===0){I.value="-- 请先选择数据表";return}let p=`SELECT
`;const a=[];Object.keys(V.value).forEach(E=>{V.value[E].forEach(N=>{a.push(`  ${E}.${N}`)})}),a.length===0&&a.push("  *"),p+=a.join(`,
`),p+=`
FROM
`,p+=`  ${f.value[0]}`;for(let E=1;E<f.value.length;E++)p+=`
  LEFT JOIN ${f.value[E]} ON ${f.value[0]}.id = ${f.value[E]}.id`;if(b.value.length>0){p+=`
WHERE
`;const E=b.value.map((N,O)=>{let g=`  ${N.field} ${N.operator}`;return N.operator!=="IS NULL"&&N.operator!=="IS NOT NULL"&&(g+=` '${N.value}'`),O<b.value.length-1&&(g+=` ${A.value}`),g});p+=E.join(`
`)}if(L.value.length>0&&(p+=`
GROUP BY
`,p+=`  ${L.value.join(`,
  `)}`),_.value.length>0){p+=`
ORDER BY
`;const E=_.value.map(N=>`  ${N.field} ${N.order}`);p+=E.join(`,
`)}p+=`
LIMIT 1000`,I.value=p};ue([f,V,b,A,_,L],()=>{ne()},{deep:!0});const ie=()=>{c.value>0&&c.value--},i=()=>{if(c.value===0&&f.value.length===0){T.warning("请至少选择一个数据表");return}if(c.value===1){let p=!1;if(Object.keys(V.value).forEach(a=>{V.value[a].length>0&&(p=!0)}),!p){T.warning("请至少选择一个字段");return}}c.value<3&&c.value++},o=async()=>{T.info("SQL预览功能需要后端支持")},h=()=>{navigator.clipboard.writeText(I.value),T.success("SQL已复制到剪贴板")},M=()=>{B("confirm",I.value)};return(p,a)=>{const E=u("el-step"),N=u("el-steps"),O=u("el-checkbox"),g=u("el-checkbox-group"),C=u("el-option"),G=u("el-select"),z=u("el-input"),R=u("el-button"),J=u("el-radio"),K=u("el-radio-group"),X=u("el-table-column"),r=u("el-table");return d(),S("div",Ie,[e(N,{active:c.value,"finish-status":"success","align-center":""},{default:t(()=>[e(E,{title:"选择数据表"}),e(E,{title:"选择字段"}),e(E,{title:"设置条件"}),e(E,{title:"预览SQL"})]),_:1},8,["active"]),Q(s("div",He,[a[4]||(a[4]=s("h3",null,"选择数据表",-1)),e(g,{modelValue:f.value,"onUpdate:modelValue":a[0]||(a[0]=n=>f.value=n)},{default:t(()=>[(d(),S(U,null,w(P,n=>e(O,{key:n.name,label:n.name},{default:t(()=>[s("div",Le,[s("span",Oe,k(n.name),1),s("span",Ue,k(n.description),1)])]),_:2},1032,["label"])),64))]),_:1},8,["modelValue"])],512),[[Z,c.value===0]]),Q(s("div",we,[a[5]||(a[5]=s("h3",null,"选择字段",-1)),(d(!0),S(U,null,w(f.value,n=>(d(),S("div",{key:n,class:"field-group"},[s("h4",null,k(n)+" 表的字段",1),e(g,{modelValue:V.value[n],"onUpdate:modelValue":D=>V.value[n]=D},{default:t(()=>[(d(!0),S(U,null,w(j(n),D=>(d(),H(O,{key:D.name,label:D.name},{default:t(()=>[s("span",qe,k(D.name),1),s("span",he,k(D.type),1),s("span",ke,k(D.description),1)]),_:2},1032,["label"]))),128))]),_:2},1032,["modelValue","onUpdate:modelValue"])]))),128))],512),[[Z,c.value===1]]),Q(s("div",Me,[a[10]||(a[10]=s("h3",null,"设置查询条件",-1)),s("div",We,[(d(!0),S(U,null,w(b.value,(n,D)=>(d(),S("div",{key:D,class:"condition-item"},[e(G,{modelValue:n.field,"onUpdate:modelValue":y=>n.field=y,placeholder:"选择字段",style:{width:"200px"}},{default:t(()=>[(d(!0),S(U,null,w(x.value,y=>(d(),H(C,{key:y,label:y,value:y},null,8,["label","value"]))),128))]),_:1},8,["modelValue","onUpdate:modelValue"]),e(G,{modelValue:n.operator,"onUpdate:modelValue":y=>n.operator=y,placeholder:"操作符",style:{width:"120px"}},{default:t(()=>[e(C,{label:"等于",value:"="}),e(C,{label:"不等于",value:"!="}),e(C,{label:"大于",value:">"}),e(C,{label:"小于",value:"<"}),e(C,{label:"大于等于",value:">="}),e(C,{label:"小于等于",value:"<="}),e(C,{label:"包含",value:"LIKE"}),e(C,{label:"不包含",value:"NOT LIKE"}),e(C,{label:"为空",value:"IS NULL"}),e(C,{label:"不为空",value:"IS NOT NULL"})]),_:1},8,["modelValue","onUpdate:modelValue"]),e(z,{modelValue:n.value,"onUpdate:modelValue":y=>n.value=y,placeholder:"值",style:{width:"200px"},disabled:n.operator==="IS NULL"||n.operator==="IS NOT NULL"},null,8,["modelValue","onUpdate:modelValue","disabled"]),e(R,{type:"danger",icon:"Delete",onClick:y=>te(D),circle:""},null,8,["onClick"])]))),128)),e(R,{type:"primary",icon:"Plus",onClick:le},{default:t(()=>[...a[6]||(a[6]=[v("添加条件",-1)])]),_:1}),e(K,{modelValue:A.value,"onUpdate:modelValue":a[1]||(a[1]=n=>A.value=n),style:{"margin-left":"20px"}},{default:t(()=>[e(J,{label:"AND"},{default:t(()=>[...a[7]||(a[7]=[v("AND (并且)",-1)])]),_:1}),e(J,{label:"OR"},{default:t(()=>[...a[8]||(a[8]=[v("OR (或者)",-1)])]),_:1})]),_:1},8,["modelValue"])]),a[11]||(a[11]=s("h3",{style:{"margin-top":"30px"}},"排序设置",-1)),s("div",$e,[(d(!0),S(U,null,w(_.value,(n,D)=>(d(),S("div",{key:D,class:"sort-item"},[e(G,{modelValue:n.field,"onUpdate:modelValue":y=>n.field=y,placeholder:"选择字段",style:{width:"200px"}},{default:t(()=>[(d(!0),S(U,null,w(x.value,y=>(d(),H(C,{key:y,label:y,value:y},null,8,["label","value"]))),128))]),_:1},8,["modelValue","onUpdate:modelValue"]),e(G,{modelValue:n.order,"onUpdate:modelValue":y=>n.order=y,placeholder:"排序方式",style:{width:"120px"}},{default:t(()=>[e(C,{label:"升序",value:"ASC"}),e(C,{label:"降序",value:"DESC"})]),_:1},8,["modelValue","onUpdate:modelValue"]),e(R,{type:"danger",icon:"Delete",onClick:y=>oe(D),circle:""},null,8,["onClick"])]))),128)),e(R,{type:"primary",icon:"Plus",onClick:ae},{default:t(()=>[...a[9]||(a[9]=[v("添加排序",-1)])]),_:1})]),a[12]||(a[12]=s("h3",{style:{"margin-top":"30px"}},"分组设置",-1)),s("div",Be,[e(G,{modelValue:L.value,"onUpdate:modelValue":a[2]||(a[2]=n=>L.value=n),multiple:"",placeholder:"选择分组字段",style:{width:"100%"}},{default:t(()=>[(d(!0),S(U,null,w(x.value,n=>(d(),H(C,{key:n,label:n,value:n},null,8,["label","value"]))),128))]),_:1},8,["modelValue"])])],512),[[Z,c.value===2]]),Q(s("div",Ge,[a[16]||(a[16]=s("h3",null,"生成的SQL查询语句",-1)),e(z,{modelValue:I.value,"onUpdate:modelValue":a[3]||(a[3]=n=>I.value=n),type:"textarea",rows:10,readonly:"",class:"sql-preview"},null,8,["modelValue"]),s("div",xe,[e(R,{type:"success",icon:"View",onClick:o},{default:t(()=>[...a[13]||(a[13]=[v("预览数据",-1)])]),_:1}),e(R,{type:"primary",icon:"CopyDocument",onClick:h},{default:t(()=>[...a[14]||(a[14]=[v("复制SQL",-1)])]),_:1})]),$.value.length>0?(d(),S("div",Qe,[a[15]||(a[15]=s("h3",null,"数据预览（前10条）",-1)),e(r,{data:$.value,border:"",stripe:""},{default:t(()=>[(d(!0),S(U,null,w(l.value,n=>(d(),H(X,{key:n,prop:n,label:n,"min-width":"120"},null,8,["prop","label"]))),128))]),_:1},8,["data"])])):ee("",!0)],512),[[Z,c.value===3]]),s("div",Fe,[c.value>0?(d(),H(R,{key:0,onClick:ie},{default:t(()=>[...a[17]||(a[17]=[v("上一步",-1)])]),_:1})):ee("",!0),c.value<3?(d(),H(R,{key:1,type:"primary",onClick:i},{default:t(()=>[...a[18]||(a[18]=[v("下一步",-1)])]),_:1})):ee("",!0),c.value===3?(d(),H(R,{key:2,type:"success",onClick:M},{default:t(()=>[...a[19]||(a[19]=[v("确认使用",-1)])]),_:1})):ee("",!0)])])}}},Pe=re(Ye,[["__scopeId","data-v-7163831f"]]),je={class:"template-selector"},ze={class:"template-grid"},Je=["onClick"],Ke={class:"template-icon"},Xe={class:"template-info"},Ze={class:"template-desc"},el={__name:"QueryTemplateSelector",emits:["select"],setup(q,{emit:W}){const B=W,c=m(""),f=m([{id:1,name:"员工基本信息表",description:"查询所有员工的基本信息，包括姓名、部门、职位等",category:"人员报表",icon:ce,sql:`SELECT
  e.id,
  e.employee_no AS 员工编号,
  e.name AS 姓名,
  e.gender AS 性别,
  e.age AS 年龄,
  e.dept_name AS 部门,
  e.position AS 职位,
  e.level AS 职级
FROM employee_profile e
WHERE e.is_deleted = 0
ORDER BY e.id
LIMIT 1000`},{id:2,name:"部门绩效对比表",description:"各部门的平均绩效得分对比分析",category:"绩效报表",icon:se,sql:`SELECT
  dept_id AS 部门ID,
  dept_name AS 部门,
  AVG(CASE WHEN category_id = 1 THEN value END) AS 组织效能,
  AVG(CASE WHEN category_id = 2 THEN value END) AS 人才建设,
  AVG(CASE WHEN category_id = 3 THEN value END) AS 薪酬福利,
  AVG(CASE WHEN category_id = 4 THEN value END) AS 绩效管理
FROM employee_profile
WHERE is_deleted = 0
GROUP BY dept_id, dept_name
ORDER BY 组织效能 DESC
LIMIT 1000`},{id:3,name:"薪酬成本分析表",description:"各部门薪酬成本统计和对比分析",category:"薪酬报表",icon:me,sql:`SELECT
  dept_id AS 部门ID,
  dept_name AS 部门,
  COUNT(DISTINCT employee_no) AS 人数,
  SUM(CASE WHEN category_id = 3 THEN value ELSE 0 END) AS 薪酬总额,
  AVG(CASE WHEN category_id = 3 THEN value END) AS 人均薪酬
FROM employee_profile
WHERE is_deleted = 0
GROUP BY dept_id, dept_name
ORDER BY 薪酬总额 DESC
LIMIT 1000`},{id:4,name:"员工流失分析表",description:"员工流失率统计和流失原因分析",category:"流失报表",icon:_e,sql:`SELECT
  period AS 月份,
  dept_name AS 部门,
  COUNT(DISTINCT employee_no) AS 总人数,
  SUM(CASE WHEN category_id = 5 AND value < 60 THEN 1 ELSE 0 END) AS 高风险人数,
  ROUND(SUM(CASE WHEN category_id = 5 AND value < 60 THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT employee_no), 2) AS 流失率
FROM employee_profile
WHERE is_deleted = 0
GROUP BY period, dept_name
ORDER BY period DESC, 流失率 DESC
LIMIT 1000`},{id:5,name:"人才梯队建设表",description:"各部门人才梯队建设情况分析",category:"人才报表",icon:Ee,sql:`SELECT
  dept_name AS 部门,
  COUNT(DISTINCT employee_no) AS 总人数,
  SUM(CASE WHEN category_id = 2 AND value >= 80 THEN 1 ELSE 0 END) AS 高潜人才,
  SUM(CASE WHEN category_id = 2 AND value >= 60 AND value < 80 THEN 1 ELSE 0 END) AS 中坚力量,
  SUM(CASE WHEN category_id = 2 AND value < 60 THEN 1 ELSE 0 END) AS 待提升
FROM employee_profile
WHERE is_deleted = 0
GROUP BY dept_name
ORDER BY 高潜人才 DESC
LIMIT 1000`},{id:6,name:"培训效果评估表",description:"培训效果和员工技能提升情况分析",category:"培训报表",icon:ve,sql:`SELECT
  period AS 月份,
  dept_name AS 部门,
  AVG(CASE WHEN category_id = 6 THEN value END) AS 培训效果,
  COUNT(DISTINCT employee_no) AS 参训人数
FROM employee_profile
WHERE is_deleted = 0 AND category_id = 6
GROUP BY period, dept_name
ORDER BY period DESC, 培训效果 DESC
LIMIT 1000`},{id:7,name:"人力成本优化表",description:"人力成本结构和优化建议分析",category:"成本报表",icon:ye,sql:`SELECT
  dept_name AS 部门,
  COUNT(DISTINCT employee_no) AS 人数,
  SUM(CASE WHEN category_id = 3 THEN value ELSE 0 END) AS 薪酬成本,
  SUM(CASE WHEN category_id = 7 THEN value ELSE 0 END) AS 管理成本,
  SUM(CASE WHEN category_id = 3 THEN value ELSE 0 END) + SUM(CASE WHEN category_id = 7 THEN value ELSE 0 END) AS 总成本,
  ROUND((SUM(CASE WHEN category_id = 3 THEN value ELSE 0 END) + SUM(CASE WHEN category_id = 7 THEN value ELSE 0 END)) / COUNT(DISTINCT employee_no), 2) AS 人均成本
FROM employee_profile
WHERE is_deleted = 0
GROUP BY dept_name
ORDER BY 总成本 DESC
LIMIT 1000`},{id:8,name:"人才发展预测表",description:"基于历史数据的人才发展预测分析",category:"发展报表",icon:Se,sql:`SELECT
  period AS 月份,
  dept_name AS 部门,
  AVG(CASE WHEN category_id = 8 THEN value END) AS 发展潜力,
  AVG(CASE WHEN category_id = 1 THEN value END) AS 当前绩效,
  ROUND(AVG(CASE WHEN category_id = 8 THEN value END) - AVG(CASE WHEN category_id = 1 THEN value END), 2) AS 提升空间
FROM employee_profile
WHERE is_deleted = 0
GROUP BY period, dept_name
ORDER BY period DESC, 发展潜力 DESC
LIMIT 1000`},{id:9,name:"预警规则统计表",description:"预警规则配置和触发情况统计",category:"效能报表",icon:fe,sql:`SELECT
  r.id AS 规则ID,
  r.rule_name AS 规则名称,
  c.category_name AS 分类,
  r.threshold_type AS 阈值类型,
  r.threshold_value AS 阈值,
  CASE WHEN r.enabled = 1 THEN '启用' ELSE '禁用' END AS 状态
FROM warning_rule r
LEFT JOIN hr_data_category c ON r.category_id = c.id
ORDER BY r.id
LIMIT 1000`},{id:10,name:"综合效能分析表",description:"多维度综合效能分析报表",category:"综合报表",icon:se,sql:`SELECT
  dept_name AS 部门,
  COUNT(DISTINCT employee_no) AS 人数,
  AVG(CASE WHEN category_id = 1 THEN value END) AS 组织效能,
  AVG(CASE WHEN category_id = 2 THEN value END) AS 人才建设,
  AVG(CASE WHEN category_id = 3 THEN value END) AS 薪酬福利,
  AVG(CASE WHEN category_id = 4 THEN value END) AS 绩效管理,
  AVG(CASE WHEN category_id = 5 THEN value END) AS 流失风险,
  AVG(CASE WHEN category_id = 6 THEN value END) AS 培训效果
FROM employee_profile
WHERE is_deleted = 0
GROUP BY dept_name
ORDER BY 组织效能 DESC
LIMIT 1000`}]),V=de(()=>{if(!c.value)return f.value;const A=c.value.toLowerCase();return f.value.filter(_=>_.name.toLowerCase().includes(A)||_.description.toLowerCase().includes(A)||_.category.toLowerCase().includes(A))}),b=A=>{B("select",A)};return(A,_)=>{const L=u("el-input"),I=u("el-icon"),$=u("el-tag");return d(),S("div",je,[_[1]||(_[1]=s("h3",null,"选择预设报表模板",-1)),e(L,{modelValue:c.value,"onUpdate:modelValue":_[0]||(_[0]=l=>c.value=l),placeholder:"搜索模板...","prefix-icon":"Search",style:{"margin-bottom":"20px"},clearable:""},null,8,["modelValue"]),s("div",ze,[(d(!0),S(U,null,w(V.value,l=>(d(),S("div",{key:l.id,class:"template-card",onClick:P=>b(l)},[s("div",Ke,[e(I,{size:32},{default:t(()=>[(d(),H(pe(l.icon)))]),_:2},1024)]),s("div",Xe,[s("h4",null,k(l.name),1),s("p",Ze,k(l.description),1),e($,{size:"small",type:"info"},{default:t(()=>[v(k(l.category),1)]),_:2},1024)])],8,Je))),128))])])}}},ll=re(el,[["__scopeId","data-v-60178cbe"]]),tl={class:"page-header"},al={class:"sql-editor-container"},ol={class:"sql-toolbar"},nl={__name:"ReportManagementView",setup(q){const W=m([]),B=m(!1),c=m(!1),f=m(!1),V=m(""),b=m(null),A=m("basic"),_=m(!1),L=m(!1),I=m([]),$=m([]),l=Ae({id:null,name:"",category:"",description:"",querySql:"",parameters:"",chartConfig:"",enabled:1}),P={name:[{required:!0,message:"请输入模板名称",trigger:"blur"}],category:[{required:!0,message:"请选择分类",trigger:"change"}],querySql:[{required:!0,message:"请输入SQL查询语句",trigger:"blur"}]},F=async()=>{B.value=!0;try{const i=await Te();W.value=i.data||[]}catch{T.error("加载数据失败")}finally{B.value=!1}},j=(i=null)=>{i?(V.value="编辑报表",l.id=i.id,l.name=i.name,l.category=i.category,l.description=i.description||"",l.querySql=i.querySql||"",l.parameters=i.parameters||"",l.chartConfig=i.chartConfig||"",l.enabled=i.enabled):(V.value="新增报表",x()),A.value="basic",c.value=!0},x=()=>{var i;l.id=null,l.name="",l.category="",l.description="",l.querySql="",l.parameters="",l.chartConfig="",l.enabled=1,(i=b.value)==null||i.clearValidate()},le=async()=>{if(b.value){await b.value.validate(),f.value=!0;try{l.id?(await be(l.id,l),T.success("更新成功")):(await Ve(l),T.success("新增成功")),c.value=!1,F()}catch{T.error(l.id?"更新失败":"新增失败")}finally{f.value=!1}}},te=async i=>{try{await Ce.confirm("确定删除该报表吗？","提示",{type:"warning"}),await Re(i),T.success("删除成功"),F()}catch(o){o!=="cancel"&&T.error("删除失败")}},ae=i=>{l.querySql=i,A.value="sql",T.success('SQL已生成，请查看"SQL查询"标签页')},oe=i=>{l.name=i.name,l.category=i.category,l.description=i.description,l.querySql=i.sql,A.value="basic",T.success(`已应用模板：${i.name}`)},ne=async()=>{if(!l.querySql||l.querySql.trim()===""){T.warning("请先输入SQL查询语句");return}L.value=!0,_.value=!0;try{const i=await De(l.querySql);I.value=i.data.data||[],$.value=i.data.columns||[],T.success("数据预览成功")}catch(i){T.error("数据预览失败："+(i.message||"未知错误")),I.value=[],$.value=[]}finally{L.value=!1}},ie=()=>{if(!l.querySql||l.querySql.trim()===""){T.warning("没有可复制的SQL");return}navigator.clipboard.writeText(l.querySql),T.success("SQL已复制到剪贴板")};return Ne(F),(i,o)=>{const h=u("el-button"),M=u("el-table-column"),p=u("el-tag"),a=u("el-table"),E=u("el-card"),N=u("el-input"),O=u("el-form-item"),g=u("el-option"),C=u("el-select"),G=u("el-switch"),z=u("el-form"),R=u("el-tab-pane"),J=u("el-tabs"),K=u("el-dialog"),X=ge("loading");return d(),S("div",null,[s("div",tl,[o[14]||(o[14]=s("h2",{class:"page-title"},"报表管理",-1)),e(h,{type:"primary",onClick:o[0]||(o[0]=r=>j())},{default:t(()=>[...o[13]||(o[13]=[v("新增报表",-1)])]),_:1})]),e(E,null,{default:t(()=>[Q((d(),H(a,{data:W.value,stripe:""},{default:t(()=>[e(M,{prop:"id",label:"ID",width:"80"}),e(M,{prop:"name",label:"模板名称"}),e(M,{prop:"category",label:"分类",width:"120"}),e(M,{prop:"description",label:"描述","show-overflow-tooltip":""}),e(M,{prop:"enabled",label:"启用状态",width:"100"},{default:t(({row:r})=>[e(p,{type:r.enabled===1?"success":"info"},{default:t(()=>[v(k(r.enabled===1?"启用":"禁用"),1)]),_:2},1032,["type"])]),_:1}),e(M,{label:"操作",width:"150",fixed:"right"},{default:t(({row:r})=>[e(h,{type:"primary",link:"",onClick:n=>j(r)},{default:t(()=>[...o[15]||(o[15]=[v("编辑",-1)])]),_:1},8,["onClick"]),e(h,{type:"danger",link:"",onClick:n=>te(r.id)},{default:t(()=>[...o[16]||(o[16]=[v("删除",-1)])]),_:1},8,["onClick"])]),_:1})]),_:1},8,["data"])),[[X,B.value]])]),_:1}),e(K,{modelValue:c.value,"onUpdate:modelValue":o[10]||(o[10]=r=>c.value=r),title:V.value,width:"900px",onClose:x},{footer:t(()=>[e(h,{onClick:o[9]||(o[9]=r=>c.value=!1)},{default:t(()=>[...o[20]||(o[20]=[v("取消",-1)])]),_:1}),e(h,{type:"primary",onClick:le,loading:f.value},{default:t(()=>[...o[21]||(o[21]=[v("确定",-1)])]),_:1},8,["loading"])]),default:t(()=>[e(J,{modelValue:A.value,"onUpdate:modelValue":o[8]||(o[8]=r=>A.value=r),type:"border-card"},{default:t(()=>[e(R,{label:"基本信息",name:"basic"},{default:t(()=>[e(z,{model:l,rules:P,ref_key:"formRef",ref:b,"label-width":"100px"},{default:t(()=>[e(O,{label:"模板名称",prop:"name"},{default:t(()=>[e(N,{modelValue:l.name,"onUpdate:modelValue":o[1]||(o[1]=r=>l.name=r),placeholder:"请输入模板名称"},null,8,["modelValue"])]),_:1}),e(O,{label:"分类",prop:"category"},{default:t(()=>[e(C,{modelValue:l.category,"onUpdate:modelValue":o[2]||(o[2]=r=>l.category=r),placeholder:"请选择分类",clearable:""},{default:t(()=>[e(g,{label:"人员报表",value:"PERSONNEL"}),e(g,{label:"绩效报表",value:"PERFORMANCE"}),e(g,{label:"薪酬报表",value:"COMPENSATION"}),e(g,{label:"效能报表",value:"EFFICIENCY"}),e(g,{label:"人才报表",value:"TALENT"}),e(g,{label:"流失报表",value:"TURNOVER"}),e(g,{label:"培训报表",value:"TRAINING"}),e(g,{label:"成本报表",value:"COST"}),e(g,{label:"发展报表",value:"DEVELOPMENT"}),e(g,{label:"综合报表",value:"COMPREHENSIVE"})]),_:1},8,["modelValue"])]),_:1}),e(O,{label:"描述",prop:"description"},{default:t(()=>[e(N,{modelValue:l.description,"onUpdate:modelValue":o[3]||(o[3]=r=>l.description=r),type:"textarea",rows:2,placeholder:"请输入描述"},null,8,["modelValue"])]),_:1}),e(O,{label:"参数配置",prop:"parameters"},{default:t(()=>[e(N,{modelValue:l.parameters,"onUpdate:modelValue":o[4]||(o[4]=r=>l.parameters=r),type:"textarea",rows:2,placeholder:'JSON格式,如: {"period":"YYYYMM"}'},null,8,["modelValue"])]),_:1}),e(O,{label:"图表配置",prop:"chartConfig"},{default:t(()=>[e(N,{modelValue:l.chartConfig,"onUpdate:modelValue":o[5]||(o[5]=r=>l.chartConfig=r),type:"textarea",rows:2,placeholder:'JSON格式,如: {"type":"bar","title":"标题"}'},null,8,["modelValue"])]),_:1}),e(O,{label:"启用状态",prop:"enabled"},{default:t(()=>[e(G,{modelValue:l.enabled,"onUpdate:modelValue":o[6]||(o[6]=r=>l.enabled=r),"active-value":1,"inactive-value":0},null,8,["modelValue"])]),_:1})]),_:1},8,["model"])]),_:1}),e(R,{label:"SQL查询",name:"sql"},{default:t(()=>[s("div",al,[s("div",ol,[e(h,{type:"primary",icon:"View",onClick:ne},{default:t(()=>[...o[17]||(o[17]=[v("预览数据",-1)])]),_:1}),e(h,{icon:"CopyDocument",onClick:ie},{default:t(()=>[...o[18]||(o[18]=[v("复制SQL",-1)])]),_:1}),e(p,{type:"info",size:"small"},{default:t(()=>[...o[19]||(o[19]=[v("支持MySQL语法，已自动添加安全限制",-1)])]),_:1})]),e(N,{modelValue:l.querySql,"onUpdate:modelValue":o[7]||(o[7]=r=>l.querySql=r),type:"textarea",rows:12,placeholder:"请输入SQL查询语句，或使用可视化构建器生成",class:"sql-editor"},null,8,["modelValue"])])]),_:1}),e(R,{label:"可视化构建器",name:"builder"},{default:t(()=>[e(Pe,{onConfirm:ae})]),_:1}),e(R,{label:"预设模板",name:"template"},{default:t(()=>[e(ll,{onSelect:oe})]),_:1})]),_:1},8,["modelValue"])]),_:1},8,["modelValue","title"]),e(K,{modelValue:_.value,"onUpdate:modelValue":o[12]||(o[12]=r=>_.value=r),title:"数据预览",width:"80%"},{footer:t(()=>[e(h,{onClick:o[11]||(o[11]=r=>_.value=!1)},{default:t(()=>[...o[22]||(o[22]=[v("关闭",-1)])]),_:1})]),default:t(()=>[Q((d(),H(a,{data:I.value,border:"",stripe:""},{default:t(()=>[(d(!0),S(U,null,w($.value,r=>(d(),H(M,{key:r,prop:r,label:r,"min-width":"120"},null,8,["prop","label"]))),128))]),_:1},8,["data"])),[[X,L.value]])]),_:1},8,["modelValue"])])}}},rl=re(nl,[["__scopeId","data-v-875956a0"]]);export{rl as default};
