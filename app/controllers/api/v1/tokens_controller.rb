require "ruby_bosh"
include WalletsHelper
class Api::V1::TokensController< ApplicationController
before_filter :restrict_access,:except=>[:create,:web_pay_mobile,:interswitch_notify]
skip_before_filter :verify_authenticity_token


def create
  phone_number = params[:phone_number]
  password = params[:password]
  if request.format != :json
    render :status=>406, :json=>{:status=>"failed",:message=>"The request must be json"}
    return
  end

  if phone_number.nil? or password.nil?
    render :status=>400,
           :json=>{:status=>"failed",:message=>"The request must contain the user phone number and password."}
    return
  end

  @user=User.find_by_phone_number(phone_number)

  if @user.nil?
    logger.info("User #{phone_number} failed signin, user cannot be found.")
    render :status=>401, :json=>{:status=>"failed",:message=>"User cannot be found"}
    return
  end

  # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
  @user.ensure_authentication_token!

  if not @user.valid_password?(password)
    #logger.info("User #{phone_number} failed signin, password \"#{phone_number}\" is invalid")
    render :status=>401, :json=>{:status=>"failed",:message=>"Invalid email or password."}
    else
    end
end

def users
end

def sign_out
  @user.reset_authentication_token!
  render :status=>200, :json=>{:status=>"success",:token=>params[:id]}
end

def airtimes

      #@airtimes= Airtime.fetch_cards(params[:card_type]).open_credits.uniq(:price).order("price asc")
      if(params[:card_type]=="mtn")
      @credits = Airtime.mtn_credit.open_credits.select([:name, :price]).uniq.order("price asc")
      elsif(params[:card_type]=="glo")
      @credits = Airtime.glo_credit.open_credits.select([:name, :price]).uniq.order("price asc")
      elsif(params[:card_type]=="etisalat")
      @credits = Airtime.etisalat_credit.open_credits.select([:name, :price]).uniq.order("price asc")
      elsif(params[:card_type]=="airtel")
      @credits = Airtime.airtel_credit.open_credits.select([:name, :price]).uniq.order("price asc")

      end
end

def mobile_purchase
    @credit = Airtime.open_credits.not_sold(params[:name]).first
    if @credit
      if @user.account_balance >= @credit.price
        @order = @user.orders.create({:credit_id => @credit.id}, as: :admin)
        if @order.save
         @order.credit.assigned_to_order
         @user.deduct_user_credits(@order.credit.price)
         @order.credit.payment_complete
         @order.purchase
         @credits= Airtime.fetch_cards(params[:card_type]).open_credits.uniq.order("price asc")
        else
          @order.destroy
          render status: 200, :json=>{:message=>"Card is out of stock",:status=>"failed"}
        end
      else
        render status: 200,:json=>{:message=>"Your account is too low for this transaction. Please fund your account",:status=>"failed"}
      end
    else
      render status:200,:json=>{:message=>"Card is out of stock",:status=>"failed"}
    end
end

def create_airtime_order
    @airtime = Airtime.open_credits.not_sold(params[:q_name]).first
    if @airtime
      @wallet= @user.wallet
      if @wallet.account_balance >= @airtime.price
        @order=PurchaseOrder.new({:item => @airtime})
        @order.user=@user
        @order.amount=@airtime.price
        @order.name=@airtime.name
        if @order.save
          @order.item.assigned_to_order
        else
          render status: 200, :json=>{:message=>"Sorry, your transaction could not be processed, Please try again Later",:status=>"failed"}
        end
      else
        render status: 200,:json=>{:message=>"Your account is too low for this transaction. Please fund your account",:status=>"failed"}
      end
    else
      render status:200,:json=>{:message=>"Card is out of stock",:status=>"failed"}
    end
end

def create_money_order
    @order= MoneyOrder.new(params[:money_order])
    if(@order)
      @order.name=@user.wallet.name
      @order.user=@user
      @order.item=@user.wallet
      @order.payment_method="interswitch"
      logger.info("Order: #{@order.payment_method}")
      if @order.save
      else
        @order.destroy
        data={}
        data[:message]=@order.errors[:amount].join(",")
        data[:status]="failed"
        render status:200,:json=>data.to_json
      end
      else
        data={}
        data[:message]=@order.errors[:amount].join(",")
        data[:status]="failed"
        render status:200,:json=>data.to_json
    end
end

def cancel_order
    @order = Order.find_by_transaction_id(params[:transaction_id])
    if(@order)
    if @order.pending?
      @order.cancel

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
    else
      respond_to do |format|
        format.html { redirect_to @order, notice: "Order not found" }
        format.json {render :status=>404, :json=>{:message=>"Order not found",:status=>"failed"}}
      end
      end
end

