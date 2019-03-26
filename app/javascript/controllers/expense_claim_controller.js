import { Controller } from "stimulus";
import Rails from "rails-ujs";

export default class ExpenseClaimController extends Controller {
    static targets = [];

    connect() {
        console.log("Hello from expense_claim")
    }
}