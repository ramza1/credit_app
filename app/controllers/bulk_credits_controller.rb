class BulkCreditsController < ApplicationController
  # GET /bulk_credits
  # GET /bulk_credits.json
  def index
    @bulk_credits = BulkCredit.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bulk_credits }
    end
  end

  # GET /bulk_credits/1
  # GET /bulk_credits/1.json
  def show
    @bulk_credit = BulkCredit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bulk_credit }
    end
  end

  # GET /bulk_credits/new
  # GET /bulk_credits/new.json
  def new
    @bulk_credit = BulkCredit.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bulk_credit }
    end
  end

  # GET /bulk_credits/1/edit
  def edit
    @bulk_credit = BulkCredit.find(params[:id])
  end

  # POST /bulk_credits
  # POST /bulk_credits.json
  def create
    @bulk_credit = BulkCredit.new(params[:bulk_credit])

    respond_to do |format|
      if @bulk_credit.save
        format.html { redirect_to @bulk_credit, notice: 'Bulk credit was successfully created.' }
        format.json { render json: @bulk_credit, status: :created, location: @bulk_credit }
      else
        format.html { render action: "new" }
        format.json { render json: @bulk_credit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bulk_credits/1
  # PUT /bulk_credits/1.json
  def update
    @bulk_credit = BulkCredit.find(params[:id])

    respond_to do |format|
      if @bulk_credit.update_attributes(params[:bulk_credit])
        format.html { redirect_to @bulk_credit, notice: 'Bulk credit was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bulk_credit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bulk_credits/1
  # DELETE /bulk_credits/1.json
  def destroy
    @bulk_credit = BulkCredit.find(params[:id])
    @bulk_credit.destroy

    respond_to do |format|
      format.html { redirect_to bulk_credits_url }
      format.json { head :no_content }
    end
  end
end
