include InterswitchHelper
class Order < ActiveRecord::Base
  #has_friendly_id :transaction_id, :use_slug => false
  FIXNUM_MAX = (2**(0.size * 4 -2) -1)

  attr_accessible :amount, :name
  attr_accessible :item, as: :admin

  #validates :amount, :name, :user_id, :pin, :pin_id, :presence => true
  belongs_to :user
  validates  :item_id, :presence => true
  #validates :payment_method,:presence=>true,:if=>:ready_to_pay?
  belongs_to :item,:polymorphic=>true


  has_one :payment
  #before_validation :set_number
  after_create    :save_transaction_id

  scope :completed_orders, -> {with_state(:successful)}
  scope :closed_orders, ->    {with_state(:cancelled)}
  scope :pending_orders, ->   {with_state(:pending)}
  scope :failed_orders, ->   {with_state(:failed)}

  scope :order_to_remove, lambda { where('created_at > ?', 10.minutes.ago) }

  scope :today, where("date(created_at) = ?", Date.today)

  state_machine initial: :pending    do
  after_transition :processing => :successful, :do => :on_order_success
  after_transition :processing => :cancelled, :do => :on_order_failed
  after_transition :processing => [:cancelled,:successful], :do => :send_mail
  after_transition :pending => :cancelled, :do => :on_order_cancelled

  after_transition any => :processing do |order, transition|

  end

  event :success do
      transition :processing => :successful
  end

  event :failure do
    transition :processing => :cancelled
  end

  event :cancel do
      transition :pending => :cancelled
  end

  event :direct_pay do
    transition :pending => :successful
  end

  event :process do
    transition :pending => :processing
  end
  event :pend do
    transition :processing => :pending
  end
end

def send_mail
   OrderMailer.order_notice(self).deliver
end

def on_order_success
   self.item.on_order_success(self)
end

def on_order_failed
  self.item.on_order_failed(self)
  #release_item
end

def on_order_cancelled
  self.item.on_order_cancelled(self)
  #release_item
end

def processing?
  self.state == "processing"
end

def failed?
  self.state == "cancelled"
end

  def pending?
    self.state == "pending"
  end

 def transaction_message
   if response_code == "51"
     "Insufficient Funds"
   elsif response_code == "54"
       "Expired card"
   elsif response_code == "55"
      "Incorrect PIN"
   else
     "Transaction Error"
   end
end

  def success?
    self.state == "successful"
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
      self.transaction_id = SecureRandom.random_number(FIXNUM_MAX)
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
      if order.item_type == "Airtime"
       order.item.canceled
      end
    end
  end

def can_pay(user)
  (self.user==user)
end

def release_item
  self.item=nil
  save
end

def to_json
  Jbuilder.encode do |json|
    json.transaction_id self.transaction_id.to_s
    json.date self.created_at.to_time.to_i.to_s
    json.item_type self.item_type
    json.name self.name
    json.amount self.amount.to_s
    json.response_description self.response_description
    json.response_code self.response_code
    json.amount_currency helpers.number_to_currency(self.amount, unit: "NGN ", precision: 0)
    json.state self.state
    if(success?)
      json.item self.item.to_json
      if(payment_method=="wallet")
        json.wallet self.user.wallet.to_json
      end

    end
  end
end


def helpers
  ActionController::Base.helpers
end

end
