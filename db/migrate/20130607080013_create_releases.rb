class CreateReleases < ActiveRecord::Migration
  def change
    create_table :releases do |t|
      t.belongs_to :platform
      t.string :version
      t.timestamps
    end
  end
end
