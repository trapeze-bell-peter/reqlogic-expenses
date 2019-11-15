

class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications:#{current_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end

  # Called when message-form contents are received by the server
  def send_message(payload)
    message = Message.new(author: current_user, text: payload["message"])

    ActionCable.server.broadcast "chat", message: render(message) if message.save
  end
end
