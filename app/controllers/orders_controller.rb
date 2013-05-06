
class OrdersController < ApplicationController
  before_filter :authenticate_user!
  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      if current_user == @user
        @page=(params[:page]||1).to_i
        @per_page  = (params[:per_page] || 10).to_i
        @count=current_user.orders.count
        @orders = current_user.orders.page(@page).per_page(@per_page).order("created_at desc").group_by{ |t| t.created_at.beginning_of_month }
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
        @page=(params[:page]||1).to_i
        @per_page  = (params[:per_page] ||10).to_i
        @count=Order.where(:payment_method=>"interswitch").count
        @orders = Order.page(@page).per_page(@per_page).order("created_at desc").includes(:payment).where(:payment_method=>"interswitch").all.group_by{ |t| t.created_at.beginning_of_month }
      else
        respond_to do |format|
          format.html {redirect_to root_url, alert: "Access Denied"}
        end
      end
  end

  def wallet_transactions
    if current_user.admin?
      @page=(params[:page]||1).to_i
      @per_page  = (params[:per_page] || 10).to_i
      @count=Order.where(:payment_method=>"wallet").count
      @orders = Order.page(@page).per_page(@per_page).order("created_at desc").where(:payment_method=>"wallet").all.group_by{ |t| t.created_at.beginning_of_month }
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
    if @order.pending?
      @order.cancel
      #@order.destroy

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
      if(@order.processing? && @order.payment_method=="interswitch")
        query_order_status(@order)
      end
  end

  def search
    @q = params[:q]
    if current_user.admin?
      @orders = Order.where(:transaction_id => @q)
    else
      @orders = current_user.orders.where(:transaction_id => @q)
    end

  end
end
