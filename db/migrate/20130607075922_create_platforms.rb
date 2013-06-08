class CreatePlatforms < ActiveRecord::Migration
  def change
    create_table :platforms do |t|
      t.string :os_name
      t.integer :download_times
      t.integer :release_id
      t.timestamps
    end
  end
end
