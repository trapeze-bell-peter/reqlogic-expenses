import consumer from "./consumer";

consumer.subscriptions.create("NotificationsChannel", {
  connected: function() {},
  disconnected: function() {},

  // Called when there's incoming data on the websocket for this channel
  received: function(data) {
    console.log('Incoming notification');

    document.getElementById('notifications').innerHTML = data.msg_html;

    fetch(`/expense_entries/${data.expense_entry_id}/edit`)
        .then( (response) => { return response.text(); } )
        .then( (expense_entry_html) => {
            let wrapper= document.createElement('div');
            wrapper.innerHTML= expense_entry_html;
            let existing_div = document.getElementById(`expense-entry-${data.expense_entry_id}`);
            existing_div.replaceWith(wrapper.firstChild);
        });
  }
});
