class CreateActiveUsers < ActiveRecord::Migration
  def change
    create_table :active_users do |t|
      t.string :phone_number
      t.string :jid
      t.timestamps
    end
    add_index :active_users, :phone_number ,:unique=>true
    add_index :active_users, :jid
  end
end
