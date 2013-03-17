class AddTransactionIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :transaction_id, :integer
    add_index :orders, :transaction_id,:unique => :true
  end
end
