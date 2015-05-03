class AddImageToBagItems < ActiveRecord::Migration
  def change
    add_column :bag_items, :image_url, :string
  end
end
