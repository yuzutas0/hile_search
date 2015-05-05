# encoding: utf-8
class Crawls::GetBagPage

	require 'open-uri'
	require 'kconv'
	require 'nokogiri'

	# rails runner Crawls::GetBagPage.execute
	def self.execute
		error_sequence = 0
		loop_sequence = 0

		loop {
			loop_sequence += 1
			puts "loop: " + loop_sequence.to_s

			manager = CrawlBagPageManager.find_by(done_flag: false)
			break if manager == nil

			begin
				puts " crawl!"
				page_url = manager.url + manager.progress_page.to_s
				sleep(2)
				this_page = Nokogiri::HTML(open(page_url, &:read).toutf8)
				error_sequence = 0
				self.get_detail_list(manager, this_page)	
			rescue
				puts "  error!"
				error_sequence += 1
				if error_sequence == 20
					puts "*** 20 sequence error ***"
					return
				end
			end
		}

		puts "*** everything done ***"
		return
	end



	def self.get_detail_list(manager, this_page)		

		detail_list = []
		loop {
			next_item = this_page.at("//*[@id=\"result_" + manager.progress_item.to_s + "\"]/div/div[2]/div[1]/a")
			next_item = this_page.at("//*[@id=\"result_" + manager.progress_item.to_s + "\"]/h3/a") if next_item.blank?
			break if next_item.blank?

			puts "detail_loop" + next_item.to_s[0..20]

			detail_url = next_item.attribute("href").to_s.match(/\/dp\//).post_match
			detail_url = "http://www.amazon.co.jp/dp/" + detail_url

			detail_obj = CrawlBagDetailManager.new(:url => detail_url, :bag_tag_id => manager.bag_tag.id)
			detail_list.push(detail_obj)

			manager.progress_item += 1
		}
		manager.progress_page += 1

		# insert
		CrawlBagDetailManager.import detail_list

		# is end_of_paging?
		next_page = this_page.at("//*[@id=\"pagnNextLink\"]")
		manager.done_flag = true if next_page.blank?
		manager.save
	end

end