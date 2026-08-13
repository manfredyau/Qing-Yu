import { Controller } from "@hotwired/stimulus"

// 滑卡交互：按住拖动卡片，松手超过阈值触发 喜欢/跳过；
// 拖动时按方向渐变显示标签（左滑→不合适，右滑→还不错，牵手式）
export default class extends Controller {
  static targets = ["likeForm", "passForm", "likeLabel", "passLabel"]
  static values = { threshold: { type: Number, default: 90 } }

  connect() {
    this.dragging = false
    this.animating = false
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
    // 飞出动画播放中忽略新触摸；不拦截按钮/链接等可点击元素
    if (this.animating) return
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
    const dy = event.clientY - this.startY

    // 位移须在合理区间（90~450px）内才算一次有意的滑动，防止坐标异常的误判
    if (Math.abs(dx) > this.thresholdValue && Math.abs(dx) < 450) {
      const like = dx > 0
      this.animateOut(like, dy)
      // 等飞出动画播完再提交，让用户看到「卡片离场 → 下一张入场」的连续特效
      setTimeout(() => this.submitDecision(like), 200)
    } else {
      this.resetCard()
    }
  }

  // 卡片按滑动方向飞出屏幕（旋转 + 淡出），选中方向的标签定格伴随飞出
  animateOut(like, dy) {
    this.animating = true
    const direction = like ? 1 : -1
    if (this.card) {
      this.card.style.transition = "transform 0.22s ease-in, opacity 0.22s ease-in"
      this.card.style.transform =
        `translate(${direction * (window.innerWidth + 160)}px, ${dy * 2}px) rotate(${direction * 28}deg)`
      this.card.style.opacity = "0"
    }
    if (like && this.hasLikeLabelTarget) this.likeLabelTarget.style.opacity = "1"
    if (!like && this.hasPassLabelTarget) this.passLabelTarget.style.opacity = "1"
  }

  submitDecision(like) {
    const button = like ? this.likeFormTarget : this.passFormTarget
    const form = button.form || button.closest("form")
    if (!form) return
    if (typeof form.requestSubmit === "function") {
      form.requestSubmit()
    } else {
      form.submit()
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
