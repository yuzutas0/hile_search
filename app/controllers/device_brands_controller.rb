class DeviceBrandsController < ApplicationController

	def index

		# children list
		# check params
		dbi = params[:dbi]
		max_dbi = DeviceBrand.maximum(:id)
		if dbi.present? && integer_string?(dbi) && dbi.to_i <= max_dbi

			# check object-by-id
			dbi_obj = DeviceBrand.find(dbi)
			if dbi_obj.present?

				# check relational-object
				@this_device_brand = DeviceBrand.find(dbi).includes(:device_items)
				render template: "device_items/index" if @this_device_brand.device_items.present? and return
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
