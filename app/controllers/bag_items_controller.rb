class BagItemsController < ApplicationController

	def index
		@device = DeviceItem.find(params[:id])

		@bags = BagItem.where("long_size > :long_size AND middle_size > :middle_size AND \
											(short_size = 0 OR short_size > :short_size) AND bag_tag_id IN (:tags)", { 
													long_size: @device.long_size, 
													middle_size: @device.middle_size, 
													short_size: @device.short_size, 
													tags: params[:tags] 
											}).page(params[:page]).per(3).order(:id)
	end

	# tag
	# = form_for @search_form, url: hoge_path, remote: true, html: {method: :get} do |f|
	# = f.check_box :foobar, {multiple: true}, 'foo', nil
	# = f.check_box :foobar, {multiple: true}, 'bar', nil

	# gem 'kaminari'
	# <%= paginate(@bags) %>

	# strong_parameter

end
