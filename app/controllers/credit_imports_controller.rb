class CreditImportsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  def new
    @credit_import = CreditImport.new
  end

  def create
    @credit_import = CreditImport.new(params[:credit_import])
    if @credit_import.save
      redirect_to root_url, notice: "Imported Credits successfully."
    else
      render :new
    end
  end
end
