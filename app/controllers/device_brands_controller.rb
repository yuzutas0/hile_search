class DeviceBrandsController < ApplicationController

	def index

		# children-pattern
		puts "1"
		dbi = params[:dbi]
		max_dbi = DeviceBrand.maximum(:id)
		if dbi.present? && integer_string?(dbi) && dbi.to_i <= max_dbi
			puts "2"

			# check object-by-id
			dbi_obj = DeviceBrand.find(dbi)
			return if dbi_obj.blank?

			# check relational-object 
			@this_device_brand = DeviceBrand.find(dbi).includes(:device_items)
			return if @this_device_brand.device_items.blank?

			# after check
			render 'children'
		end

		# default(parents-pattern)
		@device_brands = DeviceBrand.where('tree_depth = ?', 0).includes([{:children => :device_items}, :device_items])
		render 'index'
	end

	private
		def integer_string?(str)
			Integer(str)
			true
		rescue ArgumentError
			false
		end

end
