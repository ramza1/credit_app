class CreateBulkCredits < ActiveRecord::Migration
  def change
    create_table :bulk_credits do |t|
      t.decimal :amount,     :precision => 10, :scale => 0, :default => 0, :null => false
      t.string :name
      t.decimal :unit,     :precision => 10, :scale => 0, :default => 0, :null => false

      t.timestamps
    end
  end
end
