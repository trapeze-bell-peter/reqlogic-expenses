import { Controller } from "stimulus";

export default class ReceiptUploadController extends Controller {
    static targets = [ 'modal', 'receiptImagePlaceholder' ];

    // First time that we are connected,
    connect() {
        console.log('Hello World from UploadModalController()');
    }

    // Event handler for when the user selects a new file for upload.  This replaces the existing image, or inserts a
    // new one.  Ensures that the image being displayed matches the image the user will upload.
    fileSelected(event) {
        let newImage = document.createElement("img");
        newImage.className = "img-fluid";
        newImage.dataset.target = "expense-entry.receiptImage";
        newImage.src = URL.createObjectURL(event.target.files[0]);

        let existingImage = this.receiptImagePlaceholderTarget.firstChild;
        if (existingImage === undefined) {
            this.receiptImagePlaceholderTarget.appendChild(newImage)
        } else {
            this.receiptImagePlaceholderTarget.replaceChild(newImage, existingImage);
        }
    }

    // Event handler for when the modal is dismissed as a result of the user pressing 'Upload'
    dismissUploadModal(event) {
        $(this.modalTarget).modal('hide');
    }
}
