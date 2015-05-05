class BagItem < ActiveRecord::Base
	has_and_belongs_to_many :bag_tags, join_table: "bag_items_bag_tags"
end
