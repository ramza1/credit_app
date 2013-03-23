class CreateAirtimes < ActiveRecord::Migration
  def change
    create_table :airtimes do |t|
      t.decimal :price,         :precision => 10, :scale => 0, :default => 0,     :null => false
      t.string :encrypted_pin
      t.string :card_type
      t.boolean :sold,                                                 :default => false
      t.string :name
      t.string :state

      t.timestamps
    end
  end
end
