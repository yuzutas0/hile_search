class CreateJoinTableBagItemAndBagTag < ActiveRecord::Migration
  def change
    create_join_table :bag_items, :bag_tags do |t|
      # t.index [:bag_item_id, :bag_tag_id]
      # t.index [:bag_tag_id, :bag_item_id]
    end
  end
end
