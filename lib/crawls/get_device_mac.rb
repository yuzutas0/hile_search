# encoding: utf-8


class Crawls::GetDeviceMac
	# rails runner lib/crawls/get_device_mac.rb

	require 'open-uri'
	require 'kconv'
	require 'nokogiri'
	
	@mac_book_pro_retina_url = 'http://www.apple.com/jp/macbook-pro/specs-retina/'
	@mac_book_air_url = 'http://www.apple.com/jp/macbook-air/specs.html'

	# Brand
	#brand = DeviceBrand.new(:name => 'Mac')
	#brand.tap(&:save)



	# MacBook 
	mac_book_doc = Nokogiri::HTML(open("http://www.apple.com/jp/macbook/specs/", &:read).toutf8)
	mac_book_size_doc = mac_book_doc.at("//*[@id=\"main\"]/section[3]/section[6]/div/div[2]")

	mac_book_name = mac_book_doc.at("/html/body/div[1]/nav/h2/a").text
	mac_book_width = mac_book_size_doc.to_s.match(/幅/).post_match.match(/\d+/)[0]
	mac_book_height = mac_book_size_doc.to_s.match(/高/).post_match.match(/～\d+/)[0].to_s[1..-1]
	mac_book_depth = mac_book_size_doc.to_s.match(/奥/).post_match.match(/\d+/)[0]

	mac_book = DeviceItem.new(:name => mac_book_name,
														:width => mac_book_width.to_i + 1,
														:height => mac_book_height.to_i + 1,
														:depth => mac_book_depth.to_i + 1,
														:device_brand_id => 1)
	#													:device_brand_id => brand.id)
	#mac_book.save
	puts "name: "   + mac_book.name
	puts "width: "  + mac_book.width.to_s
	puts "height: " + mac_book.height.to_s
	puts "depth: "  + mac_book.depth.to_s
	puts "brand: "  + mac_book.device_brand_id.to_s



	# MacBookPro
	mac_book_pro_doc = Nokogiri::HTML(open("http://www.apple.com/jp/macbook-pro/specs/", &:read).toutf8)
	mac_book_pro_size_doc = mac_book_pro_doc.at("//*[@id=\"content\"]/table/tbody/tr[6]")

	mac_book_pro_name = mac_book_pro_doc.at("//*[@id=\"content\"]/table/thead/tr/th[3]/h1/img").attribute('alt')
	mac_book_pro_width = mac_book_pro_size_doc.to_s.match(/幅/).post_match.match(/\d+/)[0]
	mac_book_pro_height = mac_book_pro_size_doc.to_s.match(/高/).post_match.match(/\d+/)[0]
	mac_book_pro_depth = mac_book_pro_size_doc.to_s.match(/奥/).post_match.match(/\d+/)[0]

	mac_book_pro = DeviceItem.new(:name => mac_book_pro_name,
														:width => mac_book_pro_width.to_i + 1,
														:height => mac_book_pro_height.to_i + 1,
														:depth => mac_book_pro_depth.to_i + 1,
														:device_brand_id => 1)
	#													:device_brand_id => brand.id)
	#mac_book_pro.save
	puts "name: "   + mac_book_pro.name
	puts "width: "  + mac_book_pro.width.to_s
	puts "height: " + mac_book_pro.height.to_s
	puts "depth: "  + mac_book_pro.depth.to_s
	puts "brand: "  + mac_book_pro.device_brand_id.to_s

	# MacBookProRetina
	# crawl
	# name
	# width
	# height
	# depth
	# insert

	# MacBookAir
	# crawl
	# name
	# width
	# height
	# depth
	# insert

end