class WelcomeController < ApplicationController
  before_filter :authenticate_user!, :except => :index
  def index
    @mtn_credit = Credit.mtn_credit.select([:name, :price]).uniq.order("price asc")
    @glo_credit = Credit.glo_credit.select([:name, :price]).uniq.order("price asc")
    @etisalat_credit = Credit.etisalat_credit.select([:name, :price]).uniq.order("price asc")
    @airtel_credit = Credit.airtel_credit.select([:name, :price]).uniq.order("price asc")
    @messages = current_user.orders.completed_orders.order("created_at desc")   if current_user
    @bulk_credits = BulkCredit.all
    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end
  def failure
    respond_to do |format|
      format.html {redirect_to root_url, notice: "Transaction Failed"}
    end
  end

  def thank_you
    respond_to do |format|
      format.html {redirect_to root_url, notice: "account credited"}
    end
  end

  def order
    @orders = current_user.orders.group_by{ |t| t.created_at.beginning_of_month }
  end

  def messages
    @messages = current_user.orders.completed_orders
  end

  def statistics
    if current_user.admin?
      @bulk_credits = BulkCredit.all
    else
      flash[:notice] = "not authorized"
      redirect_to root_path
    end

  end
end

