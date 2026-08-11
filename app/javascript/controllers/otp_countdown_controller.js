import { Controller } from "@hotwired/stimulus"

// 验证码重发倒计时：渲染时开始倒数，倒计时期间禁用「重新发送」按钮
export default class extends Controller {
  static targets = ["timer", "button"]
  static values = { seconds: Number }

  connect() {
    this.remaining = this.secondsValue || 60
    this.render()
    this.interval = setInterval(() => {
      this.remaining -= 1
      this.render()
    }, 1000)
  }

  disconnect() {
    clearInterval(this.interval)
  }

  render() {
    const active = this.remaining > 0
    if (this.hasButtonTarget) this.buttonTarget.disabled = active
    if (this.hasTimerTarget) {
      this.timerTarget.textContent = active ? `${this.remaining} 秒后可重新发送` : ""
    }
    if (!active) clearInterval(this.interval)
  }
}
