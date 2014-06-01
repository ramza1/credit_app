class UserMailer < ActionMailer::Base
  def send_account_email(user)
    @user = user
    mail to: user.email, subject: "Blanck Digital Account Info", from: "no_reply@blanckdigital.com"
  end
end
