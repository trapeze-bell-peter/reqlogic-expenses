import consumer from "./consumer";

consumer.subscriptions.create("NotificationsChannel", {
  connected: function() {},
  disconnected: function() {},

  // Called when there's incoming data on the websocket for this channel
  received: function(data) {
    console.log('Incoming notification');

    document.getElementById('notifications').innerHTML = data.msg_html;
    document.getElementById(`expense-entry-${data.expense_entry_id}`).classList.add('alert-success');
  }
});
