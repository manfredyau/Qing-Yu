import { Controller } from "@hotwired/stimulus"

// 表单错误定位：页面加载时自动滚动到第一个出错字段。
// 缺项提示不自动滚动（避免把顶部的保存成功 flash 提示滚出屏幕），
// 用户可点击琥珀色提示条里的链接跳转到对应区块。
export default class extends Controller {
  connect() {
    const firstError = this.element.querySelector("[data-field-error]")
    if (firstError) {
      firstError.scrollIntoView({ behavior: "smooth", block: "center" })
    }
  }
}
