class WelcomeController < ApplicationController
  before_filter :authenticate_user!, :except => :index
  def index
    @mtn_credit = Airtime.mtn_credit.open_credits.select([:name, :price]).uniq.order("price asc")
    @glo_credit = Airtime.glo_credit.open_credits.select([:name, :price]).uniq.order("price asc")
    @etisalat_credit = Airtime.etisalat_credit.open_credits.select([:name, :price]).uniq.order("price asc")
    @airtel_credit = Airtime.airtel_credit.open_credits.select([:name, :price]).uniq.order("price asc")
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
    stats
  end

  def airtime_statistics
    stats
  end

  def user_statistics
    stats
  end

  private
  def stats
    if current_user.admin?
      @bulk_credits = BulkCredit.all
    else
      flash[:notice] = "not authorized"
      redirect_to root_path
    end
  end
end

