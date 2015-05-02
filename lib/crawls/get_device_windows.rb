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

	#  MainMenu => HiddenMenu
	for item_is_hidden in 0..1 do

		list_number = 1

		# MainMenu or HiddenMenu => SubMenu
		for item_is_sub_list in 0..1 do

			sub_list_number = 1
			item_is_end = false
	
			# 4PatternMenu's Items
			until item_is_end

				subseriesmenu_path = "//*[@id=\"subseriesmenu\"]/div/div/"
				subseriesmenu_path += "div[1]/" if item_is_hidden == 1
				subseriesmenu_path += ("ul/li[" + list_number.to_s + "]/")
				subseriesmenu_path += ("div/ul/li[" + sub_list_number.to_s + "]/") if item_is_sub_list == 1
				subseriesmenu_path += "a"

				subseriesmenu_name = top_doc.at(subseriesmenu_path)

				# get nil
				if subseriesmenu_name.blank?
					# possibility 1 : exception pattern
					subseriesmenu_path = "//*[@id=\"subseriesmenu\"]/div/div/div[1]/ul/li[" + list_number.to_s + "]/div/ul/li/a"
					subseriesmenu_name = top_doc.at(subseriesmenu_path)
					# possibility 2 : list end
					if subseriesmenu_name.blank?
						
						item_is_end = true
						next
					end
				end

				subseriesmenu_name = subseriesmenu_name.text
				subseriesmenu_href = subseriesmenu_name.attribute('href')

				puts subseriesmenu_path
				puts subseriesmenu_name
				puts subseriesmenu_href

				sub_list_number += 1 if item_is_sub_list == 1

				#name
      	#tree_depth = 1のとき明示
      	#leaf_flag = falseのとき明示
     		#parent_id

			end
		end
	end


=begin
	
	
href
text（ただしspanタグの手前まで）

//*[@id="subseriesmenu"]/div/div/ul/li[1]/a
//*[@id="subseriesmenu"]/div/div/ul/li[2]/a
//*[@id="subseriesmenu"]/div/div/ul/li[5]/a
//*[@id="subseriesmenu"]/div/div/ul/li[10]/a

//*[@id="subseriesmenu"]/div/div/ul/li[1]/div/ul/li[1]/a
//*[@id="subseriesmenu"]/div/div/ul/li[1]/div/ul/li[4]/a
//*[@id="subseriesmenu"]/div/div/ul/li[9]/div/ul/li[4]/a



//*[@id="subseriesmenu"]/div/div/div[1]/ul/li[1]/a
//*[@id="subseriesmenu"]/div/div/div[1]/ul/li[2]/a
//*[@id="subseriesmenu"]/div/div/div[1]/ul/li[6]/a
//*[@id="subseriesmenu"]/div/div/div[1]/ul/li[7]/a
//*[@id="subseriesmenu"]/div/div/div[1]/ul/li[21]/a

//*[@id="subseriesmenu"]/div/div/div[1]/ul/li[7]/div/ul/li/a => 特殊ケースとしてnilキャッチ時に再取得
//*[@id="subseriesmenu"]/div/div/div[1]/ul/li[12]/div/ul/li[1]/a


	# ループでマスタに入れる
	# 一覧に入る(ページングあるなら2つ目も含む)
	# PC詳細のスペックページに入る
	# PCのインサート

=end


end