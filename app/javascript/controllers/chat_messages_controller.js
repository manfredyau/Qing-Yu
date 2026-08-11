import { Controller } from "@hotwired/stimulus"

// 聊天消息区：按当前用户对齐气泡（广播渲染为中性样式）+ 自动滚动到底部
export default class extends Controller {
  connect() {
    this.align()
    this.scrollToBottom()
    this.boundOnStream = this.onStream.bind(this)
    document.addEventListener("turbo:before-stream-render", this.boundOnStream)
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.boundOnStream)
  }

  onStream() {
    requestAnimationFrame(() => {
      this.align()
      this.scrollToBottom()
    })
  }

  // 依据消息发送者与当前登录用户，左右对齐并区分气泡配色
  align() {
    const uid = document.body.dataset.currentUserId
    this.element.querySelectorAll("[data-message-row]").forEach((row) => {
      const mine = String(row.dataset.senderId) === uid
      const bubble = row.querySelector("[data-message-bubble]")
      row.classList.toggle("justify-end", mine)
      row.classList.toggle("justify-start", !mine)
      if (bubble) {
        bubble.classList.toggle("bg-teal-600", mine)
        bubble.classList.toggle("text-white", mine)
        bubble.classList.toggle("rounded-br-sm", mine)
        bubble.classList.toggle("bg-white", !mine)
        bubble.classList.toggle("text-gray-800", !mine)
        bubble.classList.toggle("rounded-bl-sm", !mine)
        bubble.classList.toggle("border", !mine)
        bubble.classList.toggle("border-gray-100", !mine)
        bubble.classList.toggle("shadow-sm", !mine)
      }
    })
  }

  scrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight
  }
}
