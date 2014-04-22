class GlosController < ApplicationController
  before_filter :authenticate_user!
  def index
    @glo_credit = Airtime.glo_credit.open_credits.select([:name, :price]).uniq.order("price asc")
  end
end
