class WelcomeController < ApplicationController
  before_filter :authenticate_user!, :except => :index

  def index
    if current_user
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
    else
       @platforms=Platform.all
       render :home, layout: "home"
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
    @page=(params[:page]||1).to_i
    @per_page  = (params[:per_page] || 10).to_i
    @count=current_user.orders.completed_orders.count
    @messages = current_user.orders.completed_orders.page(@page).per_page(@per_page).order("created_at desc")
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



  def home

  end

  def faq

  end

  def contact_us

  end

  def about

  end

  def order_mail_test
    render :layout => "mobile"
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

