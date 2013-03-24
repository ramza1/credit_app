class Wallet < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user

  def credit_wallet(amount_add)
    self.add_to_wallet(amount_add)
  end

  def debit_wallet(amount_minus)
    self.subtract_from_wallet(amount_minus)
  end

  def add_to_wallet(new_credit)
    update_account_balance(new_credit)
  end

  def subtract_from_wallet(credit_to_deduct)
    add_to_wallet(-credit_to_deduct)
  end

  def self.total_amount
    sum(&:account_balance)
  end

  def self.total_account_balance
    sum(&:account_balance)
  end

  def self.total_amount_deducted
    Airtime.sold.sum(&:price)
  end

  def self.amount_pending
    Airtime.pending.sum(&:price)
  end

  def name
    "wallet"
  end

  private

  def update_account_balance(new_credit)
    new_score = self.account_balance += new_credit
    self.update_attribute(:account_balance, new_score)
  end
end
