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
        format.html {redirect_to root_url, alert: "404 not authorised"}
      end
    end
  end

  def destroy
    @order = Order.find(params[:id])
    if @order.pending?
      @order.credit.canceled
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

  def load_credit
    @order = Order.find(params[:id])
    if @order.ready_to_process?
      @credit = @order.credit
      if current_user.account_balance >= @credit.price
        current_user.deduct_user_credits(@credit.price)
        @credit.payment_complete
        @order.purchase
        CreditNotice.credit_notice(current_user, @credit.pin).deliver
        respond_to do |format|
          format.html {redirect_to @order, notice: "Your order has been completed and your pin is #{@credit.pin}"}
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
