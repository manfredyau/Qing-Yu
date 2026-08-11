import { Controller } from "@hotwired/stimulus"

// 点击 flash 消息将其隐藏
export default class extends Controller {
  hide() {
    this.element.remove()
  }
}
