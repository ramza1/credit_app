class MessagesController < ApplicationController
  layout 'contact'
  #layout 'application', only: :single_mail
  before_filter :authenticate_user!, only: [:single_mail, :send_single_mail]
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

  def single_mail
    @user = User.find(params[:user_id])
    render layout: 'application'
    unless @user
      redirect_to users_url, notice: "Please Select a user"
    end
  end

  def send_single_mail
    @user = User.find(params[:user_id])
     if params[:subject].present? && params[:message].present?
       subject =  params[:subject]
       message =  params[:message]
       email = @user.email
       MessageMailer.send_message_to_user(subject, message, email).deliver
       redirect_to single_mail_user_messages_url(@user), notice: "Message Sent to #{@user.email}"
     else
      redirect_to single_mail_user_messages_url(@user), alert: "Message and subject must be present"
     end
  end
end
