# encoding: utf-8
class Crawls::GetBagTag
	
	# rails runner Crawls::GetBagTag.execute
	def self.execute
		self.set_each_tables(@mens_bag_name, @mens_bag_url_list)
		self.set_each_tables(@ladies_bag_name, @ladies_bag_url_list)
		self.set_each_tables(@ruck_bag_name, @ruck_bag_url_list)
		self.set_each_tables(@business_bag_name, @business_bag_url_list)
	end


	# => BothDB
	def self.set_each_tables(this_name, this_list)
		self.import_bag_tag(this_name, this_list)
		self.import_crawl_manager(this_name, this_list)
	end


	# => MainDB
	def self.import_bag_tag(this_name, this_list)
		this_bag = BagTag.new(:name => this_name)
		this_bag.tap(&:save)

		this_bag_list = []
		this_list.each_key { |each_name|
			this_bag_list << BagTag.new(:name => each_name,
																	:tree_depth => 1,
																	:parent_id => this_bag.id)
		}

		BagTag.import this_bag_list
	end


	# => SupportDB
	def self.import_crawl_manager(this_name, this_list)
		url_common_before = "http://www.amazon.co.jp/s/?rh=n%3A2016926051%2Cn%3A"
		url_common_after = "&page=" # + "1", "2", ...

		this_manager_list = []
		this_list.each { |key, value|
			parent_tag = BagTag.find_by(name: this_name, tree_depth: 0)
			bag_tag = BagTag.find_by(name: key, parent_id: parent_tag.id)
			this_url = url_common_before + value + url_common_after
			this_manager = CrawlBagPageManager.new(:bag_tag_id => bag_tag.id, :url => this_url)
			this_manager_list << this_manager
		}

		CrawlBagPageManager.import this_manager_list
	end


	# List
	@mens_bag_name = "メンズバッグ"
	@mens_bag_url_list = {
		"セカンドバッグ" => "%212016927051%2Cn%3A2221077051%2Cn%3A2221074051%2Cn%3A2221205051%2Cn%3A2221211051",
		"ショルダーバッグ" => "%212016927051%2Cn%3A2221077051%2Cn%3A2221074051%2Cn%3A2221205051%2Cn%3A2221212051",
		"トートバッグ" => "%212016927051%2Cn%3A2221077051%2Cn%3A2221074051%2Cn%3A2221205051%2Cn%3A2221214051",
		"斜めがけバッグ" => "%212016927051%2Cn%3A2221077051%2Cn%3A2221074051%2Cn%3A2221205051%2Cn%3A2230921051",
		"メッセンジャーバッグ" => "%212016927051%2Cn%3A2221077051%2Cn%3A2032443051"
	}
	@ladies_bag_name = "レディースバッグ"	
	@ladies_bag_url_list = {
		"ハンドバッグ" => "%212016927051%2Cn%3A2221077051%2Cn%3A2221075051%2Cn%3A2221178051%2Cn%3A2221189051",
		"斜めかけバッグ" => "%212016927051%2Cn%3A2221077051%2Cn%3A2221075051%2Cn%3A2221178051%2Cn%3A2221190051",
		"クラッチバッグ" => "%212016927051%2Cn%3A2221077051%2Cn%3A2221075051%2Cn%3A2221178051%2Cn%3A2221191051",
		"パーティーバッグ" => "%212016927051%2Cn%3A2221077051%2Cn%3A2221075051%2Cn%3A2221178051%2Cn%3A2221192051",
		"ショルダーバッグ" => "%212016927051%2Cn%3A2221077051%2Cn%3A2221075051%2Cn%3A2221178051%2Cn%3A2221193051",
		"フォーマルバッグ" => "%212016927051%2Cn%3A2221077051%2Cn%3A2221075051%2Cn%3A2221178051%2Cn%3A2221194051",
		"トートバッグ" => "%212016927051%2Cn%3A2221077051%2Cn%3A2221075051%2Cn%3A2221178051%2Cn%3A2221196051",
		"カゴバッグ" => "%212016927051%2Cn%3A2221077051%2Cn%3A2221075051%2Cn%3A2221178051%2Cn%3A2221197051"
	}
	@ruck_bag_name = "リュック・バックパック"
	@ruck_bag_url_list = {
		"メンズリュック・バックパック" => "%213077047051%2Cn%3A%213077049051%2Cn%3A%213077051051%2Cn%3A3077103051",
		"レディースリュック・バックパック" => "%213077047051%2Cn%3A%213077049051%2Cn%3A%213077051051%2Cn%3A3077101051",
		"キッズリュックサック" => "%212016927051%2Cn%3A2226307051%2Cn%3A2226309051%2Cn%3A2230677051",
		"通学・学校・スクール" => "2221077051%2Cn%3A2032444051%2Ck%3A%E9%80%9A%E5%AD%A6%7C%E5%AD%A6%E6%A0%A1%7C%E3%82%B9%E3%82%AF%E3%83%BC%E3%83%AB",
		"ビジネス・通勤" => "2221077051%2Cn%3A2032444051%2Ck%3A%E3%83%93%E3%82%B8%E3%83%8D%E3%82%B9%7C%E9%80%9A%E5%8B%A4",
		"アウトドアバッグ" => "%212016927051%2Cn%3A2221077051%2Cn%3A15324701"
	}
	@business_bag_name = "ビジネスバッグ"
	@business_bag_url_list = {
		"ＰＣ収納" => "2221077051%2Cn%3A2226779051%2Ck%3A%EF%BC%B0%EF%BC%A3%E5%8F%8E%E7%B4%8D",
		"多ポケット" => "2221077051%2Cn%3A2226779051%2Ck%3A%E5%A4%9A%E3%83%9D%E3%82%B1%E3%83%83%E3%83%88",
		"3way" => "2221077051%2Cn%3A2226779051%2Ck%3A3way",
		"出張" => "%212016927051%2Cn%3A2221077051%2Cn%3A2226779051%2Cp_28%3A%E5%87%BA%E5%BC%B5",
		"鍵付" => "2221077051%2Cn%3A2226779051%2Ck%3A%E9%8D%B5%E4%BB%98",
		"B4" => "%212016927051%2Cn%3A2221077051%2Cn%3A2226779051%2Cp_28%3AB4",
		"A4" => "%212016927051%2Cn%3A2221077051%2Cn%3A2226779051%2Cp_28%3AA4",
		"A3" => "%212016927051%2Cn%3A2221077051%2Cn%3A2226779051%2Cp_28%3AA3",
		"アタッシュケース" => "2221077051%2Cn%3A2226779051%2Ck%3A%E3%82%A2%E3%82%BF%E3%83%83%E3%82%B7%E3%83%A5%E3%82%B1%E3%83%BC%E3%82%B9",
		"防水・撥水" => "2221077051%2Cn%3A2226779051%2Ck%3A%E9%98%B2%E6%B0%B4%7C%E6%92%A5%E6%B0%B4",
		"ペットボトルホルダー" => "2221077051%2Cn%3A2226779051%2Ck%3A%E3%83%9A%E3%83%83%E3%83%88%E3%83%9C%E3%83%88%E3%83%AB%E3%83%9B%E3%83%AB%E3%83%80%E3%83%BC",
		"バッグインバッグ" => "2221077051%2Cn%3A2226779051%2Ck%3A%E3%83%90%E3%83%83%E3%82%B0%E3%82%A4%E3%83%B3%E3%83%90%E3%83%83%E3%82%B0"
	}

end