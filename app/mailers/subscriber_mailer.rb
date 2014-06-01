class SubscriberMailer < ActionMailer::Base
  def send_news_letter(subscriber, message)
    @message = message
    @email = subscriber.email
    mail to: subscriber.email.gsub(",", ""), subject: "NEWSLETTER[#{message.title.titleize}]", from: "no_reply@poploda.com"
  end
end
