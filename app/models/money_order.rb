class MoneyOrder < Order
  TRANSACTION_FEE = 0.015
  validates_numericality_of :amount,:greater_than_or_equal_to=> 100,:less_than_or_equal_to=>100000, :message => 'Enter a valid amount greater than 100'
  attr_accessible :item

  def name
     "Fund Wallet"
  end

  def total_amount
    self.amount
  end
end
