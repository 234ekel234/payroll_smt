import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "form" ]

  submit() {
    clearTimeout(this.timeout)
    // Delay submission by 300ms so it doesn't fire on every single keystroke
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }
}