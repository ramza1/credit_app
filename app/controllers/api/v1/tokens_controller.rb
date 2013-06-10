require "ruby_bosh"
include WalletsHelper
class Api::V1::TokensController< ApplicationController
before_filter :restrict_access,:except=>[:create,:web_pay_mobile,:one_step_pay,:cancel_order,:interswitch_notify,:test_push,:test_notification,:test_web_pay_mobile,:test_web_pay_data,:test_one_step_pay]
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
    render :status=>404, :json=>{:status=>"failed",:message=>"User cannot be found"}
    return
  end

  # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
  @user.ensure_authentication_token!

  if not @user.valid_password?(password)
    #logger.info("User #{phone_number} failed signin, password \"#{phone_number}\" is invalid")
    render :status=>400, :json=>{:status=>"failed",:message=>"Invalid email or password."}
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
      if @order.save
        logger.info "payment method:#{@order.reload.payment_method}"
      else
        @order.destroy
        data={}
        data[:message]=@order.errors[:amount].join(" , ")
        data[:status]="failed"
        render status:200,:json=>data.to_json
      end
      else
        data={}
        data[:message]=@order.errors[:amount].join(" , ")
        data[:status]="failed"
        render status:200,:json=>data.to_json
    end
end

def cancel_order
    @user = User.find_by_authentication_token(params[:token])
    @order = Order.find_by_transaction_id(params[:transaction_id])
    if(@user)
      if(@order && @order.user=@user)
        if @order.pending?
          @order.cancel
          @order.destroy
          respond_to do |format|
            @notice="Order cancelled"
            format.html { render :layout => "mobile" }
            format.json { head :no_content }
          end
        else
          respond_to do |format|
            @notice="This order cannot be cancelled"
            format.html { render :layout => "mobile" }
            format.json { head :no_content }
          end
        end
     else
         respond_to do |format|
          @notice="Invalid Transaction"
          format.html { render :layout => "mobile" }
          format.json {render :status=>200, :json=>{:message=>@notice,:status=>"failed"}}
         end
     end
    else
      respond_to do |format|
        @notice="Unauthorized"
        format.html { render :layout => "mobile" }
        format.json {render :status=>404, :json=>{:message=>"Unauthorized",:status=>"failed"}}
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
  @order = Order.includes(:item).find_by_transaction_id(params[:transaction_id])
  if(@order && @order.user==@user)
        begin
          @order.payment_method= "wallet"
          if @order.pending?
            @order.process
            @wallet=@order.user.wallet
            if @wallet.account_balance >=@order.total_amount
              @order.response_code="W00"
              @order.response_description=WALLET_RESPONSE_CODE_TO_DESCRIPTION[@order.response_code]
              @order.success
              @wallet.debit_wallet(@order.total_amount)
              respond_to do |format|
                format.html {redirect_to order_url(@order)}
                format.json
              end
            else
              @order.response_code="W02"
              @order.response_description=WALLET_RESPONSE_CODE_TO_DESCRIPTION[@order.response_code]
              @order.failure
              respond_to do |format|
                format.html {redirect_to order_url(@order)}
                format.json {render status: 200,:json=>{:message=>@order.response_description,:status=>"failed"}}
            end
            end
          else
            respond_to do |format|
              format.html {redirect_to @order, alert: "Transaction Already Processed",status:404}
              format.json {render status: 200,:json=>{:message=>"Transaction Already Processed",:status=>"failed"}}
            end
          end
        rescue Exception => e
          logger.info "ERROR #{e.message}"
          respond_to do |format|
            format.html {redirect_to order_url(@order), alert: "Invalid Transaction"}
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
    @count=@user.orders.count
    @orders = @user.orders.includes([{:user=>:wallet},:item]).page(@page).per_page(@per_page).order("created_at desc")
    logger.info " Orders count:#{@count}"
    @params={:page=>@page+1 , :per_page=>@per_page}
    @remaining=((@page*@per_page) < @count) ? true : false
    @empty=(@count==0 ) ? true : false
end

def bind
     begin
      logger.info "authenticating #{@user.phone_number} with password #{@user.phone_number}"
      @session_jid, @session_id, @session_random_id =
      RubyBOSH.initialize_session("#{@user.phone_number}@poploda.com",@user.phone_number, "http://localhost:5281/http-bind")
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

def test_bind
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
    @token=params[:token]
    @user = User.find_by_authentication_token(@token)
    if(@user)
      @order = Order.includes([{:user=>:wallet},:item]).find_by_transaction_id(params[:transaction_id])
      @notice="Invalid Transaction" unless (@order && @order.user==@user) 
    else
      @notice="Unauthorized"
    end
    render :layout => "mobile"
  end

def one_step_pay
  @token=params[:token]
  @user = User.find_by_authentication_token(@token)
  if(@user)
    @order = Order.includes([{:user=>:wallet},:item]).find_by_transaction_id(params[:transaction_id])
    @notice="Invalid Transaction" unless (@order && @order.user==@user)
  else
    @notice="Unauthorized"
  end
  render :layout => "plain"
end

