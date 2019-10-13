import { Controller } from "stimulus";

export default class ReceiptFromEmailController extends Controller {
    static targets = [ 'modal', 'emailAddress', 'emailReceiptToken' ];

    // First time that we are connected,
    connect() {
        console.log('Hello World from ReceiptFromEmailController()');

        // The listner for the Bootstrap event via jQuery
        $(this.modalTarget).on('show.bs.modal', (event) => { this.show() } );
    }

    // Event handler called when the form is exposed.  Generates a random token and inserts it into the read-only
    // text field.
    show() {
        console.log('ReceiptFromEmail modal has been shown');
        const token = [...Array(30)].map(() => Math.random().toString(36)[2]).join('');
        this.emailReceiptTokenTarget.value = token;
        this.emailAddressTarget.value = `${token}@tguk-expenses.com`;
    }

    // Event handler for when the user hits the 'Copy to Clipboard' button.  Selects the text, copies to the clipboard
    // and hides the modal.  Note, that the form also generates a PATCH request in the usual way.
    copyToClipboard(event) {
        this.emailAddressTarget.select();
        document.execCommand('copy');
        $(this.modalTarget).modal('hide');
    }
}
