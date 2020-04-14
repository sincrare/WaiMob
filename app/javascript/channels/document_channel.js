import consumer from "./consumer"

const documentChannel = consumer.subscriptions.create("DocumentChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received: function (data) {
    const content = data['content'];
    const row_id  = data['id'];
    $(`#${row_id}`).text(content);
  },

  append: function (chunk) {
    return this.perform('append', {
      chunk: chunk
    });
  },

  sync: function (content, id) {
    console.log(content, id)
    return this.perform('sync', {
      content,
      id
    });
  },

  newline: function (id) {
    return this.perform('newline', {
      id
    });
  }
});

const submitRow = (e) => {
    console.log(e.target)
    console.log($(e.target).data("id"))
    documentChannel.sync(e.target.value, $(e.target).data("id"));
    e.target.value = '';

    const textBox = $('.js-document__row-text-box')
    textBox.addClass('document__row-text-box--hide')
}

const addNewLine = (e) => {
  console.log('new_line')
  console.log(e.target)
  console.log($(e.target).data("id"))
  documentChannel.newline($(e.target).data("id"))

  // TODO: 次の行にテキストボックスを表示させる
  const textBox = $('.js-document__row-text-box')
  textBox.addClass('document__row-text-box--hide')
}

$(document).on('keypress', '.js-document__row-text-box', function (e) {
  if (e.keyCode === 13) {
    // submitRow(e)
    addNewLine(e)
    location.reload()
    return e.preventDefault();
  }
});

$(document).on('blur', '.js-document__row-text-box', function (e) {
  submitRow(e)
});

// MEMO: textareaでのkeypres処理がわからんので、ボタンで発火させる
$(document).on('click', '.btn_sync', function (event) {
  documentChannel.sync(document.querySelector(".js-document-content").value);
  return event.preventDefault();
});

//
$(document).on("dblclick", ".js-document__row", function(e) {
  const textBox = $('.js-document__row-text-box')

  textBox.val(e.target.innerText)
  textBox.data("id", e.target.id)
  textBox.removeClass('document__row-text-box--hide')

  // 要素の位置座標を取得
  var p_rect = e.target.getBoundingClientRect()
  textBox.offset({ top: p_rect.top, left: p_rect.left })
})
