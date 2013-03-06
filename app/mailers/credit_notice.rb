class CreditNotice < ActionMailer::Base
  def alert_notice(user)
    @receiver = user
    mail :to => user.email, :subject => "Credit Recharge Alert", :from => "noreply@poploader.com"
  end

  def credit_notice(user, pin)
    @user = user
    @pin = pin
    mail :to => user.email, :subject => "Your New Credit Pin", :from => "noreply@poploader.com"
  end

  def credit_amount_notice(amount_today, total_sold)
    @total_amount = amount_today
    @total_sold = total_sold
    @today_date = Date.today
    mail :to => "mezelee@yahoo.com", :subject => "Total amount added for the day at poploda", :from => "noreply@poploader.com"
  end

  def low_credit(credit_type)
    @credit_type = credit_type
    mail :to => "mezelee@yahoo.com", :subject => "Low credit on #{credit_type}", :from => "noreply@poploader.com"
  end
end
