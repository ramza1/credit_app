class CreatePlatforms < ActiveRecord::Migration
  def change
    create_table :platforms do |t|
      t.string :os_name
      t.integer :download_count
      t.timestamps
    end
  end
end
