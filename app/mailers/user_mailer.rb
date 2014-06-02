class UserMailer < ActionMailer::Base
  def send_account_email(user)
    @user = user
    mail to: user.email, subject: "Poploda Account Info", from: "no_reply@poploda.com"
  end
end
