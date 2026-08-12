import { Controller } from "@hotwired/stimulus"

// 表单错误定位：页面加载时自动滚动到第一个出错字段
export default class extends Controller {
  connect() {
    const firstError = this.element.querySelector("[data-field-error]")
    if (firstError) {
      firstError.scrollIntoView({ behavior: "smooth", block: "center" })
    }
  }
}
