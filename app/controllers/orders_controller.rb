class OrdersController < ApplicationController
  before_filter :authenticate_user!
  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      if current_user == @user
        @orders = current_user.orders.group_by{ |t| t.created_at.beginning_of_month }
      else
        respond_to do |format|
          format.html {redirect_to root_url, alert: "Access Denied"}
        end
      end
    elsif current_user.admin?
      @orders = Order.all.group_by{ |t| t.created_at.beginning_of_month }
    end
  end

  def show
    @order ||= Order.find(params[:id])
    if current_user == @order.user
      @order = Order.find(params[:id])
    else
      respond_to do |format|
        format.html {redirect_to root_url, alert: "404 not authorized"}
      end
    end
  end

  def destroy
    @order = Order.find(params[:id])
    if @order.pending? || @order.processed?
      if(@order.item_type="Airtime")
        @order.item.canceled
      end
      @order.destroy

      respond_to do |format|
        format.html { redirect_to orders_path }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to @order, notice: "This order cannot be canceled" }
        format.json { head :no_content }
      end
    end
  end

  def purchase_airtime
    @order = Order.find_by_transaction_id(params[:purchase_order][:transaction_id])
    if(@order)
      @order.payment_method= params[:purchase_order][:payment_method]
      @order.processed
      if @order.save
        case @order.payment_method
          when "wallet"
            process_airtime_wallet_pay
          when "interswitch"
        end
      else
        @order.pend
        respond_to do |format|
          format.html {render :show}
        end
      end
    else
      respond_to do |format|
        format.html {redirect_to @order, alert: "Transaction does not exist",status:404}
      end
    end
  end

  private
  def process_airtime_wallet_pay
    if @order.processed?
      @airtime = @order.item
      @wallet=current_user.wallet
      if @wallet.account_balance >= @airtime.price
        @wallet.debit_wallet(@airtime.price)
        @airtime.payment_complete
        @order.purchase
        CreditNotice.credit_notice(current_user,@airtime.pin).deliver
        respond_to do |format|
          format.html {redirect_to order_url(@order), notice: "Your order has been completed and your pin is #{@airtime.pin}"}
        end
      else
        respond_to do |format|
          format.html {redirect_to credits_path, alert: "Insufficient funds. Please fund your account"}
        end
      end
    elsif @order.already_processed?
      respond_to do |format|
        format.html {redirect_to @order, notice: "This order is already complete"}
      end
    else
      respond_to do |format|
        format.html {redirect_to @order, notice: "Order Closed"}
      end
    end
  end


end
