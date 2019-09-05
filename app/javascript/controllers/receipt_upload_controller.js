import { Controller } from "stimulus";

export default class ReceiptUploadController extends Controller {
    static targets = [ 'modal' ];

    // First time that we are connected,
    connect() {
        console.log('Hello World from UploadModalController()');
    }

    dismissUploadModal(event) {
        console.log('Hello World from dismissUploadModal()');
        $(this.modalTarget).modal('hide');
    }
}
