class CreateReleases < ActiveRecord::Migration
  def change
    create_table :releases do |t|
      t.string :dist_url
      t.belongs_to :platform
      t.string :version
      t.integer :download_times
      t.timestamps
    end
  end
end
