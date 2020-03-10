import consumer from "./consumer"

const documentChannel = consumer.subscriptions.create("DocumentChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received: function(data) {
    return alert(data['chunk']);
  },

  append: function(chunk) {
    return this.perform('append', {
      chunk: chunk
    });
  }
});

$(document).on('keypress', '[data-behavior~=document_editor]', function(event) {
  if (event.keyCode === 13) {
    documentChannel.append(event.target.value);
    event.target.value = '';
    return event.preventDefault();
  }
});