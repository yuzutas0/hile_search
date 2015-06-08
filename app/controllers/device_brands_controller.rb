class DeviceBrandsController < ApplicationController

	def index

		# case: top-page
		@device_brands = DeviceBrand.where('tree_depth = ?', 0).includes(:device_items)
		@pattern = "parents"

		# case: brand-parents
		# exist check
		if params[:dbp].present?
			dbp = params[:dbp].to_i
			max_db_id = DeviceBrand.maximum('id')

			# value check
			if 0 < dbp && dbp <= max_db_id
				device_brand_parent = DeviceBrand.find(dbp).includes(:device_items)
				@device_brand_children = device_brand_parent.children
				@device_items = device_brand_parent.device_items

				# 4 pattern display
				if @device_brand_children.present? && @device_items.present?
					other = DeviceBrand.new(:name => "その他", :tree_depth => 1)
					@device_brand_children.push(other)
					@pattern = "both"   # children + items
				elsif @device_brand_children.present?
					@pattern = "children"   # children only
				elsif @device_items.present?
					@pattern = "items"   # items only
				else
					@pattern = "nothing"   # nothing
				end
			end
		end

		# case: brand-children

	end

end
