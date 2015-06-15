class DeviceBrandsController < ApplicationController

	def index

		# children list
		# check params
		dbi = params[:dbi]
		max_dbi = DeviceBrand.maximum(:id)
		if dbi.present? && integer_string?(dbi) && dbi.to_i <= max_dbi

			# check object-by-id
			@this_device_brand = DeviceBrand.find(dbi)				
			if @this_device_brand.present? && @this_device_brand.device_items.present?
			 	render template: "device_items/index" and return
			end
		end

		# default - parents list		
		@device_brands = DeviceBrand.where('tree_depth = ?', 0).includes([{:children => :device_items}, :device_items])
	end

	private
		def integer_string?(str)
			Integer(str)
			true
		rescue ArgumentError
			false
		end
		
end
