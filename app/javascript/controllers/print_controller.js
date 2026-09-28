import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { title: String }

  connect() {
    this.savedTitle = document.title
    if (this.titleValue) document.title = this.titleValue
  }

  disconnect() {
    document.title = this.savedTitle
  }

  print() {
    window.print()
  }
}