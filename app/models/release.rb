class Release < ActiveRecord::Base
  attr_accessible :version,:dist
  belongs_to :platform
  has_attached_file :dist

  validates :version,:platform_id, :presence => true
  validates_attachment :dist, :presence => true

end
