<script>
    import { categories, fetchCategories } from './categories';

    let expense_entry;
</script>

<div id="{expense_entry.id}" class="{background}">
    <form>
        <div class="form-row align-items-top">
            <div class="form-group col-1">
               <input type="text" class="form-control" name="expense_entry[sequence]" readonly="true" value="{expense_entry.sequence}" />
            </div>
            <div class="form-group col-2">
                <input type="date" class="form-control" name="expense_entry[date]" value="{expense_entry.date}" />
            </div>
            <div class="form-group col-2">
                <select class="form-control" placeholder="Category" name="expense_entry[category]">
                    {#each $categories as category }
                        <option value="{category.id}">{category.name}</option>
                    {/each}
                </select>
            </div>
            <div class="form-group col-6">
                <div class="input-group">
                    <input type="text" name="expense_entry[description]">
                    en
                </div>
            </div>
        </div>
    </form>
</div>


.form-group.col-6
.input-group
= expense_entry_presenter.description
.input-group-append
- expense_entry_presenter.matching_cc_dropdown do |matching_cc_list|
.dropdown.dropleft
%button.btn.btn-outline-secondary.dropdown-toggle{ type: "button",
aria_haspopup: true, aria_expanded: false,
data: { toggle: 'dropdown' } }
.dropdown-menu
- matching_cc_list.each_pair do |category, matches|
%h6.dropdown-header= category
- matches.each do |match|
%a.dropdown-item{ h_ref: '#', data: { action: "click->expense-entry#copyDescriptionFromCC"} }= match
%button.btn.btn-outline-secondary{ data: { action: "click->expense-entry#clearDescription" } }
%i.fa.fa-times
.form-group.col-1
%span{ data: { toggle: 'modal', target: '#receipt-modal' } }
%button.expenses-button{ type: 'button', data: { toggle: 'tooltip',
placement: 'top',
title: 'Receipt',
action: 'click->expense-entry#receiptUpload' } }
%i.fas.fa-receipt.fa-2x.expenses-action-icon
.form-row.align-items-top.justify-content-end
.form-group.col-1= expense_entry_presenter.form_field :project, :text_field, id: "expense_entry_project_#{expense_entry.id}"
.form-group.col-1= expense_entry_presenter.vat
.form-group.col-1= expense_entry_presenter.qty
.form-group.col-1= expense_entry_presenter.unit_cost
.form-group.col-1= expense_entry_presenter.total_cost
.form-group.col-1
= expense_entry_presenter.delete_button
= expense_entry_presenter.insert_button
= expense_entry_presenter.copy_button

- if expense_entry.receipt
= ReceiptPresenter.create_receipt_presenter(self, expense_entry.receipt).render_for_modal