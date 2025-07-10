import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "confirmButton"]

  connect() {
    this.element.setAttribute("data-turbo-frame", "_top")
  }

  open(event) {
    event.preventDefault()
    this.element.classList.remove("hidden")
    const message = event.currentTarget.dataset.confirmModalMessage
    const url = event.currentTarget.dataset.confirmModalUrl
    this.messageTarget.textContent = message
    this.confirmButtonTarget.dataset.url = url
  }

  close() {
    this.element.classList.add("hidden")
  }

  confirm() {
    const url = this.confirmButtonTarget.dataset.url
    fetch(url, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "text/vnd.turbo-stream.html"
      }
    }).then(response => {
      if (response.ok) {
        this.close()
      }
    })
  }
}