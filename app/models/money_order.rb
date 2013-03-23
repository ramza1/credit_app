class MoneyOrder < Order
  validates_numericality_of :amount,:greater_than_or_equal_to=>500,:less_than_or_equal_to=>100000, :only_integer => true ,:message => 'Enter a valid amount between 500 and 100000.it must be a whole number!'
  attr_accessible :item
end
