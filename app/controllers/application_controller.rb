class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :count_filter

  def count_filter
		@device_count = DeviceItem.count
		@bag_count = BagItem.count
  end
end
