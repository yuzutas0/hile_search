# encoding: utf-8
class Crawls::GetBagPage

	require 'open-uri'
	require 'kconv'
	require 'nokogiri'

	# rails runner Crawls::GetBagPage.execute
	def self.execute

	end



	def self.page_to_detail

		manager = CrawlBagPageManager.find_by(done_flag: false)
		page_url = manager.url + manager.progress_page
		this_page = Nokogiri::HTML(open(page_url, &:read).toutf8)
		sleep(1)

		# get detail_list
		detail_list = []
		loop {
			next_item = this_page.at("//*[@id=\"result_" + manager.progress_item.to_s + "\"]/div/div[2]/div[1]/a")
			next_item = this_page.at("//*[@id=\"result_" + manager.progress_item.to_s + "\"]/h3/a") if next_item.blank?
			break if next_item.blank?

			detail_url = next_item.attribute("href").to_s.match(/\/dp\//).post_match
			detail_url = "http://www.amazon.co.jp/dp/" + detail_url

			detail_list.push(detail_url)
			manager.progress_item += 1
		}
		manager.progress_page += 1

		# insert
		# code here + manager.bag_tag_id

		# is end_of_paging?
		next_page = this_page.at("//*[@id=\"pagnNextLink\"]")
		manager.done_flag = true if next_page.blank?
		manager.save
	end

end