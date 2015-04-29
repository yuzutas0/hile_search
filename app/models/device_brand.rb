class DeviceBrand < ActiveRecord::Base
	has_many :children, class_name: "DeviceBrand", foreign_key: "parent_id"
	belongs_to :parent, class_name: "DeviceBrand"
	has_many :device_items
end
