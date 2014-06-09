class MessageMailer < ActionMailer::Base

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.message_mailer.send_message.subject
  #
  def send_message(message)
    @body = message.content
    @from = message.email
    @name = message.name
    @subject = message.subject

    mail to: "customercare@poploda.com", :subject => "new mail from #{message.name} - hall and johnson", :from => message.email
  end

  def send_message_to_user(subject, message, email)
     @message = message
     @email = email
     @subject = subject
     mail to: email, :subject => subject, :from => "admin@poploda.com"
  end
end
