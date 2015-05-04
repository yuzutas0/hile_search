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
			self.detail_to_array(detail_url)
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

		#️ url_dp
		detail_url_dp = detail_url.match(/\/dp\//).post_match
		# 既存チェック

		# name
		detail_name = this_detail.at("//*[@id=\"productTitle\"]").text
		detail_name.gsub!(" ", "")
		detail_name.gsub!("　", "")

		# image
		detail_image = this_detail.at("//*[@id=\"landingImage\"]")
		return if detail_image == nil
		detail_image = detail_image.attribute("src")
		return if detail_image == nil
		return if detail_image.to_s.blank?

		# price
		detail_price_text = this_detail.at("//*[@id=\"priceblock_ourprice\"]")
		detail_price_text = this_detail.at("//*[@id=\"priceblock_saleprice\"]") if detail_price_text == nil
		detail_price_text = detail_price_text.text
		[" ", "　", "¥", "￥", ",", "、"].each { |word|   detail_price_text.gsub!(word, "") }
		detail_price = detail_price_text.to_i

		# size
		detail_size_doc = this_detail.at("//*[@id=\"feature-bullets\"]/ul")
		return if detail_size_doc == nil
		return if detail_size_doc.to_s.blank?

		# if they say "size", focus it
		if detail_size_doc.to_s.match(/サイズ/) != nil
			detail_size_doc = detail_size_doc.to_s.match(/サイズ/).post_match
		end

		# get_size
		detail_width = self.get_size(["横", "ヨコ", "長", "幅", "Ｗ", "W"], detail_size_doc)
		detail_height = self.get_size(["縦", "タテ", "高", "厚", "Ｈ", "H"], detail_size_doc)
		detail_depth = self.get_size(["奥", "マチ", "マッチ", "幅", "厚","Ｄ", "D"], detail_size_doc)

		# get_size in other case
		if detail_width == detail_height && detail_width == detail_depth
			if detail_width == 0
				# size：19.5cm×11.5cm×4.3cm
				slicers = ["x", "×"]
				is_slice_pattern = self.is_slice_pattern(detail_size_doc, slicers)
				if is_slice_pattern["result"] == "1" || is_slice_pattern["result"] == "2"
					slicer = is_slice_pattern["slicer"]

					if detail_size_doc.to_s.match(/#{slicer}/).pre_match.size > 10
						detail_width_string = detail_size_doc.to_s.match(/#{slicer}/).pre_match.to_s[-10..-1].match(/[0-9０-９]+/)
					else
						detail_width_string = detail_size_doc.to_s.match(/#{slicer}/).pre_match.match(/[0-9０-９]+/)
					end
					detail_width = self.get_size_by_slicer(detail_width_string)

					detail_height_string = detail_size_doc.to_s.match(/#{slicer}/).post_match.match(/[0-9０-９]+/)
					detail_height = self.get_size_by_slicer(detail_height_string)
					
					if is_slice_pattern["result"] == "2"
						detail_depth_string = detail_size_doc.to_s.match(/#{slicer}/).post_match.match(/#{slicer}/).post_match.match(/[0-9０-９]+/)
						detail_depth = self.get_size_by_slicer(detail_depth_string)
					end
				end
			end
		end

		if detail_width == detail_height && detail_width == detail_depth
			puts "********** other pattern **********"
			return
		end

		if detail_width == 0 || detail_height == 0
			puts "********** not found width **********" if detail_width == 0
			puts "********** not found height **********" if detail_height == 0
			return
		end
		puts "********** not found depth **********" if detail_depth == 0

		# object
		detail_item = BagItem.new(:name      => detail_name,
															:url_dp    => detail_url_dp,
															:width     => detail_width,
															:height    => detail_height,
															:depth     => detail_depth,
															:price     => detail_price,
															:image_url => detail_image)
		# item * tag (detail_item.tag.push("this tag"))
		# array.push(detail_item)

		puts " name  : " + detail_item.name
		puts " url_dp: " + detail_item.url_dp
		puts " width : " + detail_item.width.to_s
		puts " height: " + detail_item.height.to_s
		puts " depth : " + detail_item.depth.to_s
		puts " price : " + detail_item.price.to_s
		puts " image : " + detail_item.image_url.to_s
	end



	def self.get_size(size, detail_size_doc)
		result_integer = 0
		size.each { |word|
			result_string = detail_size_doc.to_s.match(/#{word}/)
			if result_string != nil
				result_string = result_string.post_match.match(/[0-9０-９]+/)
				if result_string != nil
					result_string.to_s.tr!('０-９','0-9')
					result_integer = result_string.to_s.to_i 
					break
				end
			end
		}
		return result_integer
	end



	def self.is_slice_pattern(detail_size_doc, slicers)
		resultset = { "result" => "0", "slicer" => nil}
		slicers.each { |slicer| 
			tmp_detail_size_doc = detail_size_doc
			count = 0
			until tmp_detail_size_doc == nil || tmp_detail_size_doc.blank?
				if detail_size_doc.to_s.match(/#{slicer}/) != nil
					if detail_size_doc.to_s.match(/#{slicer}/).post_match.to_s[1..10].match(/#{slicer}/) != nil
						return { "result" => "2", "slicer" => slicer }
					else
						resultset = { "result" => "1", "slicer" => slicer}
						tmp_detail_size_doc = detail_size_doc.to_s.match(/#{slicer}/).post_match.to_s
						count += 1
						return resultset if count > 10
					end
				else
					break
				end
			end
		}
		return resultset
	end



	def self.get_size_by_slicer(size_string)
		if size_string != nil && !(size_string.blank?)
			size_string.to_s.tr!('０-９','0-9')
			return size_string.to_s.to_i
		end
		return 0
	end



	# rails runner Crawls::GetBag.test_page_to_detail
	def self.test_page_to_detail
		page_url = "http://www.amazon.co.jp/s/rh=n%3A2016926051%2Cn%3A%212016927051%2Cn%3A2221077051%2Cn%3A2221074051%2Cn%3A2221205051%2Cn%3A2221211051&page=4&ie=UTF8&qid=1430707642"
		next_item_number = 144
		self.page_to_detail(page_url, next_item_number)
	end
	# => last 3 lines
	# http://www.amazon.co.jp/dp/B00T2HSNHY
	# 48
	# *** return: true ***

	# rails runner Crawls::GetBag.test_detail_to_array
	def self.test_detail_to_array
		detail_url = "http://www.amazon.co.jp/dp/B00I3DQ82A"
		self.detail_to_array(detail_url)
	end



end