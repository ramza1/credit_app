class Api::V1::TokensController< ApplicationController
skip_before_filter :verify_authenticity_token
respond_to :json
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
  @user=User.find_by_authentication_token(params[:access_token])
  if @user.nil?
    logger.info("Token not found.")
    render :status=>404, :json=>{:status=>"failed",:message=>"Invalid token."}
  else
  end
end

def sign_out
  @user=User.find_by_authentication_token(params[:id])
  if @user.nil?
    logger.info("Token not found.")
    render :status=>404, :json=>{:status=>"failed",:message=>"Token not found"}
  else
    @user.reset_authentication_token!
    render :status=>200, :json=>{:status=>"success",:token=>params[:id]}
  end
end

def credits
    @user=User.find_by_authentication_token(params[:access_token])
    if @user.nil?
      logger.info("Token not found.")
      render :status=>404, :json=>{:status=>"failed",:message=>"Invalid token."}
    else
      #@credits= Credit.fetch_cards(params[:card_type]).open_credits.uniq(:price).order("price asc")
      if(params[:card_type]=="mtn")
      @credits = Credit.mtn_credit.open_credits.select([:name, :price]).uniq.order("price asc")
      elsif(params[:card_type]=="glo")
      @credits = Credit.glo_credit.open_credits.select([:name, :price]).uniq.order("price asc")
      elsif(params[:card_type]=="etisalat")
      @credits = Credit.etisalat_credit.open_credits.select([:name, :price]).uniq.order("price asc")
      elsif(params[:card_type]=="airtel")
      @credits = Credit.airtel_credit.open_credits.select([:name, :price]).uniq.order("price asc")
     end
    end
  end

def mobile_purchase
  @user=User.find_by_authentication_token(params[:access_token])
  if @user
    @credit = Credit.open_credits.not_sold(params[:name]).first
    if @credit
      if @user.account_balance >= @credit.price
        @order = @user.orders.create({:credit_id => @credit.id}, as: :admin)
        if @order.save
         @order.credit.assigned_to_order
         @user.deduct_user_credits(@order.credit.price)
         @order.credit.payment_complete
         @order.purchase
         @credits= Credit.fetch_cards(params[:card_type]).open_credits.uniq.order("price asc")
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
  else
    logger.info("Token not found.")
    render :status=>404, :json=>{:message=>"Invalid token.",:status=>"failed"}
  end
end

def create_order
  @user=User.find_by_authentication_token(params[:access_token])
  if @user
    @credit = Credit.open_credits.not_sold(params[:q_name]).first
    if @credit
      if @user.account_balance >= @credit.price
        @order = @user.orders.create({:credit_id => @credit.id}, as: :admin)
        if @order.save
          @order.credit.assigned_to_order
        else
          render status: 200, :json=>{:message=>"Sorry, your transaction could not be processed, Please try again Later",:status=>"failed"}
        end
      else
        render status: 200,:json=>{:message=>"Your account is too low for this transaction. Please fund your account",:status=>"failed"}
      end
    else
      render status:200,:json=>{:message=>"Card is out of stock",:status=>"failed"}
    end
  else
    logger.info("Token not found.")
    render :status=>404, :json=>{:message=>"Invalid token.",:status=>"failed"}
  end
end

def cancel_order
  @user=User.find_by_authentication_token(params[:access_token])
  if @user
    @order = Order.find(params[:transaction_id])
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
  else
    logger.info("Token not found.")
    respond_to do |format|
      format.html { redirect_to @order, notice: "This order cannot be canceled" }
      format.json render :status=>404, :json=>{:message=>"Invalid token.",:status=>"failed"}
    end
  end
end

def charge_order
  @user=User.find_by_authentication_token(params[:access_token])
  if @user
    @order = Order.find(params[:transaction_id])
    if @order.ready_to_process?
      @credit = @order.credit
      if @user.account_balance >= @credit.price
        @user.deduct_user_credits(@credit.price)
        @credit.payment_complete
        @order.purchase
        CreditNotice.credit_notice(@user, @credit.pin).deliver
        respond_to do |format|
          format.json
        end
      else
        respond_to do |format|
          format.json render status: 200,:json=>{:message=>"Your account is too low for this transaction. Please fund your account",:status=>"failed"}
        end
      end
    elsif @order.already_processed?
      respond_to do |format|
        format.json  render status: 200,:json=>{:message=>"This order is already complete",:status=>"failed"}

      end
    else
      respond_to do |format|
        format.json  render status: 200,:json=>{:message=>"Order Closed",:status=>"failed"}
      end
    end
  else
    logger.info("Token not found.")
    respond_to do |format|
      format.html { redirect_to @order, notice: "This order cannot be canceled" }
      format.json render :status=>404, :json=>{:message=>"Invalid token.",:status=>"failed"}
    end
 end
end

def charge_order_from_interswitch

end

def messages
  @user=User.find_by_authentication_token(params[:access_token])
  if @user
    @page=(params[:page]||1).to_i
    @per_page = (params[:per_page] || 10).to_i
    @per_page=@per_page<100?@per_page:100
    @count=@user.orders.completed_orders.count
    @orders = @user.orders.completed_orders.includes(:credit).page(@page).per_page(@per_page).order("created_at desc")
    @params={:page=>@page+1 , :per_page=>@per_page}
    @remaining=((@page*@per_page) < @count) ? true : false
    @empty=(@count==0 ) ? true : false
  else
    render :status=>404, :json=>{:message=>"Invalid token.",:status=>"failed"}
  end
end
end




