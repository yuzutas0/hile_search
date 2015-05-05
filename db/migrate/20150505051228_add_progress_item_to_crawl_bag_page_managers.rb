class AddProgressItemToCrawlBagPageManagers < ActiveRecord::Migration
  def change
    add_column :crawl_bag_page_managers, :progress_item, :integer, :null => false, :default => 0
  end
end
