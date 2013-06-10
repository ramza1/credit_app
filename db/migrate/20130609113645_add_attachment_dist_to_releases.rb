class AddAttachmentDistToReleases < ActiveRecord::Migration
  def self.up
    change_table :releases do |t|
      t.attachment :dist
    end
  end

  def self.down
    drop_attached_file :releases, :dist
  end
end
