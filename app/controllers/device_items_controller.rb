class DeviceItemsController < ApplicationController

	def index
		redirect_to controller: 'device_brands', action: 'index'
	end

end