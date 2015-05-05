class BagTag < ActiveRecord::Base
	has_many :children, class_name: "BagTag", foreign_key: "parent_id"
	belongs_to :parent, class_name: "BagTag"
	has_and_belongs_to_many :bag_items, join_table: "bag_items_bag_tags"

	has_one :crawl_bag_page_manager
	has_many :crawl_bag_detail_manager
end
