include OrdersHelper
class OrderMailer < ActionMailer::Base
  def order_notice(order)
    @order = order
    mail :to => order.user.email, :subject => "Transaction #{order.state}", :from => "noreply@poploda.com"
  end
end
