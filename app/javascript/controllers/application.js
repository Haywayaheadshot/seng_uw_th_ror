import { Application } from "@hotwired/stimulus"
import ConfirmModalController from "./controllers/confirm_modal_controller"

const application = Application.start()
application.register("confirm-modal", ConfirmModalController)

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }


