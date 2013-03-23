class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,:token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :sms_notification, :phone_number, :subscription_duration
  # attr_accessible :title, :body
  has_many :orders

  validates :phone_number, :presence => true, :uniqueness => true

  validates_numericality_of :phone_number

  validates_length_of :phone_number, is: 11, :message => 'Invalid Phone Number'

  scope :weekly_mail_to_users, where("subscription_duration = ?", "weekly")
  scope :monthly_mail_to_users, where("subscription_duration = ?", "monthly")
  scope :daily_mail_to_users, where("subscription_duration = ?", "daily")

  has_one :wallet
  after_create :create_wallet

  def can_edit?(what)
    case what.class.name
      when 'User'
        self.admin? or what == self
      else
        raise "Unrecognized argument to can_edit? (#{what.inspect})"
    end
  end

  def self.daily_mail
    self.daily_mail_to_users.each do |user|
      CreditNotice.alert_notice(user).deliver
    end

  end

  def self.monthly_mail
    self.monthly_mail_to_users.each do |user|
      CreditNotice.alert_notice(user).deliver
    end
  end

  def self.weekly_mail
    self.weekly_mail_to_users.each do |user|
      CreditNotice.alert_notice(user).deliver
    end
  end






  private

  def create_wallet
    self.wallet=Wallet.new
    save
  end

  def update_account_balance(new_credit)
    new_score = self.account_balance += new_credit
    self.update_attribute(:account_balance, new_score)
  end
end