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
    @per_page  = (params[:per_page] || 2).to_i
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

  def bind
    begin
      logger.info "authenticating #{current_user.phone_number} with password #{current_user.phone_number}"
      @session_jid, @session_id, @session_random_id =
          RubyBOSH.initialize_session("#{current_user.phone_number}@rzaartz.local",current_user.phone_number, "http://localhost:5280/http-bind")
      # RubyBOSH.initialize_session("paul@rzaartz.local","foo", "http://localhost:5280/http-bind")
      render :json => {
          :jid=>@session_jid,
          :sid=>@session_id,
          :rid=>@session_random_id,
          :user=>{
              :name=>current_user.name,
              :id=>current_user.id
          }
      }, :status => 200
    rescue Exception => e
      logger.info "Error connecting:,#{e.message}"
      logger.warn $!.backtrace.collect { |b| " > #{b}" }.join("\n")
      render :json => {:error=>"failed"}, :status => 404
    end
  end

  def home

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

