class DeviceBrand < ActiveRecord::Base
	# Ancestry => https://github.com/stefankroes/ancestry
	has_many :children, class_name: "DeviceBrand", foreign_key: "parent_id"
	belongs_to :parent, class_name: "DeviceBrand"
	
	has_many :device_items	
end
