class DocumentChannel < ApplicationCable::Channel
  def subscribed
    stream_from "document_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def append(data)
    # FIXME: どこからIDを取得するか？
    document = Document.first
    # FIXME: ここで保存失敗したらどうする？
    document.append_content!(data['chunk'])

    # jsで実行されたspeakのmessageを受け取り、room_channelのreceivedにブロードキャストする
    ActionCable.server.broadcast 'document_channel', content: document.content
  end

  def sync(data)
    # FIXME: どこからIDを取得するか？
    document = Document.last
    row = document.rows.find(data['id'].to_i)
    row.content = data['content']
    row.save!

    # jsで実行されたspeakのmessageを受け取り、room_channelのreceivedにブロードキャストする
    ActionCable.server.broadcast 'document_channel', content: row.content, id: row.id
  end

  def newline(data)
    document = Document.first
    new_row = document.rows.build(content: 'newline')
    current_row = document.rows.find(data['id'].to_i)
    next_row = current_row.next_row
    Row.transaction do
      if current_row.present?
        if next_row
          next_row.previous_row = new_row
          next_row.save!
        end
        new_row.previous_row = current_row
        new_row.next_row = current_row.next_row
        current_row.next_row = new_row
        new_row.save!
        current_row.save!
      else
        raise 'current_row is not found.'
      end
    end
  end
end
