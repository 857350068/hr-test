import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

/**
 * Excel导出工具类
 */

/**
 * 导出数据到Excel文件
 * @param {Array} data - 要导出的数据数组
 * @param {String} filename - 文件名（不含扩展名）
 * @param {Object} options - 配置选项
 * @param {Object} options.fieldMapping - 字段映射 { 字段名: 显示名称 }
 * @param {Array} options.fields - 要导出的字段列表，不指定则导出所有字段
 * @param {String} options.sheetName - 工作表名称，默认'Sheet1'
 */
export function exportToExcel(data, filename, options = {}) {
  if (!data || data.length === 0) {
    throw new Error('导出数据不能为空')
  }

  const {
    fieldMapping = {},
    fields = null,
    sheetName = 'Sheet1'
  } = options

  // 处理数据
  let exportData = data

  // 如果指定了字段列表，只导出指定字段
  if (fields && fields.length > 0) {
    exportData = data.map(item => {
      const newItem = {}
      fields.forEach(field => {
        newItem[field] = item[field]
      })
      return newItem
    })
  }

  // 应用字段映射（将字段名转换为中文表头）
  if (Object.keys(fieldMapping).length > 0) {
    exportData = exportData.map(item => {
      const newItem = {}
      Object.keys(item).forEach(key => {
        const displayName = fieldMapping[key] || key
        newItem[displayName] = item[key]
      })
      return newItem
    })
  }

  // 创建工作表
  const ws = XLSX.utils.json_to_sheet(exportData)

  // 设置列宽
  const colWidths = []
  if (exportData.length > 0) {
    const headers = Object.keys(exportData[0])
    headers.forEach((header, colIndex) => {
      let maxWidth = header.length
      exportData.forEach(row => {
        const cellValue = row[header]
        if (cellValue) {
          const cellLength = String(cellValue).length
          if (cellLength > maxWidth) {
            maxWidth = cellLength
          }
        }
      })
      colWidths.push({ wch: Math.min(maxWidth + 2, 50) }) // 最大宽度50
    })
  }
  ws['!cols'] = colWidths

  // 创建工作簿
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, sheetName)

  // 生成Excel文件
  const excelBuffer = XLSX.write(wb, { bookType: 'xlsx', type: 'array' })
  const blob = new Blob([excelBuffer], { type: 'application/octet-stream' })

  // 下载文件
  const timestamp = new Date().toISOString().replace(/[-:T]/g, '').slice(0, 14)
  const fullFilename = `${filename}_${timestamp}.xlsx`
  saveAs(blob, fullFilename)

  return fullFilename
}

/**
 * 导出大数据量到Excel（分批处理）
 * @param {Array} data - 要导出的数据数组
 * @param {String} filename - 文件名
 * @param {Object} options - 配置选项
 * @param {Number} options.batchSize - 每批处理的数据量，默认10000
 */
export function exportLargeExcel(data, filename, options = {}) {
  const {
    batchSize = 10000,
    fieldMapping = {},
    fields = null,
    sheetName = 'Sheet1'
  } = options

  if (!data || data.length === 0) {
    throw new Error('导出数据不能为空')
  }

  // 对于大数据量，使用流式处理
  const wb = XLSX.utils.book_new()

  // 分批处理数据
  const totalBatches = Math.ceil(data.length / batchSize)
  for (let i = 0; i < totalBatches; i++) {
    const start = i * batchSize
    const end = Math.min(start + batchSize, data.length)
    const batchData = data.slice(start, end)

    // 处理每批数据
    let exportData = batchData

    if (fields && fields.length > 0) {
      exportData = exportData.map(item => {
        const newItem = {}
        fields.forEach(field => {
          newItem[field] = item[field]
        })
        return newItem
      })
    }

    if (Object.keys(fieldMapping).length > 0) {
      exportData = exportData.map(item => {
        const newItem = {}
        Object.keys(item).forEach(key => {
          const displayName = fieldMapping[key] || key
          newItem[displayName] = item[key]
        })
        return newItem
      })
    }

    // 创建工作表
    const ws = XLSX.utils.json_to_sheet(exportData)
    const currentSheetName = totalBatches > 1 ? `${sheetName}_${i + 1}` : sheetName
    XLSX.utils.book_append_sheet(wb, ws, currentSheetName)
  }

  // 生成并下载文件
  const excelBuffer = XLSX.write(wb, { bookType: 'xlsx', type: 'array' })
  const blob = new Blob([excelBuffer], { type: 'application/octet-stream' })

  const timestamp = new Date().toISOString().replace(/[-:T]/g, '').slice(0, 14)
  const fullFilename = `${filename}_${timestamp}.xlsx`
  saveAs(blob, fullFilename)

  return fullFilename
}

/**
 * 导出多个工作表到Excel
 * @param {Array} sheets - 工作表配置数组
 * @param {String} sheets[].name - 工作表名称
 * @param {Array} sheets[].data - 工作表数据
 * @param {Object} sheets[].fieldMapping - 字段映射
 * @param {String} filename - 文件名
 */
export function exportMultiSheetExcel(sheets, filename) {
  if (!sheets || sheets.length === 0) {
    throw new Error('工作表配置不能为空')
  }

  const wb = XLSX.utils.book_new()

  sheets.forEach(sheet => {
    let exportData = sheet.data

    // 应用字段映射
    if (sheet.fieldMapping && Object.keys(sheet.fieldMapping).length > 0) {
      exportData = exportData.map(item => {
        const newItem = {}
        Object.keys(item).forEach(key => {
          const displayName = sheet.fieldMapping[key] || key
          newItem[displayName] = item[key]
        })
        return newItem
      })
    }

    const ws = XLSX.utils.json_to_sheet(exportData)
    XLSX.utils.book_append_sheet(wb, ws, sheet.name)
  })

  // 生成并下载文件
  const excelBuffer = XLSX.write(wb, { bookType: 'xlsx', type: 'array' })
  const blob = new Blob([excelBuffer], { type: 'application/octet-stream' })

  const timestamp = new Date().toISOString().replace(/[-:T]/g, '').slice(0, 14)
  const fullFilename = `${filename}_${timestamp}.xlsx`
  saveAs(blob, fullFilename)

  return fullFilename
}

/**
 * 生成Excel模板
 * @param {Array} fields - 字段配置数组
 * @param {String} fields[].name - 字段名
 * @param {String} fields[].label - 字段显示名称
 * @param {String} fields[].example - 示例值
 * @param {String} filename - 文件名
 */
export function generateTemplate(fields, filename) {
  if (!fields || fields.length === 0) {
    throw new Error('字段配置不能为空')
  }

  // 创建表头行
  const headers = {}
  fields.forEach(field => {
    headers[field.label || field.name] = field.example || ''
  })

  // 创建示例数据行
  const exampleData = [headers]

  // 创建工作表
  const ws = XLSX.utils.json_to_sheet(exampleData)

  // 设置列宽
  ws['!cols'] = fields.map(field => ({
    wch: Math.max((field.label || field.name).length, (field.example || '').length) + 5
  }))

  // 创建工作簿
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, '模板')

  // 生成并下载文件
  const excelBuffer = XLSX.write(wb, { bookType: 'xlsx', type: 'array' })
  const blob = new Blob([excelBuffer], { type: 'application/octet-stream' })

  const fullFilename = `${filename}_模板.xlsx`
  saveAs(blob, fullFilename)

  return fullFilename
}
