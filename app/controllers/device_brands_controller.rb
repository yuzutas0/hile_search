class DeviceBrandsController < ApplicationController

	def index
		@device_brands = DeviceBrand.where('tree_depth = ?', 0).includes(:device_items)
	end

end
