class CreateCrawlBagPageManagers < ActiveRecord::Migration
  def change
    create_table :crawl_bag_page_managers do |t|
      t.integer :bag_tag_id
      t.text :url
      t.integer :progress_page, :null => false, :default => 1
      t.boolean :done_flag, :null => false, :default => false

      t.timestamps
    end
    add_index :crawl_bag_page_managers, :bag_tag_id
  end
end
