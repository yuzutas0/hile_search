class AddColumnToDeviceItems < ActiveRecord::Migration
  def change
    add_column :device_items, :long_side, :integer, :null => false, :default => 0
    add_index :device_items, :long_side
    add_column :device_items, :middle_side, :integer, :null => false, :default => 0
    add_index :device_items, :middle_side
    add_column :device_items, :short_side, :integer, :null => false, :default => 0
    add_index :device_items, :short_side
  end
end
