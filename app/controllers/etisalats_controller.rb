class EtisalatsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @etisalat_credit = Airtime.etisalat_credit.open_credits.select([:name, :price]).uniq.order("price asc")
  end
end