def test_one_step_pay
  #@order = Order.includes([{:user=>:wallet},:item]).find_by_transaction_id(params[:transaction_id])
  #@notification=encode_order_to_json
  redirect_to  :action => 'test_notification', :transaction_id => params[:transaction_id]
end

def test_notification
  @order = Order.includes([{:user=>:wallet},:item]).find_by_transaction_id(params[:transaction_id])
  @notification=encode_order_to_json
  render :one_step_pay,:layout => "plain"
end

def test_web_pay_mobile
  @order = Order.includes([{:user=>:wallet},:item]).find_by_transaction_id(params[:transaction_id])
  @notification=encode_order_to_json
  render :web_pay_mobile,:layout => "mobile"
end

def web_pay_data
  @order=Order.includes(:item).find_by_transaction_id(params[:transaction_id])
  @interswitch=view_context.map_order_to_interswitch_params(@order)
  if(@order && @order.user=@user)
    respond_to do |format|
      format.json
      format.js
    end
  else
    respond_to do |format|
      format.html {redirect_to @order, alert: "Transaction does not exist",status:404}
      format.json {render status: 200,:json=>{:message=>"Transaction does not exist",:status=>"failed"}}
      format.js {render status: 200,:json=>{:message=>"Transaction does not exist",:status=>"failed"}}
    end
  end
end

def test_web_pay_data
  @order = Order.includes([{:user=>:wallet},:item]).find_by_transaction_id(params[:transaction_id])
  if(@order)
  else
    @notice="Unauthorized"
  end
  render :web_pay_mobile,:layout => "mobile"
end

def interswitch_notify
  @txn_ref = params[:txnref]
  @order=Order.find_by_transaction_id(@txn_ref)
  if(@order)
    if (@order.pending?)
    @order.payment_method="interswitch"
    @order.process
    begin
        query_order_status(@order)
        @wallet=@order.user.wallet
        @item=@order.item
        @notification=encode_order_to_json
        respond_to do |format|
          format.html {}
          format.json {render :status=>200,:json=>encode_order_to_json}
        end
        rescue Exception => e
            logger.error "ERROR #{e.message}"
            #logger.warn $!.backtrace.collect { |b| " > #{b}" }.join("\n")
            @notice="An error occured while processing your transaction, please try again"
            @order.pend
          ensure
            if(@order.success?||@order.failed?)
              begin
                json= encode_order_to_json
                logger.info"JSON #{json}"
                request = Typhoeus::Request.new(
                    "http://localhost:8080/notify",
                    method:        :post,
                    body:          json,
                    params:        {phone_number: @order.user.phone_number}
                )
                request.run
                response = request.response
                logger.info"RESPONSE_CODE #{response.code}"
                  rescue Exception => e
                      logger.error "ERROR #{e.message}"
                      #logger.warn $!.backtrace.collect { |b| " > #{b}" }.join("\n")
                end
            end
        end
      end
      else
    @notice="Transaction does not exist"
  end
  render :layout => "mobile"
end

def test_push
  @order=Order.find_by_transaction_id(params[:transaction_id])
  #json=@order.to_json
  json=Jbuilder.encode do |json|
    json.notification do|json|
      json.type "transaction"
      json.transaction_id @order.transaction_id.to_s
      json.date @order.created_at.to_time.to_i.to_s
      json.item_type @order.item_type
      json.name @order.name
      json.amount @order.amount.to_s
      json.response_description @order.response_description
      json.response_code @order.response_code
      json.payment_method @order.payment_method
      json.amount_currency view_context.number_to_currency(@order.amount, unit: "NGN ", precision: 0)
      json.state @order.state
      if(@order.success?)
        json.item @order.item.to_json
        if(@order.payment_method=="wallet")
          json.wallet @order.user.wallet.to_json
          end
      end
      end
  end
  logger.info"JSON #{json}"
  request = Typhoeus::Request.new(
      "http://localhost:#{params[:port]}/notify",
      method:        :post,
      body:          json,
      params:        {phone_number: params[:phone_number]}
  )
  request.run
  response = request.response
  logger.info"RESPONSE_CODE #{response.code}"
  render :nothing => true
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

  def encode_order_to_json
    Jbuilder.encode do |json|
      status=view_context.order_status_message(@order)
      json.subject status[:message]
      json.body status[:description]
    	json.formatted_date  "#{@order.created_at.strftime('%a %d %b %Y')} #{@order.created_at.strftime("%I:%M%p")}"
    	json.date @order.created_at.to_time.to_i.to_s
      json.notification do|json|
        json.type "Transaction"
        json.transaction_id @order.transaction_id.to_s
        json.date @order.created_at.to_time.to_i.to_s
        json.item_type @order.item_type
        json.name @order.name
        json.amount @order.amount.to_s
        json.response_description @order.response_description
        json.response_code @order.response_code
        json.payment_method @order.payment_method
        json.amount_currency view_context.number_to_currency(@order.amount, unit: "NGN ", precision: 0)
        json.state @order.state
        if(@order.success?)
          json.item @order.item.to_json
          if(@order.payment_method=="wallet")
            json.wallet  @order.user.wallet.to_json
          end
        end
      end
    end
  end
end




