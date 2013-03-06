class Order < ActiveRecord::Base
  attr_accessible :amount, :name
  attr_accessible :credit_id, as: :admin

  #validates :amount, :name, :user_id, :pin, :pin_id, :presence => true
  belongs_to :user
  validates :credit_id, :presence => true, :uniqueness => true
  belongs_to :credit

  scope :completed_orders, -> {with_state(:complete)}
  scope :closed_orders, -> {with_state(:closed)}
  scope :pending_orders, -> {with_state(:pending)}

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

  def self.delete_closed_orders
    self.pending_orders.order_to_remove.find_each do |order|
      order.cancel
      order.credit.canceled
      order.destroy
    end
  end
end