def charge_order
    @order = Order.find_by_transaction_id(params[:transaction_id])
    if(@order)
      @order.payment_method=params[:payment_method]
      if @order.save
        case @order.payment_method
          when "wallet"
            process_charge_from_wallet
          when "interswitch"
        end
      else
        @order.pend
        respond_to do |format|
          format.json {render status: 200,:json=>{:message=>"Invalid Payment Method",:status=>"failed"}}
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to @order, notice: "Order not found" }
        format.json {render :status=>404, :json=>{:message=>"Order not found",:status=>"failed"}}
      end
    end
end


def wallet_pay
  @order = Order.includes([{:user=>:wallet},:item]).find_by_transaction_id(params[:transaction_id])
  if(@order)
    if verify_mac(params)
      @order.payment_method= "wallet"
      if @order.pending?
        @order.process
        @wallet=@order.user.wallet
        if @wallet.account_balance >=@order.total_amount
          @wallet.debit_wallet(@order.total_amount)
          @order.success
          @order.save
        else
          @order.response_code="51"
          @order.response_description="Insufficient funds. Please fund your account"
          @order.failure
          @order.save
        end
      else
        respond_to do |format|
          format.html {redirect_to @order, alert: "Invalid Transaction",status:404}
          format.json {render status: 200,:json=>{:message=>"Transaction Already Processed",:status=>"failed"}}
        end
      end
    else
      respond_to do |format|
        format.html {redirect_to @order, alert: "Invalid Transaction",status:404}
        format.json {render status: 200,:json=>{:message=>"Invalid Transaction",:status=>"failed"}}
      end
    end
  else
    respond_to do |format|
      format.html {redirect_to @order, alert: "Transaction does not exist",status:404}
      format.json {render status: 200,:json=>{:message=>"Transaction does not exist",:status=>"failed"}}
    end
  end
end

def messages
    @page=(params[:page]||1).to_i
    @per_page = (params[:per_page] || 10).to_i
    @per_page=@per_page<100?@per_page:100
    @count=@user.orders.completed_orders.count
    @orders = @user.orders.completed_orders.includes(:item).page(@page).per_page(@per_page).order("created_at desc")
    @params={:page=>@page+1 , :per_page=>@per_page}
    @remaining=((@page*@per_page) < @count) ? true : false
    @empty=(@count==0 ) ? true : false
end

def bind
     begin
      logger.info "authenticating #{@user.phone_number} with password #{@user.phone_number}"
      @session_jid, @session_id, @session_random_id =
      RubyBOSH.initialize_session("#{@user.phone_number}@rzaartz.local",@user.phone_number, "http://localhost:5280/http-bind")
      # RubyBOSH.initialize_session("paul@rzaartz.local","foo", "http://localhost:5280/http-bind")
      render :json => {
          :jid=>@session_jid,
          :sid=>@session_id,
          :rid=>@session_random_id,
          :status=>"success"
      }, :status => "200"
    rescue Exception => e
      logger.info "Error connecting:,#{e.message}"
      logger.warn $!.backtrace.collect { |b| " > #{b}" }.join("\n")
      render :status=>404, :json=>{:message=>"Connection failed",:status=>"failed"}
    end
end

  def web_pay_mobile
    @user=User.find_by_authentication_token(params[:token])
    if(@user)
    @order = Order.find_by_transaction_id(params[:transaction_id])
    if(@order)
    else
      @error="Transaction does not exist"
    end
    else
      @error="Unauthorized"
    end
    render :layout => "mobile"
  end

def interswitch_notify
  @txn_ref = params[:txnref]
  @order=Order.find_by_transaction_id(@txn_ref)
  if(@order)
    @order.payment_method="interswitch"
    @order.save
    @order.process
    query_order_status(@order)
    #notify
    #RestClient.post "http://localhost:3001/notify_transaction", { :phone_number => @order.user.phone_number,:transaction_id=>@order.transaction_id }.to_json, :content_type => :json, :accept => :json
    response = Typhoeus::Request.post("http://localhost:3001/notify_transaction", :body => {:phone_number => @order.user.phone_number,:transaction_id=>@order.transaction_id}.to_json)
    if !response.success?
      #raise response.body
    end
  end
  render :layout => "mobile"
end

  private
  def process_charge_from_wallet
    if @order.ready_to_pay?
      @item = @order.item
      @wallet=@user.wallet
      if @wallet.account_balance >= @order.amount
        @wallet.debit_wallet(@order.amount)
        @item.payment_complete
        @order.purchase
        CreditNotice.credit_notice(@user, @item.pin).deliver if @order.item_type=="Airtime"
        respond_to do |format|
          format.json
        end
      else
        respond_to do |format|
          format.json {render status: 200,:json=>{:message=>"Your account is too low for this transaction. Please fund your account",:status=>"failed"}}
        end
      end
    elsif @order.already_processed?
      respond_to do |format|
        format.json {render status: 200,:json=>{:message=>"This order is already complete",:status=>"failed"}}
      end
    else
      respond_to do |format|
        format.json  {render status: 200,:json=>{:message=>"Invalid Transaction",:status=>"failed"}}
      end
    end
  end

  
  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
       @user=User.find_by_authentication_token(token)
    end
  end
end




