class DocumentChannel < ApplicationCable::Channel
  def subscribed
    stream_from "document_channel_#{params['document_id']}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def append(data)
    document = Document.find(params['document_id'])
    # FIXME: ここで保存失敗したらどうする？
    document.append_content!(data['chunk'])

    # jsで実行されたspeakのmessageを受け取り、room_channelのreceivedにブロードキャストする
    ActionCable.server.broadcast "document_channel_#{params['document_id']}", content: document.content
  end

  def sync(data)
    document = Document.find(params['document_id'])
    row = document.rows.find(data['id'].to_i)
    row.content = data['content']
    row.save!

    # jsで実行されたspeakのmessageを受け取り、room_channelのreceivedにブロードキャストする
    ActionCable.server.broadcast "document_channel_#{params['document_id']}", content: row.content, id: row.id
  end

  def newline(data)
    document = Document.find(params['document_id'])
    current_row = document.rows.find(data['id'].to_i)
    new_row = document.rows.build(content: 'new line')
    new_row.insert_at!(current_row.position + 1)

    # あたらしい行が入力されたことをブロードキャストする
    ActionCable.server.broadcast "document_channel_#{params['document_id']}", content: new_row.content, id: new_row.id, position: new_row.position

  end

  def remove_line(data)
    document = Document.find(params['document_id'])
    current_row = document.rows.find(data['id'].to_i)
    Row.transaction do
      current_row.remove_from_list
      current_row.destroy!
    end
  end
end
