class MtnsController < ApplicationController
  def index
    @mtn_credit = Credit.mtn_credit.select([:name, :price]).uniq.order("price asc")
  end
end
