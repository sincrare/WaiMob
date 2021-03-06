import consumer from "./consumer"

$(function() {
  const documentChannel = consumer.subscriptions.create({
    channel: 'DocumentChannel',
    document_id: $('#js-document').data('document-id')
  }, {
    connected() {
      // Called when the subscription is ready for use on the server
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
    },

    received: function (data) {
      const content = data['content'];
      const row_id = data['id'];
      const position = data['position'];

      if (position) {
        // TODO: 前の行がなくても追加できるようにする
        const previous_row = $(document.querySelectorAll('.js-document__row')[parseInt(position)-2])
        const new_el = $(`<p id="${row_id}" class="js-document__row">${content}</p>`) 
        previous_row.after(new_el)
      } else {
        $(`#${row_id}`).text(content);
      }
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
    },

    removeLine: function (id) {
      return this.perform('remove_line', {
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

  const removeLine = (e) => {
    console.log('remove line')
    documentChannel.removeLine($(e.target).data("id"))
  }

  $(document).on('keyup', '.js-document__row-text-box', function (e) {
    console.log(e.keyCode)
    if (e.keyCode === 13) {
      addNewLine(e)
      return e.preventDefault();
    } else if (e.keyCode === 8 && e.currentTarget.value === '') {
      removeLine(e)
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
    textBox.offset({ top: p_rect.top - 1, left: p_rect.left - 1 })
  })
})
