import { Controller } from "@hotwired/stimulus"

// 滑卡交互：按住拖动卡片，松手超过阈值触发 喜欢/跳过；
// 拖动时按方向渐变显示标签（左滑→不合适，右滑→还不错，牵手式）
export default class extends Controller {
  static targets = ["likeForm", "passForm", "likeLabel", "passLabel"]
  static values = { threshold: { type: Number, default: 90 } }

  connect() {
    this.dragging = false
    this.startX = 0
    this.startY = 0
    this.lastDragEndAt = 0
    this.boundDown = this.onPointerDown.bind(this)
    this.boundMove = this.onPointerMove.bind(this)
    this.boundUp = this.onPointerUp.bind(this)
    this.boundCancel = this.onPointerCancel.bind(this)
    this.boundClick = this.onClickCapture.bind(this)
    this.element.addEventListener("pointerdown", this.boundDown)
    this.element.addEventListener("pointermove", this.boundMove)
    this.element.addEventListener("pointerup", this.boundUp)
    this.element.addEventListener("pointercancel", this.boundCancel)
    // 捕获阶段拦截：防止拖拽松手时手指落在按钮上合成的 click 误触喜欢/跳过
    this.element.addEventListener("click", this.boundClick, true)
  }

  disconnect() {
    this.element.removeEventListener("pointerdown", this.boundDown)
    this.element.removeEventListener("pointermove", this.boundMove)
    this.element.removeEventListener("pointerup", this.boundUp)
    this.element.removeEventListener("pointercancel", this.boundCancel)
    this.element.removeEventListener("click", this.boundClick, true)
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
    this.updateLabels(dx)
  }

  // 拖动距离越大，对应方向的标签越明显（0~1 渐变）；超过最小位移才渐显，轻触微动不闪标签
  updateLabels(dx) {
    const min = 24
    const likeOpacity = dx > min ? Math.min(1, (dx - min) / 100) : 0
    const passOpacity = dx < -min ? Math.min(1, (-dx - min) / 100) : 0
    if (this.hasLikeLabelTarget) {
      this.likeLabelTarget.style.opacity = String(likeOpacity)
    }
    if (this.hasPassLabelTarget) {
      this.passLabelTarget.style.opacity = String(passOpacity)
    }
  }

  onPointerUp(event) {
    if (!this.dragging) return
    this.dragging = false
    this.lastDragEndAt = Date.now()
    const dx = event.clientX - this.startX
    this.resetCard()

    // 位移须在合理区间（90~450px）内才算一次有意的滑动，防止坐标异常的误判
    if (Math.abs(dx) > this.thresholdValue && Math.abs(dx) < 450) {
      // 目标元素是提交按钮，须取其所属表单再提交（requestSubmit 是表单方法）
      const button = dx > 0 ? this.likeFormTarget : this.passFormTarget
      const form = button.form || button.closest("form")
      if (!form) return
      if (typeof form.requestSubmit === "function") {
        form.requestSubmit()
      } else {
        form.submit()
      }
    }
  }

  // 浏览器接管手势（如滚动）会触发 pointercancel，其坐标不可靠：
  // 此时只复位卡片，绝不能算作选择（否则轻微滑动会误触发喜欢/跳过）
  onPointerCancel(event) {
    if (!this.dragging) return
    this.dragging = false
    this.lastDragEndAt = Date.now()
    this.resetCard()
  }

  // 刚结束拖动的短暂窗口内，拦截落在按钮上的合成 click（松手位置在按钮上会误触）
  onClickCapture(event) {
    if (this.lastDragEndAt && Date.now() - this.lastDragEndAt < 300) {
      if (event.target.closest("button, [type='submit']")) {
        event.preventDefault()
        event.stopPropagation()
      }
    }
  }

  resetCard() {
    if (this.card) {
      this.card.style.transition = "transform 0.2s ease, opacity 0.2s ease"
      this.card.style.transform = ""
      this.card.style.opacity = ""
      this.card = null
    }
    if (this.hasLikeLabelTarget) this.likeLabelTarget.style.opacity = ""
    if (this.hasPassLabelTarget) this.passLabelTarget.style.opacity = ""
  }
}
