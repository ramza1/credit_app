class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.belongs_to :user
      t.decimal  "account_balance",        :precision => 10, :scale => 0, :default => 0
      t.timestamps
    end
  end
end
