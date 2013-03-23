class AirtelsController < ApplicationController
  def index
    @airtel_credit = Airtime.airtel_credit.open_credits.select([:name, :price]).uniq.order("price asc")
  end
end
