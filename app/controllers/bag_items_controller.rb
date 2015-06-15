class BagItemsController < ApplicationController

	def index
		# check params
		dii = params[:dii]
		max_dii = DeviceItem.maximum(:id)
		if dii.present? && integer_string?(dii) && dii.to_i <= max_dii
			return
		end
		redirect_to :root
	end

	def test
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

	private
		def integer_string?(str)
			Integer(str)
			true
		rescue ArgumentError
			false
		end

end
