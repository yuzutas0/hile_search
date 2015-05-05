class CreateCrawlBagPageManagers < ActiveRecord::Migration
  def change
    create_table :crawl_bag_page_managers do |t|
      t.integer :bag_tag_id
      t.text :url
      t.integer :progress_page
      t.boolean :done_flag

      t.timestamps
    end
    add_index :crawl_bag_page_managers, :bag_tag_id
  end
end
