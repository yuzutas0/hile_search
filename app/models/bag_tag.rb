class BagTag < ActiveRecord::Base
	has_many :children, class_name: "BagTag", foreign_key: "parent_id"
	belongs_to :parent, class_name: "BagTag"
	has_and_belongs_to_many :bag_items
end
