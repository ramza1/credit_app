class Platforms < ActiveRecord::Base
  attr_accessible :os_name
  has_many :releases,:dependent=>:destroy
end
