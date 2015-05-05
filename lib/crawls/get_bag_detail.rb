# encoding: utf-8
class Crawls::GetBagDetail

	require 'open-uri'
	require 'kconv'
	require 'nokogiri'

	# rails runner Crawls::GetBagDetail.execute
	def self.execute
		# input => detail-manager
		# output => save
		# CrawlBagDetailManager
	end



	def self.detail_to_array(manager)

		# same check
		detail_url_dp = manager.url.match(/\/dp\//).post_match
		if self.check_same_dp_url(detail_url_dp, manager.bag_tag)
			manager.done_flag = true
			return
		end

		# crawl
		sleep(1)
		this_detail = Nokogiri::HTML(open(manager.url, &:read).toutf8)

		# get basic parameters
		detail_name = self.get_name(this_detail)
		detail_image = self.get_image(this_detail)
		detail_price = self.get_price(this_detail)

		# get size parameters
		size_hash = self.get_size(this_detail)
		detail_width = size_hash["width"]
		detail_height = size_hash["height"]
		detail_depth = size_hash["depth"]

		# error check
		if detail_name == nil || detail_image == nil || detail_price == 0 || detail_width == 0 || detail_height == 0
			manager.error_flag = true
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
		detail_item.bag_tag << manager.bag_tag
		detail_item.save
		manager.done_flag = true
		return
	end



	def self.check_same_dp_url(detail_url_dp, bag_tag)
		item = BagItem.find_by(url_dp: detail_url_dp)
		if item != nil
			item.bag_tag << bag_tag
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
		return detail_image
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
		if detail_size_doc == nil || detail_size_doc.to_s.blank?
			return { "width" => 0, "height" => 0, "depth" => 0 }
		end

		# if they say "size", focus it
		if detail_size_doc.to_s.match(/サイズ/) != nil
			detail_size_doc = detail_size_doc.to_s.match(/サイズ/).post_match
		end

		# get_size_score
		detail_width = self.get_size_score(["横", "ヨコ", "長", "幅", "Ｗ", "W"], detail_size_doc)
		detail_height = self.get_size_score(["縦", "タテ", "高", "厚", "Ｈ", "H"], detail_size_doc)
		detail_depth = self.get_size_score(["奥", "マチ", "マッチ", "幅", "厚","Ｄ", "D"], detail_size_doc)

		# get_size_score in other case
		if detail_width == detail_height && detail_width == detail_depth && detail_width == 0
			slice_size_hash = self.get_size_when_slice_pattern(detail_size_doc)
			detail_width = slice_size_hash["width"]
			detail_height = slice_size_hash["height"]
			detail_depth = slice_size_hash["depth"]
		end
		return { "width" => detail_width, "height" => detail_height, "depth" => detail_depth}
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
		slicers = ["x", "×"]
		is_slice_pattern = self.is_slice_pattern(detail_size_doc, slicers)

		if is_slice_pattern["result"] == "1" || is_slice_pattern["result"] == "2"
			slicer = is_slice_pattern["slicer"]

			if detail_size_doc.to_s.match(/#{slicer}/).pre_match.size > 10
				detail_width_string = detail_size_doc.to_s.match(/#{slicer}/).pre_match.to_s[-10..-1].match(/[0-9０-９]+/)
			else
				detail_width_string = detail_size_doc.to_s.match(/#{slicer}/).pre_match.match(/[0-9０-９]+/)
			end
			detail_width = self.get_size_score_by_slicer(detail_width_string)
			detail_height_string = detail_size_doc.to_s.match(/#{slicer}/).post_match.match(/[0-9０-９]+/)
			detail_height = self.get_size_score_by_slicer(detail_height_string)
			
			if is_slice_pattern["result"] == "2"
				detail_depth_string = detail_size_doc.to_s.match(/#{slicer}/).post_match.match(/#{slicer}/).post_match.match(/[0-9０-９]+/)
				detail_depth = self.get_size_score_by_slicer(detail_depth_string)
			end
		end

		return ["width" => detail_width, "height" => detail_height, "depth" => detail_depth]
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



	def self.get_size_score_by_slicer(size_string)
		if size_string != nil && !(size_string.blank?)
			size_string.to_s.tr!('０-９','0-9')
			return size_string.to_s.to_i
		end
		return 0
	end


end