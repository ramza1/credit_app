class MtnsController < ApplicationController
  def index
    @mtn_credit = Airtime.mtn_credit.open_credits.select([:name, :price]).uniq.order("price asc")
  end
end
