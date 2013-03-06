class CreditsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :except => [:load_credit, :create_order, :start_order]
  def index
    @mtn_credit = Credit.mtn_credit.select([:name, :price]).uniq.order("price asc")
    @glo_credit = Credit.glo_credit.select([:name, :price]).uniq.order("price asc")
    @etisalat_credit = Credit.etisalat_credit.select([:name, :price]).uniq.order("price asc")
    @airtel_credit = Credit.airtel_credit.select([:name, :price]).uniq.order("price asc")
    @messages = current_user.orders.completed_orders
  end

  # GET /credits/1
  # GET /credits/1.json
  def show
    if current_user.admin?
      @credit = Credit.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @credit }
      end
    else
      respond_to do |format|
        format.html {redirect_to root_url, notice: "Not authorized"}
      end
    end
  end

  # GET /credits/new
  # GET /credits/new.json
  def new
    @credit = Credit.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @credit }
    end
  end

  # GET /credits/1/edit
  def edit
    @credit = Credit.find(params[:id])
  end

  # POST /credits
  # POST /credits.json
  def create
    @credit = Credit.new(params[:credit])

    respond_to do |format|
      if @credit.save
        format.html { redirect_to @credit, notice: 'Credit was successfully created.' }
        format.json { render json: @credit, status: :created, location: @credit }
      else
        format.html { render action: "new" }
        format.json { render json: @credit.errors, status: :unprocessable_entity }
      end
    end
  end

  def import
    Credit.import(params[:file])
    redirect_to credits_url, notice: "Credits Imported"
  end

  # PUT /credits/1
  # PUT /credits/1.json
  def update
    @credit = Credit.find(params[:id])

    respond_to do |format|
      if @credit.update_attributes(params[:credit])
        format.html { redirect_to @credit, notice: 'Credit was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @credit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /credits/1
  # DELETE /credits/1.json
  def destroy
    @credit = Credit.find(params[:id])
    @credit.destroy

    respond_to do |format|
      format.html { redirect_to credits_url }
      format.json { head :no_content }
    end
  end

  def start_order
    @credit = Credit.open_credits.not_sold(params[:name]).first
    if @credit
      @order = current_user.orders.create({:credit_id => @credit.id}, as: :admin)
      if @order.save
        @credit.assigned_to_order
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


end