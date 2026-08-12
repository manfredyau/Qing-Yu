import { Controller } from "@hotwired/stimulus"

// 照片上传：XHR 直传（带真实进度条），成功后用 Turbo 刷新页面
export default class extends Controller {
  static targets = ["input", "progress", "bar", "status"]

  upload() {
    const file = this.inputTarget.files[0]
    if (!file) return

    const formData = new FormData()
    formData.append("photo[file]", file)

    const xhr = new XMLHttpRequest()
    xhr.open("POST", "/photos")
    xhr.setRequestHeader("X-CSRF-Token", document.querySelector('meta[name="csrf-token"]')?.content || "")

    this.progressTarget.classList.remove("hidden")
    this.barTarget.style.width = "0%"
    this.statusTarget.textContent = "上传中…"
    this.statusTarget.classList.remove("text-red-500")

    xhr.upload.onprogress = (event) => {
      if (event.lengthComputable) {
        const percent = Math.round((event.loaded / event.total) * 100)
        this.barTarget.style.width = percent + "%"
      }
    }

    xhr.onload = () => {
      if (xhr.status >= 200 && xhr.status < 400) {
        this.statusTarget.textContent = "上传成功，等待审核"
        this.barTarget.style.width = "100%"
        // 重新加载页面展示最新照片（含审核中状态）
        setTimeout(() => window.Turbo.visit(window.location.pathname), 600)
      } else {
        this.statusTarget.textContent = "上传失败，请重试"
        this.statusTarget.classList.add("text-red-500")
        this.progressTarget.classList.add("hidden")
        this.inputTarget.value = ""
      }
    }

    xhr.onerror = () => {
      this.statusTarget.textContent = "上传失败，请检查网络"
      this.statusTarget.classList.add("text-red-500")
      this.progressTarget.classList.add("hidden")
      this.inputTarget.value = ""
    }

    xhr.send(formData)
  }
}
