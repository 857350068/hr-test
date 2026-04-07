import * as XLSX from 'xlsx'

/**
 * Excel导入工具类
 */

/**
 * 解析Excel文件
 * @param {File} file - 要解析的Excel文件
 * @param {Object} options - 配置选项
 * @param {Number} options.sheetIndex - 工作表索引，默认0
 * @param {Object} options.fieldMapping - 字段映射 { 显示名称: 字段名 }
 * @param {Boolean} options.hasHeader - 是否包含表头，默认true
 * @returns {Promise<Array>} 解析后的数据数组
 */
export function parseExcel(file, options = {}) {
  return new Promise((resolve, reject) => {
    const {
      sheetIndex = 0,
      fieldMapping = {},
      hasHeader = true
    } = options

    const reader = new FileReader()

    reader.onload = (e) => {
      try {
        const data = new Uint8Array(e.target.result)
        const workbook = XLSX.read(data, { type: 'array' })

        // 获取指定工作表
        const sheetName = workbook.SheetNames[sheetIndex]
        if (!sheetName) {
          reject(new Error(`工作表索引 ${sheetIndex} 不存在`))
          return
        }

        const worksheet = workbook.Sheets[sheetName]

        // 转换为JSON
        let jsonData = XLSX.utils.sheet_to_json(worksheet, {
          header: hasHeader ? 1 : null,
          defval: '' // 空单元格默认值
        })

        if (hasHeader && jsonData.length > 0) {
          // 第一行是表头
          const headers = jsonData[0]
          const rows = jsonData.slice(1)

          // 转换为对象数组
          jsonData = rows.map(row => {
            const item = {}
            headers.forEach((header, index) => {
              if (header) {
                // 应用字段映射
                const fieldName = fieldMapping[header] || header
                item[fieldName] = row[index] || ''
              }
            })
            return item
          })
        }

        resolve(jsonData)
      } catch (error) {
        reject(new Error(`Excel解析失败: ${error.message}`))
      }
    }

    reader.onerror = () => {
      reject(new Error('文件读取失败'))
    }

    reader.readAsArrayBuffer(file)
  })
}

/**
 * 数据校验
 * @param {Array} data - 要校验的数据数组
 * @param {Object} rules - 校验规则
 * @param {Boolean} rules[].required - 是否必填
 * @param {String} rules[].type - 数据类型 (string, number, date, email, phone)
 * @param {Number} rules[].min - 最小值/最小长度
 * @param {Number} rules[].max - 最大值/最大长度
 * @param {RegExp} rules[].pattern - 正则表达式
 * @param {Function} rules[].validator - 自定义校验函数
 * @param {String} rules[].message - 错误提示信息
 * @returns {Object} 校验结果 { valid: Boolean, errors: Array }
 */
export function validateData(data, rules) {
  const errors = []

  if (!data || data.length === 0) {
    return { valid: false, errors: [{ row: 0, message: '数据不能为空' }] }
  }

  data.forEach((item, rowIndex) => {
    Object.keys(rules).forEach(field => {
      const rule = rules[field]
      const value = item[field]
      const rowNumber = rowIndex + 2 // Excel行号（从2开始，第1行是表头）

      // 必填校验
      if (rule.required && (value === null || value === undefined || value === '')) {
        errors.push({
          row: rowNumber,
          field,
          message: rule.message || `第${rowNumber}行: ${field}不能为空`
        })
        return
      }

      // 如果值为空且非必填，跳过其他校验
      if (value === null || value === undefined || value === '') {
        return
      }

      // 类型校验
      if (rule.type) {
        switch (rule.type) {
          case 'number':
            if (isNaN(Number(value))) {
              errors.push({
                row: rowNumber,
                field,
                message: rule.message || `第${rowNumber}行: ${field}必须是数字`
              })
            }
            break
          case 'email':
            const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
            if (!emailPattern.test(value)) {
              errors.push({
                row: rowNumber,
                field,
                message: rule.message || `第${rowNumber}行: ${field}格式不正确`
              })
            }
            break
          case 'phone':
            const phonePattern = /^1[3-9]\d{9}$/
            if (!phonePattern.test(value)) {
              errors.push({
                row: rowNumber,
                field,
                message: rule.message || `第${rowNumber}行: ${field}格式不正确`
              })
            }
            break
          case 'date':
            if (isNaN(Date.parse(value))) {
              errors.push({
                row: rowNumber,
                field,
                message: rule.message || `第${rowNumber}行: ${field}必须是有效日期`
              })
            }
            break
        }
      }

      // 最小值/最小长度校验
      if (rule.min !== undefined) {
        if (rule.type === 'number') {
          if (Number(value) < rule.min) {
            errors.push({
              row: rowNumber,
              field,
              message: rule.message || `第${rowNumber}行: ${field}不能小于${rule.min}`
            })
          }
        } else {
          if (String(value).length < rule.min) {
            errors.push({
              row: rowNumber,
              field,
              message: rule.message || `第${rowNumber}行: ${field}长度不能小于${rule.min}`
            })
          }
        }
      }

      // 最大值/最大长度校验
      if (rule.max !== undefined) {
        if (rule.type === 'number') {
          if (Number(value) > rule.max) {
            errors.push({
              row: rowNumber,
              field,
              message: rule.message || `第${rowNumber}行: ${field}不能大于${rule.max}`
            })
          }
        } else {
          if (String(value).length > rule.max) {
            errors.push({
              row: rowNumber,
              field,
              message: rule.message || `第${rowNumber}行: ${field}长度不能大于${rule.max}`
            })
          }
        }
      }

      // 正则表达式校验
      if (rule.pattern && !rule.pattern.test(value)) {
        errors.push({
          row: rowNumber,
          field,
          message: rule.message || `第${rowNumber}行: ${field}格式不正确`
        })
      }

      // 自定义校验函数
      if (rule.validator) {
        const result = rule.validator(value, item, rowIndex)
        if (result !== true) {
          errors.push({
            row: rowNumber,
            field,
            message: result || `第${rowNumber}行: ${field}校验失败`
          })
        }
      }
    })
  })

  return {
    valid: errors.length === 0,
    errors
  }
}

/**
 * 检查文件类型
 * @param {File} file - 文件对象
 * @param {Array} allowedTypes - 允许的文件类型数组，如 ['.xlsx', '.xls']
 * @returns {Boolean} 是否为允许的类型
 */
export function checkFileType(file, allowedTypes = ['.xlsx', '.xls']) {
  const fileName = file.name.toLowerCase()
  return allowedTypes.some(type => fileName.endsWith(type.toLowerCase()))
}

/**
 * 检查文件大小
 * @param {File} file - 文件对象
 * @param {Number} maxSize - 最大文件大小（字节）
 * @returns {Boolean} 是否超过大小限制
 */
export function checkFileSize(file, maxSize = 10 * 1024 * 1024) {
  return file.size <= maxSize
}

/**
 * 格式化文件大小
 * @param {Number} bytes - 字节数
 * @returns {String} 格式化后的文件大小
 */
export function formatFileSize(bytes) {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
}
