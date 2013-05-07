include WalletsHelper
class WalletsController < ApplicationController

  def deposit
     @order= MoneyOrder.new(params[:money_order])
     @order.name=current_user.wallet.name
     @order.user=current_user
     @order.item=current_user.wallet
     @order.payment_method="interswitch"
       if @order.save
         respond_to do |format|
           format.html { redirect_to order_path @order}
           format.json { head :ok }
         end
       else
         @order.destroy
         respond_to do |format|
           format.html {render :action=>:load_money}
           format.json { render json: @order.errors, status: :unprocessable_entity }
         end
       end
  end

  def load_money
   @order=   MoneyOrder.new
  end

  def account

  end

  def order_confirmation
    @order = Order.find(params[:id])
    if(@order)
    if @order.ready_to_process?
      interswitch_url=""+"?"
      interswitch_params={}   #watever der params r
      interswitch_params.each do|key,value|
      interswitch_url+=interswitch_url+"#{key}=#{value}"
      end
      redirect_to interswitch_url
    elsif @order.already_processed?
      respond_to do |format|
        format.html {redirect_to :account, notice: "This order is already complete"}
      end
    else
      respond_to do |format|
        format.html {redirect_to @order, notice: "Order Closed"}
      end
    end
    else
      respond_to do |format|
        format.html {redirect_to :account,:status=>404, notice: "Transaction does not exist"}
      end
    end

  end

  def notify_payment(transaction)
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


  def pay
    @order = Order.find_by_transaction_id(params[:transaction_id])
    if(@order && @order.user==current_user)
      if verify_mac(params)
      @order.payment_method= "wallet"
      if @order.pending?
        @order.process
        @wallet=current_user.wallet
        if @wallet.account_balance >=@order.total_amount
          @wallet.debit_wallet(@order.total_amount)
          @order.response_code="W00"
          @order.response_description=WALLET_RESPONSE_CODE_TO_DESCRIPTION[@order.response_code]
          @order.success
          respond_to do |format|
            format.html {redirect_to order_url(@order)}
          end
        else
          @order.response_code="W02"
          @order.response_description=WALLET_RESPONSE_CODE_TO_DESCRIPTION[@order.response_code]
          @order.failure
          respond_to do |format|
            format.html {redirect_to order_url(@order)}
          end
        end
      end
      else
        @order.response_code="W03"
        @order.response_description=WALLET_RESPONSE_CODE_TO_DESCRIPTION[@order.response_code]
        @order.failure
        respond_to do |format|
          format.html {redirect_to @order, alert: "Invalid Transaction",status:404}
        end
      end
    else
      respond_to do |format|
        format.html {redirect_to @order, alert: "Transaction does not exist",status:404}
      end
    end
  end
end
