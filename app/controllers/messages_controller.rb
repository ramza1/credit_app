class MessagesController < ApplicationController
  layout 'contact'
  def new
    @message = Message.new
  end

  def create
    @message = Message.new(params[:message])
    if @message.valid?
      MessageMailer.send_message(@message).deliver
      redirect_to new_message_path, notice: "Message sent! Thank you for contacting us."
    else
      render "new"
    end
  end
end
