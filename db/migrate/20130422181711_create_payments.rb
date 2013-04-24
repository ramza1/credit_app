class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :payment_reference
      t.string :retrieval_reference_number
      t.belongs_to :order
      t.string :card_number
      t.date  :transaction_date
      t.decimal :amount,     :precision => 10, :scale => 0, :default => 0, :null => false
      t.timestamps
    end
    add_index :payments, :payment_reference,:unique => :true
    add_index :payments, :retrieval_reference_number,:unique => :true
    add_index :payments, :order_id,:unique => :true
  end
end
