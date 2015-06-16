class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  before_action :count_filter
	rescue_from Exception, with: :error_handler

  def count_filter
		@device_count = DeviceItem.count
		@bag_count = BagItem.count

    device_last_update_time = DeviceItem.maximum(:updated_at)
    bag_last_update_time = BagItem.maximum(:updated_at)
    last_update_time = [device_last_update_time, bag_last_update_time].compact.max
    @last_update = last_update_time.strftime("%Y/%m/%d") if last_update_time.present?
  end

  def error_handler
  	redirect_to :controller => 'device_brands', :action => 'index'
  end

end
