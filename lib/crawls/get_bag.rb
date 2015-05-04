# encoding: utf-8
# rails runner Crawls::GetBag
class Crawls::GetBag

	require 'open-uri'
	require 'kconv'
	require 'nokogiri'

	# index page

	# bag-tag(roop)
	# new-product array / old-product array


	# メンズ => セカンド、ショルダー、トート、斜めかけ
	#️ メンズ各ブランド）
	# レディース => ハンド、斜めかけ、クラッチ、パーティー、ショルダー、フォーマル、トート、カゴ
	#️ レディース各ブランド
	# リュック・バックパック => メンズ、レディース、キッズ、ビジネス、スクール、アウトドア
	# ビジネスバック => PC収納、多ポケット、3Way...


	# メンズ => セカンド
	# http://www.amazon.co.jp/s/
	# rh=n%3A2016926051%2Cn%3A%212016927051%2Cn%3A2221077051%2Cn%3A2221074051%2Cn%3A2221205051%2Cn%3A2221211051&
	# page=3&ie=UTF8&qid=1430707642


	# page_urlのパースは前の段階で行う
	# next_item_numberは初期値0で投げる
	def self.page_to_detail(page_url, next_item_number)
		this_page = Nokogiri::HTML(open(page_url, &:read).toutf8)
		sleep(2)

		# get detail_url_list
		detail_url_list = []
		last_item = false

		until last_item do
			next_item = this_page.at("//*[@id=\"result_" + next_item_number.to_s + "\"]/div/div[2]/div[1]/a")
			next_item = this_page.at("//*[@id=\"result_" + next_item_number.to_s + "\"]/h3/a") if next_item.blank?

			if next_item.blank?
				last_item = true  
				next
			end

			detail_url = next_item.attribute("href").to_s.match(/\/dp\//).post_match
			detail_url = "http://www.amazon.co.jp/dp/" + detail_url
			detail_url_list.push(detail_url)

			next_item_number += 1
		end

		# get detail_info
		for detail_url in detail_url_list do
			puts detail_url
		end
		puts detail_url_list.count

		# is end_of_paging?
		next_page = this_page.at("//*[@id=\"pagnNextLink\"]")
		until next_page.blank?
			puts "*** return: true ***"
			return true
		end
		puts "*** return: false ***"
		return false
	end



	# detail(roop)
	def self.detail_to_array(detail_url)
		this_detail = Nokogiri::HTML(open(detail_url, &:read).toutf8)
		sleep(2)

		# name, url_dp
		detail_name   = this_detail.at("//*[@id=\"productTitle\"]").text
		detail_url_dp = detail_url.match(/\/dp\//).post_match

		# image
		detail_image  = this_detail.at("//*[@id=\"landingImage\"]")
		return if detail_image == nil
		detail_image  = detail_image.attribute("src")
		return if detail_image == nil
		return if detail_image.to_s.blank?

		# price
		detail_price_text = this_detail.at("//*[@id=\"priceblock_ourprice\"]").text
		[" ", "　", "¥", "￥", ",", "、"].each { |word|   detail_price_text.gsub!(word, "") }
		detail_price = detail_price_text.to_i

		# size
		detail_size_doc = this_detail.at("//*[@id=\"feature-bullets\"]/ul")
		return if detail_size_doc == nil
		return if detail_size_doc.to_s.blank?


		detail_width = self.get_size(["横", "ヨコ"], detail_size_doc)
		if detail_width == 0
			puts "********** not found width **********"
			return
		end

		detail_height = self.get_size(["縦", "タテ"], detail_size_doc)
		if detail_height == 0
			puts "********** not found height **********"
			return
		end

		detail_depth = self.get_size(["幅", "マチ"], detail_size_doc)
		if detail_depth == 0
			puts "********** not found depth **********"
			return
		end

		if detail_width == detail_height && detail_width == detail_depth
			puts "********** H,W,D = x,x,x pattern"
		end

		# object
		detail_item = BagItem.new(:name   => detail_name,
															:url_dp => detail_url_dp,
															:width  => detail_width - 1,
															:height => detail_height - 1,
															:depth  => detail_depth - 1,
															:price  => detail_price)
		# item * tag (detail_item.tag.push("this tag"))
		# array.push(detail_item)

		puts " name  : " + detail_item.name
		puts " url_dp: " + detail_item.url_dp
		puts " width : " + detail_item.width
		puts " height: " + detail_item.height
		puts " depth : " + detail_item.depth
		puts " price : " + detail_item.price
	end



	def self.get_size(size, detail_size_doc)
		result_integer = 0
		size.each { |word|
			result_string = detail_size_doc.to_s.match(/#{word}/)
			if result_string != nil
				result_string = result_string.post_match.match(/[0-9０-９]+/)
				if result_string != nil
					result_integer = result_string.tr!("０-９", "0-9").to_i 
					break
				end
			end
		}
		return result_integer
	end





	# rails runner Crawls::GetBag.test_page_to_detail
	def self.test_page_to_detail
		page_url = "http://www.amazon.co.jp/s/rh=n%3A2016926051%2Cn%3A%212016927051%2Cn%3A2221077051%2Cn%3A2221074051%2Cn%3A2221205051%2Cn%3A2221211051&page=3&ie=UTF8&qid=1430707642"
		next_item_number = 96
		self.page_to_detail(page_url, next_item_number)
	end
	# => last 3 lines
	# http://www.amazon.co.jp/dp/B00T2HSNHY
	# 48
	# *** return: true ***

	# rails runner Crawls::GetBag.test_detail_to_array
	def self.test_detail_to_array
		detail_url = "http://www.amazon.co.jp/dp/B00T2HSNHY"
		self.detail_to_array(detail_url)
	end



end