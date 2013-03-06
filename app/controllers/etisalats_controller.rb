class EtisalatsController < ApplicationController
  def index
    @etisalat_credit = Credit.etisalat_credit.select([:name, :price]).uniq.order("price asc")
  end
end
