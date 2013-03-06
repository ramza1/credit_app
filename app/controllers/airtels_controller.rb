class AirtelsController < ApplicationController
  def index
    @airtel_credit = Credit.airtel_credit.select([:name, :price]).uniq.order("price asc")
  end
end
