class OrdersController < ApplicationController
  before_filter :authenticate_user!

  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      if current_user == @user || current_user.admin?
        @page=(params[:page]||1).to_i
        @per_page  = (params[:per_page] || 10).to_i
        @count= @user.orders.count
        @orders = @user.orders.page(@page).per_page(@per_page).order("created_at desc").group_by{ |t| t.created_at.beginning_of_month }
      else
        respond_to do |format|
          format.html {redirect_to root_url, alert: "Access Denied"}
        end
      end
    elsif current_user.admin?
      @page=(params[:page]||1).to_i
      @per_page  = (params[:per_page] || 10).to_i
      @count=Order.count
      @orders = Order.page(@page).per_page(@per_page).order("created_at desc").all.group_by{ |t| t.created_at.beginning_of_month }
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

  def pay_view
    respond_to do |format|
      format.js
    end
  end

  def show
    @order ||= Order.find(params[:id])
    if (current_user == @order.user||current_user.admin?)
      @order = Order.find(params[:id])
     else
      respond_to do |format|
        format.html {redirect_to root_url, alert: "404 not authorized"}
      end
    end
  end

  def destroy
    @order = Order.find(params[:id])
    if @order && @order.user==current_user
    if @order.pending?
      @order.cancel
      @order.destroy
      respond_to do |format|
        format.html { redirect_to user_orders_path(current_user) }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to @order, alert: "This order cannot be canceled" }
        format.json { head :no_content }
      end
      end
      else
      respond_to do |format|
        format.html { redirect_to @order, alert: "Unauthorized" }
        format.json { head :no_content }
      end
    end
  end

  def check_order_status
    if (current_user.admin?)
      @order = Order.find(params[:id])
      view_context.query_order_status(@order)
    else
      respond_to do |format|
        format.html {redirect_to root_url, alert: "404 not authorized"}
      end
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
