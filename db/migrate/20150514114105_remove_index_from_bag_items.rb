class RemoveIndexFromBagItems < ActiveRecord::Migration
  def change
    remove_index :bag_items, :height
    remove_index :bag_items, :width
    remove_index :bag_items, :depth
    remove_index :device_items, :height
    remove_index :device_items, :width
    remove_index :device_items, :depth
  end
end
