class Order < ActiveRecord::Base
  #has_friendly_id :transaction_id, :use_slug => false
  FIXNUM_MAX = (2**(0.size * 8 -2) -1)
  NUMBER_SEED     = 1001001001000
  CHARACTERS_SEED = 21

  attr_accessible :amount, :name
  attr_accessible :credit_id, as: :admin

  #validates :amount, :name, :user_id, :pin, :pin_id, :presence => true
  belongs_to :user
  validates :credit_id, :presence => true, :uniqueness => true
  belongs_to :credit
  #before_validation :set_number
  #after_create    :save_transaction_id

  scope :completed_orders, -> {with_state(:complete)}
  scope :closed_orders, ->    {with_state(:closed)}
  scope :pending_orders, ->   {with_state(:pending)}

  scope :order_to_remove, lambda { where('created_at < ?', 30.minutes.ago) }

  scope :today, where("date(created_at) = ?", Date.today)

  state_machine initial: :pending    do

    event :purchase do
      transition :pending => :complete
    end

    event :cancel do
      transition :pending => :closed
    end

    event :pend do
      transition :closed => :pending
    end

  end

  def ready_to_process?
    self.state == "pending"
  end

  def already_processed?
    self.state == "complete"
  end
  # Called before validation.  sets the order number, if the id is nil the order number is bogus
  #
  # @param none
  # @return [none]
  def set_number
    return set_transaction_id if self.id
    #self.transaction_id = (Time.now.to_i).to_s(CHARACTERS_SEED)## fake number for friendly_id validator
    begin
      self.transaction_id = SecureRandom.random_number(FIXNUM_MAX)
    end while self.class.exists?(transaction_id: transaction_id)
  end


  # sets the order number based off constants and the order id
  #
  # @param none
  # @return [none]
  def set_transaction_id
    begin
      self.transaction_id = SecureRandom.random_number(Integer.ma)
    end while self.class.exists?(transaction_id: transaction_id)
    logger.info("transaction id: #{self.transaction_id}")
  end

  def save_transaction_id
    set_transaction_id
    save
  end

  def self.delete_closed_orders
    self.pending_orders.order_to_remove.find_each do |order|
      order.cancel
      order.credit.canceled
      order.destroy
    end
  end
end
