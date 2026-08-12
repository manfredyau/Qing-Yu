import { Controller } from "@hotwired/stimulus"

// 表单定位：页面加载时自动滚动到第一个出错字段；
// 无字段错误时，滚动到第一个缺失的资料区块（data-scroll-to）
export default class extends Controller {
  connect() {
    const firstError = this.element.querySelector("[data-field-error]")
    if (firstError) {
      firstError.scrollIntoView({ behavior: "smooth", block: "center" })
      return
    }

    const targetId = this.element.querySelector("[data-scroll-to]")?.dataset.scrollTo
    if (targetId) {
      document.getElementById(targetId)?.scrollIntoView({ behavior: "smooth", block: "center" })
    }
  }
}
