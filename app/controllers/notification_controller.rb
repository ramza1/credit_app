class NotificationController < ApplicationController
  def notify
    @transaction_id = params[:transaction_id]
    hydra = Typhoeus::Hydra.new
    request = Typhoeus::Request.new("https://voguepay.com/?v_transaction_id=#{@transaction_id}&type=json")
    request.on_complete do |response|
      transaction = Yajl::Parser.parse(response.body)  #or Yajl::Parser.parse(response.body)
      notify_info(transaction)
    end
    hydra.queue(request)
    hydra.run
  end

  def single_notify
    @transaction_id = params[:transaction_id]
    hydra = Typhoeus::Hydra.new
    request = Typhoeus::Request.new("https://voguepay.com/?v_transaction_id=#{@transaction_id}&type=json")
    request.on_complete do |response|
      transaction = Yajl::Parser.parse(response.body)  #or Yajl::Parser.parse(response.body)
      single_notify_info(transaction)
    end
    hydra.queue(request)
    hydra.run
  end

  def notify_info(transaction)
    if transaction["status"] == "Approved" && transaction["merchant_id"] == "#{MERCHANT_ID}"
      @credit = BulkCredit.find(transaction["transaction_id"])
      if @credit
        if transaction["total"].to_f >= @credit.amount.to_f
          current_user.award_user_credits(@credit.unit)
          create_order(@credit.name, @credit.amount, @credit.unit, @credit.id)
          render :text => "Your account has been credited with #{@credit.unit}", :layout => false
        else
          render :text => "Invalid transaction amount", :layout => false
        end
      else
        render :text => "Invalid transaction", :layout => false
      end
    else
      render :text => "Invalid Merchant ID or your transaction is not approved by the payment gateway", :layout => false
    end
  end

  def single_notify_info(transaction)
    if transaction["status"] == "Approved" && transaction["merchant_id"] == "#{MERCHANT_ID}"
      @order = Order.find(transaction["transaction_id"])
      if @order.ready_to_process?
        @credit = @order.credit
        if transaction["total"].to_f >= @credit.price.to_f
          @credit.payment_complete
          @order.purchase
          CreditNotice.credit_notice(current_user, @credit.pin).deliver
          render :text => "Transaction Complete. Your Order has been completed", :layout => false
        else
          render :text => "Invalid transaction Amount", :layout => false
        end
      elsif @order.already_processed?
        render :text => "Order is has been completed", :layout => false
      else
        render :text => "Order closed", :layout => false
      end
    else
      render :text => "Transaction declined", :layout => false
    end

  end
end