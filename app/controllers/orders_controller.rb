
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

  def interswitch_transactions
      if current_user.admin?
        @orders = Order.includes(:payment).where(:payment_method=>"interswitch").all.group_by{ |t| t.created_at.beginning_of_month }
      else
        respond_to do |format|
          format.html {redirect_to root_url, alert: "Access Denied"}
        end
      end
  end

  def wallet_transactions
    if current_user.admin?
      @orders = Order.all.where(:payment_method=>"wallet").group_by{ |t| t.created_at.beginning_of_month }
    else
      respond_to do |format|
        format.html {redirect_to root_url, alert: "Access Denied"}
      end
    end
  end

  def show
    @order ||= Order.find(params[:id])
    if current_user == @order.user
      @order = Order.find(params[:id])
      check_order_status
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
        format.html { redirect_to @order, alert: "This order cannot be canceled" }
        format.json { head :no_content }
      end
    end
  end

  def check_order_status
      if(@order.processing?)
        query_order_status(@order)
      end
   end
end
