# encoding: utf-8
class Crawls::GetBagDetail

	require 'open-uri'
	require 'kconv'
	require 'nokogiri'

	# rails runner Crawls::GetBagDetail.execute
	# for auto crawling
	def self.execute
		rest = CrawlBagDetailManager.where(done_flag: false, error_flag: false).count
		if rest == 0
			puts "*** everything done ***"
			return
		end

		for now_number in 0..rest do
			self.execute_single
			puts "finish ===> " + now_number.to_s + "/" + rest.to_s

			all = CrawlBagDetailManager.count
			rest = CrawlBagDetailManager.where(done_flag: false, error_flag: false).count
			done = CrawlBagDetailManager.where(done_flag: true).count
			error = CrawlBagDetailManager.where(error_flag: true).count
			puts = "DB-rest ===> " + rest.to_s + "/" + all.to_s
			puts = "DB-done ===> " + done.to_s + "/" + all.to_s
			puts = "DB-error ===> " + error.to_s + "/" + all.to_s
		end

		puts "*** for-loop-end ***"
	end



	# rails runner Crawls::GetBagDetail.execute_ten_thousand
	def self.execute_ten_thousand
		for now_number in 1..10 do
			self.execute_thousand
			puts " ===> ===> ===> finish ===> ===> ===> " + (now_number * 1000).to_s + "/10000"
		end
	end

	# rails runner Crawls::GetBagDetail.execute_thousand
	def self.execute_thousand
		for now_number in 1..10 do
			self.execute_hundred
			puts " ===> ===> finish ===> ===> " + (now_number * 100).to_s + "/1000"
		end
	end

	# rails runner Crawls::GetBagDetail.execute_hundred
	def self.execute_hundred
		for now_number in 1..10 do
			self.execute_ten
			puts " ===> finish ===> " + (now_number * 10).to_s + "/100"
		end
	end

	# rails runner Crawls::GetBagDetail.execute_ten
	def self.execute_ten
		for now_number in 1..10 do
			self.execute_single
			puts "finish ===> " + now_number.to_s + "/10"
		end
	end



	# rails runner Crawls::GetBagDetail.execute_single
	# for check test
	def self.execute_single
		puts "getting manager..."
		manager = CrawlBagDetailManager.find_by(done_flag: false, error_flag: false)
		if manager == nil
			puts "*** everything done ***"
			return
		end

		# same check
		puts "same check..."
		url_dp = manager.url.match(/\/dp\//).post_match
		if self.check_same_dp_url(url_dp, manager.bag_tag)
			manager.update_attribute(:done_flag, true)
			puts "tag-association update!"
			return
		end

		puts "while ready..."
		error_sequence = 0
		while_sequence = 0
		
		while !manager.done_flag && !manager.error_flag
			
			begin
				puts " crawl!"
				sleep(1)
				this_detail = Nokogiri::HTML(open(manager.url, &:read).toutf8)
				puts "  crawl done!"
				error_sequence = 0
			rescue
				puts "  error!"
				error_sequence += 1
			end

			self.detail_to_array(manager, this_detail) if this_detail != nil

			if error_sequence >= 30
				puts "*** 30 sequence error ***"
				puts manager.url
				return
			end

			while_sequence += 1
			if while_sequence >= 50
				puts "*** 50 sequence while ***"
				puts manager.url
				return
			end
		end
	end



	def self.detail_to_array(manager, this_detail)

		# get basic parameters
		detail_url_dp = manager.url.match(/\/dp\//).post_match
		detail_name = self.get_name(this_detail)
		detail_image = self.get_image(this_detail)
		detail_price = self.get_price(this_detail)

		# get size parameters
		size_hash = self.get_size(this_detail)
		detail_width = size_hash["width"]
		detail_height = size_hash["height"]
		detail_depth = size_hash["depth"]

		# mm => cm
		if detail_width >= 200 || detail_height >= 200
			detail_width = detail_width / 10
			detail_height = detail_height / 10
			detail_depth = detail_depth / 10
		end

		# error check
		if detail_name == nil || detail_image == nil || detail_price == 0 || detail_width == 0 || detail_height == 0
			manager.update_attribute(:error_flag, true)
			puts "get_name mistake!" if detail_name == nil
			puts "get_image mistake!" if detail_image == nil
			puts "get_price mistake!" if detail_price == 0
			puts "get_width mistake!" if detail_width == 0
			puts "get_height mistake!" if detail_height == 0
			puts "url ===> " + manager.url
			return
		end

		if detail_depth == 0
			manager.error_flag = true
			# keep this script (not return)
		end

		# save
		detail_item = BagItem.new(:name      => detail_name,
															:url_dp    => detail_url_dp,
															:width     => detail_width,
															:height    => detail_height,
															:depth     => detail_depth,
															:price     => detail_price,
															:image_url => detail_image)
		detail_item.bag_tags << manager.bag_tag
		detail_item.tap(&:save)

		puts "save => " + detail_item.name
		puts " - url_dp:" + detail_item.url_dp
		puts " - width:" + detail_item.width.to_s
		puts " - height:" + detail_item.height.to_s
		puts " - depth:" + detail_item.depth.to_s
		puts " - price:" + detail_item.price.to_s
		puts " - image:" + detail_item.image_url

		manager.done_flag = true
		manager.save
		return
	end



	def self.check_same_dp_url(detail_url_dp, bag_tag)
		item = BagItem.find_by(url_dp: detail_url_dp)
		if item != nil
			item.bag_tags << bag_tag
			item.save
			return true
		else
			return false
		end
	end



	def self.get_name(this_detail)
		begin
			detail_name = this_detail.at("//*[@id=\"productTitle\"]").text
		rescue
			return nil
		end
		detail_name.gsub!(" ", "")
		detail_name.gsub!("　", "")
		return detail_name
	end



	def self.get_image(this_detail)
		detail_image = this_detail.at("//*[@id=\"landingImage\"]")
		return nil if detail_image == nil
		detail_image = detail_image.attribute("src")
		return nil if detail_image == nil
		return nil if detail_image.to_s.blank?
		return detail_image.to_s
	end



	def self.get_price(this_detail)
		detail_price_text = this_detail.at("//*[@id=\"priceblock_ourprice\"]")
		detail_price_text = this_detail.at("//*[@id=\"priceblock_saleprice\"]") if detail_price_text == nil
		return 0 if detail_price_text == nil
		detail_price_text = detail_price_text.text
		[" ", "　", "¥", "￥", ",", "、"].each { |word|
			detail_price_text.gsub!(word, "")
		}
		detail_price = detail_price_text.to_i
		return detail_price
	end



	def self.get_size(this_detail)
		detail_size_doc = this_detail.at("//*[@id=\"feature-bullets\"]/ul")
		response = self.get_size_by_xpath(detail_size_doc)

		if response["width"] == 0 || response["height"] == 0
			detail_size_doc = this_detail.at("//*[@id=\"productDescription\"]/div/div")
			response = self.get_size_by_xpath(detail_size_doc)
		end

		return response
	end



	def self.get_size_by_xpath(detail_size_doc)
		if detail_size_doc == nil || detail_size_doc.to_s.blank?
			return { "width" => 0, "height" => 0, "depth" => 0 }
		end

		# if they say "size", focus it
		if detail_size_doc.to_s.match(/サイズ/) != nil
			detail_size_doc = detail_size_doc.to_s.match(/サイズ/).post_match
		end

		# get_size_score
		detail_width = self.get_size_score(["横", "ヨコ", "長", "幅", "Ｗ", "W"], detail_size_doc)
		detail_height = self.get_size_score(["縦", "タテ", "高", "厚", "マチ", "マッチ", "まち", "Ｈ", "H"], detail_size_doc)
		detail_depth = self.get_size_score(["奥", "マチ", "マッチ", "まち", "幅", "厚","Ｄ", "D"], detail_size_doc)

		# get_size_score in other case
		if detail_width == 0 || detail_height == 0
			slice_size_hash = self.get_size_when_slice_pattern(detail_size_doc)
			detail_width = slice_size_hash["width"]
			detail_height = slice_size_hash["height"]
			detail_depth = slice_size_hash["depth"]
		end

		return { "width" => detail_width, "height" => detail_height, "depth" => detail_depth }
	end



	def self.get_size_score(size, detail_size_doc)
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



	def self.get_size_when_slice_pattern(detail_size_doc)
		detail_width = 0
		detail_height = 0
		detail_depth = 0

		# size：19.5cm×11.5cm×4.3cm
		["x", "×", "ｘ"].each { |slicer|
			is_slice_pattern = self.is_slice_pattern(detail_size_doc, slicer)
			if is_slice_pattern > 0
				if detail_size_doc.to_s.match(/#{slicer}/).pre_match.size > 10
					detail_width_string = detail_size_doc.to_s.match(/#{slicer}/).pre_match.to_s[-10..-1].match(/[0-9０-９]+/)
				else
					detail_width_string = detail_size_doc.to_s.match(/#{slicer}/).pre_match.match(/[0-9０-９]+/)
				end
				detail_width = self.get_size_score_by_slicer(detail_width_string)

				detail_height_string = detail_size_doc.to_s.match(/#{slicer}/).post_match.match(/[0-9０-９]+/)
				detail_height = self.get_size_score_by_slicer(detail_height_string)
				
				if is_slice_pattern == 2
					detail_depth_string = detail_size_doc.to_s.match(/#{slicer}/).post_match.match(/#{slicer}/).post_match.match(/[0-9０-９]+/)
					detail_depth = self.get_size_score_by_slicer(detail_depth_string)
				end
			end

			break if detail_width > 0 && detail_height > 0
		}

		return { "width" => detail_width, "height" => detail_height, "depth" => detail_depth }
	end



	def self.is_slice_pattern(detail_size_doc, slicer)
		result = 0
			tmp_detail_size_doc = detail_size_doc
			count = 0
			until tmp_detail_size_doc == nil || tmp_detail_size_doc.blank?
				if detail_size_doc.to_s.match(/#{slicer}/) != nil
					if detail_size_doc.to_s.match(/#{slicer}/).post_match.to_s[1..10].match(/#{slicer}/) != nil
						return 2
					else
						result = 1
						tmp_detail_size_doc = detail_size_doc.to_s.match(/#{slicer}/).post_match.to_s
						count += 1
						return result if count > 10
					end
				else
					break
				end
			end
		return result
	end



	def self.get_size_score_by_slicer(size_string)
		if size_string != nil && !(size_string.blank?)
			size_string.to_s.tr!('０-９','0-9')
			return size_string.to_s.to_i
		end
		return 0
	end


end