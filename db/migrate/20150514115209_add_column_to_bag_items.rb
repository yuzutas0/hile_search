class AddColumnToBagItems < ActiveRecord::Migration
  def change
    add_column :bag_items, :long_side, :integer, :null => false, :default => 0
    add_index :bag_items, :long_side
    add_column :bag_items, :middle_side, :integer, :null => false, :default => 0
    add_index :bag_items, :middle_side
    add_column :bag_items, :short_side, :integer, :null => false, :default => 0
    add_index :bag_items, :short_side
  end
end
