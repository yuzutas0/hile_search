class DeviceBrandsControllerController < ApplicationController
	def show
		@device_brands = DeviceBrand.all.includes(:device_item)
	end
end
