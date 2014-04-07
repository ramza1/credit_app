class AirtimesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :except => [:load_credit, :create_order, :start_order]
  def index
    @page=(params[:page]||1).to_i
    @per_page  = (params[:per_page] || 20).to_i
    @count=User.count
    #@mtn_credit = Airtime.mtn_credit.open_credits.select([:name, :price]).uniq.order("price asc")
    #@glo_credit = Airtime.glo_credit.open_credits.select([:name, :price]).uniq.order("price asc")
    #@etisalat_credit = Airtime.etisalat_credit.open_credits.select([:name, :price]).uniq.order("price asc")
    #@airtel_credit = Airtime.airtel_credit.open_credits.select([:name, :price]).uniq.order("price asc")
    #@messages = current_user.orders.completed_orders
    @airtimes = Airtime.recently_added
  end

  # GET /airtimes/1
  # GET /airtimes/1.json
  def show
    if current_user.admin?
      @airtime = Airtime.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @airtime }
      end
    else
      respond_to do |format|
        format.html {redirect_to root_url, notice: "Not authorized"}
      end
    end
  end

  # GET /airtimes/new
  # GET /airtimes/new.json
  def new
    @airtime = Airtime.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @airtime }
    end
  end

  # GET /airtimes/1/edit
  def edit
    @airtime = Airtime.find(params[:id])
  end

  # POST /airtimes
  # POST /airtimes.json
  def create
    @airtime = Airtime.new(params[:airtime])

    respond_to do |format|
      if @airtime.save
        format.html { redirect_to @airtime, notice: 'Airtime was successfully created.' }
        format.json { render json: @airtime, status: :created, location: @airtime }
      else
        format.html { render action: "new" }
        format.json { render json: @airtime.errors, status: :unprocessable_entity }
      end
    end
  end

  def import
    Airtime.import(params[:file])
    redirect_to airtimes_url, notice: "Credits Imported"
  end

  # PUT /airtimes/1
  # PUT /airtimes/1.json
  def update
    @airtime = Airtime.find(params[:id])

    respond_to do |format|
      if @airtime.update_attributes(params[:airtimes])
        format.html { redirect_to @airtime, notice: 'Airtime was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @airtime.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /airtimes/1
  # DELETE /airtimes/1.json
  def destroy
    @airtime = Airtime.find(params[:id])
    @airtime.destroy

    respond_to do |format|
      format.html { redirect_to airtimes_url }
      format.json { head :no_content }
    end
  end

  def start_order
    @airtime = Airtime.open_credits.not_sold(params[:name]).first
    if @airtime
      @order=PurchaseOrder.new({:item => @airtime})
      @order.name=@airtime.name
      @order.user=current_user
      @order.amount=@airtime.price
      if @order.save
        @airtime.assigned_to_order
        respond_to do |format|
          format.html {redirect_to user_order_path(current_user, @order)}
        end
      else
        @order.destroy
        respond_to do |format|
          format.html {redirect_to root_url, alert: "Invalid Transaction Please try again"}
        end
      end
    else
      respond_to do |format|
        format.html {redirect_to root_url, alert: "Currently Out Of Stock. Please try again later"}
      end
    end
  end

  def purchase_airtime
    @order = Order.find_by_transaction_id(params[:transaction_id])
    if(@order)
      @order.payment_method= "wallet"
      if @order.ready_to_process?
        @airtime = @order.item
        @wallet=current_user.wallet
        if @wallet.account_balance >= @airtime.price
          @wallet.debit_wallet(@airtime.price)
          @airtime.payment_complete
          @order.purchase
          respond_to do |format|
            format.html {redirect_to order_url(@order), notice: "Your order has been completed and your pin is #{@airtime.pin}"}
          end
        else
          respond_to do |format|
            format.html {redirect_to airtimes_url, alert: "Insufficient funds. Please fund your account"}
          end
        end
      elsif @order.already_processed?
        respond_to do |format|
          format.html {redirect_to @order, notice: "This order is already complete"}
        end
      else
        respond_to do |format|
          format.html {redirect_to @order, notice: "Order Closed"}
        end
      end
    else
      respond_to do |format|
        format.html {redirect_to @order, alert: "Transaction does not exist",status:404}
      end
    end
  end

  def search
    @airtime = Airtime.find_by_pin(params[:pin].to_i)
  end

end