class DocumentChannel < ApplicationCable::Channel
  def subscribed
    stream_from "document_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def append(data)
    # FIXME: どこからIDを取得するか？
    document = Document.find(1)
    # FIXME: ここで保存失敗したらどうする？
    document.append_content!(data['chunk'])

    # jsで実行されたspeakのmessageを受け取り、room_channelのreceivedにブロードキャストする
    ActionCable.server.broadcast 'document_channel', content: document.content
  end
end
