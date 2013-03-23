class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :name
      t.decimal :amount,     :precision => 10, :scale => 0, :default => 0, :null => false
      t.string :type
      t.belongs_to :user
      t.belongs_to(:item, :polymorphic => true)
      t.string :state
      t.timestamps
    end
    add_index :orders, :user_id
    add_index :orders, :item_id
    add_index :orders, :item_type
  end
end
