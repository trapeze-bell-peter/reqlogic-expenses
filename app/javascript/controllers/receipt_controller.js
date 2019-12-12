import { Controller } from "stimulus";

export default class ReceiptController extends Controller {
    static targets = [ 'modal', 'filename', 'emailAddress', 'emailReceiptToken', 'imageReceiptUrl',
                       'newReceiptImagePlaceholder', 'receiptSizeLabel' ];

    // First time that we are connected,
    connect() {
        console.log('Hello World from ReceiptController()');

        // The listener for the Bootstrap event via jQuery.
        // Thanks to https://mikerogers.io/2019/09/19/listening-to-bootstrap-events-in-stimulus-controllers.html for
        // providing the info that the Bootstrap modal event is generated in a way that prevents Stimulus from attaching
        // to it.
        $(this.modalTarget).on('show.bs.modal', (event) => { this.show(event) } );
    }

    // Event handler called when the modal is exposed.
    show(event) {
        console.log('Receipt modal has been shown');

        this.expenseEntryDiv = event.relatedTarget.closest('.expense-entry');

        this.resetImageAndFilenameField();
        this.resetImageUrlField();
        this.setEmailReceiptToken();
    }

    resetImageAndFilenameField() {
        if (this.newReceiptImagePlaceholderTarget.firstChild!=null) {
            this.newReceiptImagePlaceholderTarget.firstChild.remove();
        }
        this.filenameTarget.nextElementSibling.innerHTML = '';
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
        $('.custom-file-label').html(event.target.files[0].name);

        let newImage = document.createElement("img");
        newImage.className = "img-fluid receipt-img";
        newImage.dataset.target = "expense-entry.receiptImage";
        newImage.src = URL.createObjectURL(event.target.files[0]);

        this.newReceiptImagePlaceholderTarget.appendChild(newImage)
    }

    setReceiptSize(event) {
        this.receiptSizeLabelTargets.forEach( receiptSizeLabel => {
            receiptSizeLabel.firstChild.checked = receiptSizeLabel.classList.contains('active');
        });
        $(this.modalTarget).modal('hide');
    }
}
