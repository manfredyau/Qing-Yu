import { Controller } from "@hotwired/stimulus"

// 滑卡交互：按住拖动卡片，松手超过阈值触发 喜欢/跳过
export default class extends Controller {
  static targets = ["likeForm", "passForm"]
  static values = { threshold: { type: Number, default: 90 } }

  connect() {
    this.dragging = false
    this.startX = 0
    this.startY = 0
    this.boundDown = this.onPointerDown.bind(this)
    this.boundMove = this.onPointerMove.bind(this)
    this.boundUp = this.onPointerUp.bind(this)
    this.element.addEventListener("pointerdown", this.boundDown)
    this.element.addEventListener("pointermove", this.boundMove)
    this.element.addEventListener("pointerup", this.boundUp)
    this.element.addEventListener("pointercancel", this.boundUp)
  }

  disconnect() {
    this.element.removeEventListener("pointerdown", this.boundDown)
    this.element.removeEventListener("pointermove", this.boundMove)
    this.element.removeEventListener("pointerup", this.boundUp)
    this.element.removeEventListener("pointercancel", this.boundUp)
  }

  onPointerDown(event) {
    // 不拦截按钮/链接等可点击元素
    if (event.target.closest("button, a, input, select, textarea")) return
    this.dragging = true
    this.startX = event.clientX
    this.startY = event.clientY
    this.card = event.currentTarget.querySelector("div")
    this.card.style.transition = "none"
  }

  onPointerMove(event) {
    if (!this.dragging) return
    const dx = event.clientX - this.startX
    const dy = event.clientY - this.startY
    this.card.style.transform = `translate(${dx}px, ${dy * 0.25}px) rotate(${dx * 0.04}deg)`
    this.card.style.opacity = String(Math.max(0.25, 1 - Math.abs(dx) / 450))
  }

  onPointerUp(event) {
    if (!this.dragging) return
    this.dragging = false
    const dx = event.clientX - this.startX
    this.resetCard()

    if (Math.abs(dx) > this.thresholdValue) {
      const form = dx > 0 ? this.likeFormTarget : this.passFormTarget
      form.requestSubmit()
    }
  }

  resetCard() {
    if (!this.card) return
    this.card.style.transition = "transform 0.2s ease, opacity 0.2s ease"
    this.card.style.transform = ""
    this.card.style.opacity = ""
    this.card = null
  }
}
