import { Controller } from "stimulus";

export default class ReceiptController extends Controller {
    static targets = [ 'modal', 'filename', 'emailAddress', 'emailReceiptToken', 'receiptImagePlaceholder',
                       'imageReceiptUrl', 'receiptImagePlaceholder' ];

    // First time that we are connected,
    connect() {
        console.log('Hello World from ReceiptController()');

        // The listener for the Bootstrap event via jQuery.
        // Thanks to https://mikerogers.io/2019/09/19/listening-to-bootstrap-events-in-stimulus-controllers.html for
        // providing the info that the Bootstrap modal event is generated in a way that prevents Stimulus from attaching
        // to it.
        $(this.modalTarget).on('show.bs.modal', (event) => { this.show() } );
    }

    // Event handler called when the modal is exposed.
    show() {
        console.log('Receipt modal has been shown');

        this.resetFilenameField();
        this.resetImageUrlField();
        this.setEmailReceiptToken();
    }

    resetFilenameField() {
        // this.filenameTarget.nextElementSibling.innerHTML = '';
        this.filenameTarget.disabled = false;
    }

    // When we bring up the modal, we need to clear the Image URL text field as it will need refilling.
    resetImageUrlField() {
        this.imageReceiptUrlTarget.value = '';
    }

    // Used to create a random token to send the email receipt to, so it can be associated with the email.
    setEmailReceiptToken() {
        const token = [...Array(30)].map(() => Math.random().toString(36)[2]).join('').substring(0, 8);
        this.emailReceiptTokenTarget.value = token;
        this.emailAddressTarget.value = `${this.data.get('addressee')}.${token}@tguk-expenses.com`;
    }
    // Event handler for when the user hits the 'Copy to Clipboard' button.  Selects the text, copies to the clipboard
    // and hides the modal.  Note, that the form also generates a PATCH request in the usual way.
    copyToClipboard(event) {
        this.emailAddressTarget.select();
        document.execCommand('copy');
        $(this.modalTarget).modal('hide');
    }

    // Event handler for when the user selects a new file for upload.  This replaces the existing image, or inserts a
    // new one.  Ensures that the image being displayed matches the image the user will upload.
    fileSelected(event) {
        this.filenameTarget
        $('.custom-file-label').html(event.target.files[0].name);

        let newImage = document.createElement("img");
        newImage.className = "img-fluid";
        newImage.dataset.target = "expense-entry.receiptImage";
        newImage.src = URL.createObjectURL(event.target.files[0]);

        let existingImage = this.receiptImagePlaceholderTarget.firstChild;
        if (existingImage == null) {
            this.receiptImagePlaceholderTarget.appendChild(newImage)
        } else {
            this.receiptImagePlaceholderTarget.replaceChild(newImage, existingImage);
        }
    }

    // Event handler for when the modal is dismissed as a result of the user pressing 'Upload'
    dismissReceiptModal(event) {
        $(this.modalTarget).modal('hide');
    }
}
