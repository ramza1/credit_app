class GlosController < ApplicationController
  def index
    @glo_credit = Airtime.glo_credit.open_credits.select([:name, :price]).uniq.order("price asc")
  end
end
