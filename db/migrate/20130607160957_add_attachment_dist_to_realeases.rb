class AddAttachmentDistToRealeases < ActiveRecord::Migration
  def self.up
    change_table :realeases do |t|
      t.attachment :dist
    end
  end

  def self.down
    drop_attached_file :realeases, :dist
  end
end
