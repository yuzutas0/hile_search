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



	#  MainMenu => HiddenMenu => End
	item_number = 0
	item_is_end = false
	item_is_hidden = false

	until item_is_end

		item_number += 1
		subseriesmenu_path = "//*[@id=\"subseriesmenu\"]/div/div/"
		subseriesmenu_path += "div[1]/" if item_is_hidden == 1
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
		#menu_list.tap(&:save)
		puts "[before]name: "       + menu_list.name
		puts "[before]tree_depth: " + menu_list.tree_depth.to_s
		puts "[before]leaf_flag: "  + menu_list.leaf_flag.to_s
		puts "[before]parent_id: "  + menu_list.parent_id.to_s



		# MainMenu or HiddenMenu => SubMenu
		sub_item_number = 0
		sub_item_is_end = false

		until sub_item_is_end

			sub_item_number += 1
			sub_subseriesmenu_path = "//*[@id=\"subseriesmenu\"]/div/div/"
			sub_subseriesmenu_path += "div[1]/" if item_is_hidden == 1
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
																			:parent_id => 2)
#																			:parent_id => menu_list.id)
			#sub_menu_list.tap(&:save)
			puts "   name: "       + sub_menu_list.name
			puts "      tree_depth: " + sub_menu_list.tree_depth.to_s
			puts "      leaf_flag: "  + sub_menu_list.leaf_flag.to_s
			puts "      parent_id: "  + sub_menu_list.parent_id.to_s

			if sub_item_number == 1
				menu_list.leaf_flag = false
				#menu_list.tap(&:save)
			end



			# 一覧に入る(ページングあるなら2つ目も含む)
			# PC詳細のスペックページに入る
			# PCのインサート

		end



		# 一覧に入る(ページングあるなら2つ目も含む)
		# PC詳細のスペックページに入る
		# サブメニューでは扱っていなかったPCをインサート
		puts "[after]name: "       + menu_list.name
		puts "[after]tree_depth: " + menu_list.tree_depth.to_s
		puts "[after]leaf_flag: "  + menu_list.leaf_flag.to_s
		puts "[after]parent_id: "  + menu_list.parent_id.to_s
		puts "*****"



	end

end