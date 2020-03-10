class DocumentChannel < ApplicationCable::Channel
  def subscribed
    stream_from "document_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def append(data)
    # jsで実行されたspeakのmessageを受け取り、room_channelのreceivedにブロードキャストする
    ActionCable.server.broadcast 'document_channel', chunk: data['chunk']
  end
end
