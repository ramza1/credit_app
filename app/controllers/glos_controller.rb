class GlosController < ApplicationController
  def index
    @glo_credit = Credit.glo_credit.select([:name, :price]).uniq.order("price asc")
  end
end
