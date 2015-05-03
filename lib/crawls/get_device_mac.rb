# encoding: utf-8


class Crawls::GetDeviceMac
	# rails runner Crawls::GetDeviceMac

	require 'open-uri'
	require 'kconv'
	require 'nokogiri'

	# Brand
	brand = DeviceBrand.new(:name => 'Mac')
	brand.tap(&:save)



	# MacBook 
	mac_book_doc = Nokogiri::HTML(open("http://www.apple.com/jp/macbook/specs/", &:read).toutf8)
	sleep(2)

	mac_book_name = mac_book_doc.at("/html/body/div[1]/nav/h2/a").text
	mac_book_size_doc = mac_book_doc.at("//*[@id=\"main\"]/section[3]/section[6]/div/div[2]")
	mac_book_width = mac_book_size_doc.to_s.match(/幅/).post_match.match(/\d+/)[0]
	mac_book_height = mac_book_size_doc.to_s.match(/高/).post_match.match(/～\d+/)[0].to_s[1..-1]
	mac_book_depth = mac_book_size_doc.to_s.match(/奥/).post_match.match(/\d+/)[0]

	mac_book = DeviceItem.new(:name => mac_book_name,
														:width => mac_book_width.to_i + 1,
														:height => mac_book_height.to_i + 1,
														:depth => mac_book_depth.to_i + 1,
														:device_brand_id => brand.id)
	mac_book.save

	puts "* save *"
	puts "   name: "   + mac_book.name
	puts "   width: "  + mac_book.width.to_s
	puts "   height: " + mac_book.height.to_s
	puts "   depth: "  + mac_book.depth.to_s
	puts "   brand: "  + mac_book.device_brand_id.to_s



	# MacBookPro
	mac_book_pro_doc = Nokogiri::HTML(open("http://www.apple.com/jp/macbook-pro/specs/", &:read).toutf8)
	sleep(2)

	mac_book_pro_name = mac_book_pro_doc.at("//*[@id=\"content\"]/table/thead/tr/th[3]/h1/img").attribute('alt')
	mac_book_pro_size_doc = mac_book_pro_doc.at("//*[@id=\"content\"]/table/tbody/tr[6]")
	mac_book_pro_width = mac_book_pro_size_doc.to_s.match(/幅/).post_match.match(/\d+/)[0]
	mac_book_pro_height = mac_book_pro_size_doc.to_s.match(/高/).post_match.match(/\d+/)[0]
	mac_book_pro_depth = mac_book_pro_size_doc.to_s.match(/奥/).post_match.match(/\d+/)[0]

	mac_book_pro = DeviceItem.new(:name => mac_book_pro_name.to_s,
														:width => mac_book_pro_width.to_i + 1,
														:height => mac_book_pro_height.to_i + 1,
														:depth => mac_book_pro_depth.to_i + 1,
														:device_brand_id => brand.id)
	mac_book_pro.save

	puts "* save *"
	puts "   name: "   + mac_book_pro.name
	puts "   width: "  + mac_book_pro.width.to_s
	puts "   height: " + mac_book_pro.height.to_s
	puts "   depth: "  + mac_book_pro.depth.to_s
	puts "   brand: "  + mac_book_pro.device_brand_id.to_s



	# MacBookProRetina
	mac_book_pro_retina_doc = Nokogiri::HTML(open("http://www.apple.com/jp/macbook-pro/specs-retina/", &:read).toutf8)
	mac_book_pro_retina_post_name = mac_book_pro_retina_doc.at("//*[@id=\"productheader\"]/h2/a/img").attribute('alt')
	sleep(2)

	for num in 3..4 do
		mac_book_pro_retina_name_path = "//*[@id=\"content\"]/table/thead/tr/th[" + num.to_s + "]/h1/img"
		num -= 1
		mac_book_pro_retina_size_path = "//*[@id=\"content\"]/table/tbody/tr[11]/td[" + num.to_s + "]"
		mac_book_pro_retina_size_doc = mac_book_pro_retina_doc.at(mac_book_pro_retina_size_path)

		mac_book_pro_retina_pre_name = mac_book_pro_retina_doc.at(mac_book_pro_retina_name_path).attribute('alt')
		mac_book_pro_retina_name = mac_book_pro_retina_pre_name.to_s + mac_book_pro_retina_post_name.to_s
		mac_book_pro_retina_width = mac_book_pro_retina_size_doc.to_s.match(/幅/).post_match.match(/\d+/)[0]
		mac_book_pro_retina_height = mac_book_pro_retina_size_doc.to_s.match(/高/).post_match.match(/\d+/)[0]
		mac_book_pro_retina_depth = mac_book_pro_retina_size_doc.to_s.match(/奥/).post_match.match(/\d+/)[0]

		mac_book_pro_retina = DeviceItem.new(:name => mac_book_pro_retina_name.to_s,
															:width => mac_book_pro_retina_width.to_i + 1,
															:height => mac_book_pro_retina_height.to_i + 1,
															:depth => mac_book_pro_retina_depth.to_i + 1,
															:device_brand_id => brand.id)
		mac_book_pro_retina.save

		puts "* save *"
		puts "   name: "   + mac_book_pro_retina.name
		puts "   width: "  + mac_book_pro_retina.width.to_s
		puts "   height: " + mac_book_pro_retina.height.to_s
		puts "   depth: "  + mac_book_pro_retina.depth.to_s
		puts "   brand: "  + mac_book_pro_retina.device_brand_id.to_s
	end



	# MacBookAir
	mac_book_air_doc = Nokogiri::HTML(open("http://www.apple.com/jp/macbook-air/specs.html", &:read).toutf8)
	sleep(2)

	for num in 2..3 do
		mac_book_air_name_path = "//*[@id=\"main\"]/table/tr[1]/td[" + num.to_s + "]/span"
		mac_book_air_size_path = "//*[@id=\"main\"]/table/tr[8]/td[" + num.to_s + "]"
		mac_book_air_size_doc = mac_book_air_doc.at(mac_book_air_size_path)

		mac_book_air_name = mac_book_air_doc.at(mac_book_air_name_path).text
		mac_book_air_width = mac_book_air_size_doc.to_s.match(/幅/).post_match.match(/\d+/)[0]
		mac_book_air_height = mac_book_air_size_doc.to_s.match(/高/).post_match.match(/～\d+/)[0].to_s[1..-1]
		mac_book_air_depth = mac_book_air_size_doc.to_s.match(/奥/).post_match.match(/\d+/)[0]

		mac_book_air = DeviceItem.new(:name => mac_book_air_name.to_s,
															:width => mac_book_air_width.to_i + 1,
															:height => mac_book_air_height.to_i + 1,
															:depth => mac_book_air_depth.to_i + 1,
															:device_brand_id => brand.id)
		mac_book_air.save
		
		puts "* save *"
		puts "   name: "   + mac_book_air.name
		puts "   width: "  + mac_book_air.width.to_s
		puts "   height: " + mac_book_air.height.to_s
		puts "   depth: "  + mac_book_air.depth.to_s
		puts "   brand: "  + mac_book_air.device_brand_id.to_s
	end

end