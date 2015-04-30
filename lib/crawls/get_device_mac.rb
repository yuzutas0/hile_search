class Crawls::GetDeviceMac
	
	# Property:ItemURL
	@mac_book_url = 'http://www.apple.com/jp/macbook/specs/'
	@mac_book_pro_url = 'http://www.apple.com/jp/macbook-pro/specs/'
	@mac_book_pro_retina_url = 'http://www.apple.com/jp/macbook-pro/specs-retina/'
	@mac_book_air_url = 'http://www.apple.com/jp/macbook-air/specs.html'

	# Model
	brand = DeviceBrand.new(:name => 'Mac')
	brand.tap(&:save)



	# MacBook

	# crawl
	# name
	mac_book_name = ''
	# width
	mac_book_width = 0
	# height
	mac_book_height = 0
	# depth
	mac_book_depth = 0
	# insert
	mac_book = DeviceItem.new(:name => mac_book_name,
														:width => mac_book_width,
														:height => mac_book_height,
														:depth => mac_book_depth,
														:device_brand_id => brand.id)
	mac_book.save



	# MacBookPro
	# crawl
	# name
	# width
	# height
	# depth
	# insert

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