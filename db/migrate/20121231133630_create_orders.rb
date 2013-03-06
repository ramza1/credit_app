class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :name
      t.decimal :amount,     :precision => 10, :scale => 0, :default => 0, :null => false
      t.belongs_to :user
      t.belongs_to :credit
      t.string :state

      t.timestamps
    end
    add_index :orders, :user_id
    add_index :orders, :credit_id
  end
end
