class EtisalatsController < ApplicationController
  def index
    @etisalat_credit = Airtime.etisalat_credit.open_credits.select([:name, :price]).uniq.order("price asc")
  end
end
