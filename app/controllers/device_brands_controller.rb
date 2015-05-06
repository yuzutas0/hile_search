class DeviceBrandsController < ApplicationController

	def index
		@device_brands = DeviceBrand.all.includes(:device_item)
	end

end
