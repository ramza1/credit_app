class ContactWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(id)
    contact = User.find(id)
    UserMailer.send_account_email(user).deliver
    User.transaction do
      contact.has_account = false
      contact.save
    end
  end
end