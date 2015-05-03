# encoding: utf-8


class Crawls::GetDeviceWindows
	# rails runner Crawls::GetDeviceWindows

	require 'open-uri'
	require 'kconv'
	require 'nokogiri'

	# TOP
	top_doc_original = open("http://kakaku.com/pc/note-pc/", &:read).toutf8
	top_doc_original.gsub!(/<span>.+?<\/span>/, "")
	top_doc = Nokogiri::HTML(top_doc_original)
	sleep(1)

	#  MainMenu => HiddenMenu => End
	item_number = 0
	item_is_end = false
	item_is_hidden = false

	until item_is_end

		puts "- until item_is_end -" + Time.now.to_s 
		devices = []

		item_number += 1
		subseriesmenu_path = "//*[@id=\"subseriesmenu\"]/div/div/"
		subseriesmenu_path += "div[1]/" if item_is_hidden == true
		subseriesmenu_path += ("ul/li[" + item_number.to_s + "]/a")
		subseriesmenu_name = top_doc.at(subseriesmenu_path)
		
		if subseriesmenu_name.blank?
			if item_is_hidden
				item_is_end = true
				next
			else
				item_is_hidden = true
				next
			end
		end

		subseriesmenu_href = subseriesmenu_name.attribute('href')
		subseriesmenu_name = subseriesmenu_name.text

		menu_list = DeviceBrand.new(:name => subseriesmenu_name)
		menu_list.tap(&:save)

		puts "* save *"
		puts "   item_number: "        + item_number.to_s
		puts "   [before]name: "       + menu_list.name
		puts "   [before]tree_depth: " + menu_list.tree_depth.to_s
		puts "   [before]leaf_flag: "  + menu_list.leaf_flag.to_s
		puts "   [before]parent_id: "  + menu_list.parent_id.to_s



		# MainMenu or HiddenMenu => SubMenu
		sub_item_number = 0
		sub_item_is_end = false

		until sub_item_is_end

			puts "- until sub_item_is_end -" + Time.now.to_s 
			sub_item_number += 1

			sub_subseriesmenu_path = "//*[@id=\"subseriesmenu\"]/div/div/"
			sub_subseriesmenu_path += "div[1]/" if item_is_hidden == true
			sub_subseriesmenu_path += ("ul/li[" + item_number.to_s + "]/div/ul/li[" + sub_item_number.to_s + "]/a")
			sub_subseriesmenu_name = top_doc.at(sub_subseriesmenu_path)

			if sub_subseriesmenu_name.blank?
				# possibility 1 : exception pattern
				sub_subseriesmenu_path = "//*[@id=\"subseriesmenu\"]/div/div/div[1]/ul/li[" + item_number.to_s + "]/div/ul/li/a"
				sub_subseriesmenu_name = top_doc.at(sub_subseriesmenu_path)
				# possibility 2 : list end
				if sub_subseriesmenu_name.blank? || sub_item_number > 1
					sub_item_is_end = true
					next
				end
			end

			sub_subseriesmenu_href = sub_subseriesmenu_name.attribute('href')
			sub_subseriesmenu_name = sub_subseriesmenu_name.text

			sub_menu_list = DeviceBrand.new(:name => sub_subseriesmenu_name,
																			:tree_depth => 1,
																			:parent_id => menu_list.id)
			sub_menu_list.tap(&:save)

			puts "* save *"
			puts "   sub_item_number: " + sub_item_number.to_s
			puts "   name: "            + sub_menu_list.name
			puts "   tree_depth: "      + sub_menu_list.tree_depth.to_s
			puts "   leaf_flag: "       + sub_menu_list.leaf_flag.to_s
			puts "   parent_id: "       + sub_menu_list.parent_id.to_s

			if sub_item_number == 1
				menu_list.leaf_flag = false
				menu_list.tap(&:save)
			end



			# note-PC's index
			page_number = 0
			page_is_end = false

			until page_is_end
				
				puts "- until page_is_end -" + Time.now.to_s 
				page_number += 1

				page_url = sub_subseriesmenu_href.to_s + "&pdf_pg=" + page_number.to_s
				begin
					page_doc = Nokogiri::HTML(open(page_url, &:read).toutf8)
				rescue Exception => e
					puts "********** page_url: " + page_url
					logger.error "error-message:" + e.message
					page_doc = Nokogiri::HTML(open(page_url, &:read).toutf8)
				end
				sleep(1)



				# SubMenu (not MainMenu nor HiddenMenu)
				# note-PC's link
				link_number = 0
				link_is_end = false
				link_count = 0
				link_max = page_doc.at("//*[@id=\"itemList\"]/form/div[1]/table/tr/td[1]/p[2]/span[2]").text.to_i

				until link_is_end

					puts "- until link_is_end -" + Time.now.to_s 
					if link_count >= link_max
						link_is_end = true 
						next
					end

					link_number += 1
					link_path = "//*[@id=\"compTblList\"]/tbody/tr[" + link_number.to_s + "]/td[2]/table/tr/td[1]/a"
					link_point = page_doc.at(link_path)

					next if link_point.blank?
					link_count += 1
					link_uri = link_point.attribute('href').to_s



					# note-PC's detail
					link_uri += "spec/#tab"
					detail_doc = Nokogiri::HTML(open(link_uri, &:read).toutf8)
					sleep(1)

					detail_name = detail_doc.at("//*[@id=\"titleBox\"]/div[1]/h2").text					
					kakakucom_check = detail_name.match(/価格.com/)
					unless kakakucom_check.blank?
						puts "* skip - kakakucom! *"
						next
					end
					package_check = detail_name.match(/パッケージ/)
					unless package_check.blank?
						puts "* skip - package! *"
						next
					end

					detail_size = detail_doc.at("//*[@id=\"mainLeft\"]/table/tr[23]/td[1]").text
					next if detail_size.blank?

					detail_width = detail_size.to_s.match(/\d+/)[0].to_i
					detail_height = detail_size.to_s.match(/x/).post_match.match(/\d+/)[0].to_i
					detail_depth = detail_size.to_s.match(/x/).post_match.match(/x/).post_match.match(/\d+/)[0].to_i

					detail_unit = detail_size.to_s.match(/mm|cm/)[0]
					if detail_unit == "mm"
						detail_width = detail_width / 10
						detail_height = detail_height / 10
						detail_depth = detail_depth / 10
					end

					detail_obj = DeviceItem.new(:name => detail_name,
																			:width => detail_width + 1,
																			:height => detail_height + 1,
																			:depth => detail_depth + 1,
	 																		:device_brand_id => sub_menu_list.id)
					devices.push(detail_obj)

					puts "* add array *"
					puts "   link_number: "     + link_number.to_s
					puts "   link_count: "      + link_count.to_s
					puts "   name: "            + detail_obj.name
					puts "   width: "           + detail_obj.width.to_s
					puts "   height: "          + detail_obj.height.to_s
					puts "   depth: "           + detail_obj.depth.to_s					
					puts "   device_brand_id: " + detail_obj.device_brand_id.to_s
				end

				page_next = page_doc.at("//*[@id=\"itemList\"]/form/div[1]/table/tr/td[1]/p[2]/a/img")
				if page_next == nil
					page_is_end = true
				else
					page_next = page_next.attribute('class')
					page_is_end = true unless page_next == "pageNextOn"
				end
			end
		end


		# MainMenu or HiddenMenu (not SubMenu)
		# note-PC's index
		page_number = 0
		page_is_end = false

		until page_is_end
			
			puts "- until page_is_end -" + Time.now.to_s 
			page_number += 1

			page_url = subseriesmenu_href.to_s + "&pdf_pg=" + page_number.to_s
			page_doc = Nokogiri::HTML(open(page_url, &:read).toutf8)
			sleep(1)



			# note-PC's link
			link_number = 0
			link_is_end = false
			link_count = 0
			link_max = page_doc.at("//*[@id=\"itemList\"]/form/div[1]/table/tr/td[1]/p[2]/span[2]").text.to_i

			until link_is_end

				puts "- until link_is_end -" + Time.now.to_s 
				if link_count >= link_max
					link_is_end = true 
					next
				end

				link_number += 1
				link_path = "//*[@id=\"compTblList\"]/tbody/tr[" + link_number.to_s + "]/td[2]/table/tr/td[1]/a"
				link_point = page_doc.at(link_path)

				next if link_point.blank?
				link_count += 1
				link_uri = link_point.attribute('href').to_s



				# note-PC's detail
				link_uri += "spec/#tab"
				detail_doc = Nokogiri::HTML(open(link_uri, &:read).toutf8)
				sleep(1)

				detail_name = detail_doc.at("//*[@id=\"titleBox\"]/div[1]/h2").text
				kakakucom_check = detail_name.match(/価格.com/)
				unless kakakucom_check.blank?
					puts "* skip - kakakucom! *"
					next
				end
				package_check = detail_name.match(/パッケージ/)
				unless package_check.blank?
					puts "* skip - package! *"
					next
				end

				is_same_device = false
				for device in devices do
					if device.name == detail_name
						is_same_device = true
						puts "* skip - same device! *"
						break
					end
				end
				next if is_same_device					

				detail_size = detail_doc.at("//*[@id=\"mainLeft\"]/table/tr[23]/td[1]").text
				next if detail_size.blank?

				detail_width = detail_size.to_s.match(/\d+/)[0].to_i
				detail_height = detail_size.to_s.match(/x/).post_match.match(/\d+/)[0].to_i
				detail_depth = detail_size.to_s.match(/x/).post_match.match(/x/).post_match.match(/\d+/)[0].to_i

				detail_unit = detail_size.to_s.match(/mm|cm/)[0]
				if detail_unit == "mm"
					detail_width = detail_width / 10
					detail_height = detail_height / 10
					detail_depth = detail_depth / 10
				end

				detail_obj = DeviceItem.new(:name => detail_name,
																		:width => detail_width + 1,
																		:height => detail_height + 1,
																		:depth => detail_depth + 1,
 																		:device_brand_id => menu_list.id)
				devices.push(detail_obj)

				puts "* add array *"
				puts "   link_number: "     + link_number.to_s
				puts "   link_count + 1: "  + (link_count + 1).to_s
				puts "   name: "            + detail_obj.name
				puts "   width: "           + detail_obj.width.to_s
				puts "   height: "          + detail_obj.height.to_s
				puts "   depth: "           + detail_obj.depth.to_s					
				puts "   device_brand_id: " + detail_obj.device_brand_id.to_s
			end

			page_next = page_doc.at("//*[@id=\"itemList\"]/form/div[1]/table/tr/td[1]/p[2]/a/img")
			if page_next == nil
				page_is_end = true
			else
				page_next = page_next.attribute('class')
				page_is_end = true unless page_next == "pageNextOn"
			end
		end



		# Bulk Insert by gem 'activerecord-import'
		DeviceItem.import devices

		puts "* save PC list *"
		puts "   item_number: "       + item_number.to_s
		puts "   [after]name: "       + menu_list.name
		puts "   [after]tree_depth: " + menu_list.tree_depth.to_s
		puts "   [after]leaf_flag: "  + menu_list.leaf_flag.to_s
		puts "   [after]parent_id: "  + menu_list.parent_id.to_s
		puts "********** ********** **********"

	end
end