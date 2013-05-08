class Wallet < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user


  def on_order_success(order)
    self.transaction do
      add_to_wallet(order.amount)
    end
  end

  def on_order_failed(order)
    #
  end

  def on_order_cancelled(order)
    #
  end

  def credit_wallet(amount_add)
    self.transaction do
      add_to_wallet(amount_add)
    end
  end

  def debit_wallet(amount_minus)
    self.transaction do
      raise Exception unless self.account_balance > amount_minus
      subtract_from_wallet(amount_minus)
    end
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
    "Fund Wallet"
  end

  private

  def add_to_wallet(amount)
    update_account_balance(amount)
  end

  def subtract_from_wallet(amount)
    add_to_wallet(-amount)
  end

  def update_account_balance(new_credit)
    new_score = self.account_balance += new_credit
    self.update_attribute(:account_balance, new_score)
  end
end
