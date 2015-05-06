class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  before_action :count_filter
	rescue_from Exception, with: :error_handler

  def count_filter
		@device_count = DeviceItem.count
		@bag_count = BagItem.count
  end

  def error_handler
  	redirect_to :controller => 'device_brands', :action => 'index'
  end

end
