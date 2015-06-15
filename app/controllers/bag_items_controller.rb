class BagItemsController < ApplicationController

	def index
		# check params
		dii = params[:dii]
		max_dii = DeviceItem.maximum(:id)
		if dii.present? && integer_string?(dii) && dii.to_i <= max_dii
			@device = DeviceItem.find(dii)
			@bags = BagItem.where("long_side > :long_side AND middle_side > :middle_side AND (short_side = 0 OR short_side > :short_side)",{
																long_side: @device.long_side, 
																middle_side: @device.middle_side, 
																short_side: @device.short_side, 
														}).page(1).per(3).order(:id)
			puts @bags
			return if @bags.present?
		end
		redirect_to :root
	end

	def test
		@bags = BagItem.where("long_side > :long_side AND middle_side > :middle_side AND \
											(short_side = 0 OR short_side > :short_side) AND bag_tag_id IN (:tags)", { 
													long_side: @device.long_side, 
													middle_side: @device.middle_side, 
													short_side: @device.short_side, 
													tags: params[:tags] 
											}).page(params[:page]).per(3).order(:id)
	end

	# tag
	# = form_for @search_form, url: hoge_path, remote: true, html: {method: :get} do |f|
	# = f.check_box :foobar, {multiple: true}, 'foo', nil
	# = f.check_box :foobar, {multiple: true}, 'bar', nil

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
