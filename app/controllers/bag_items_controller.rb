class BagItemsController < ApplicationController

	def index
		# check params dii
		dii = params[:dii]
		max_dii = DeviceItem.maximum(:id)
		if dii.present? && integer_string?(dii) && dii.to_i <= max_dii

			# check params sbt
			@sbt = params[:sbt]
			if @sbt.blank? || !(sbt_is_right?(@sbt))
				@sbt = BagTag.pluck(:id)
			end

			# check params cot
			@cot = params[:cot]
			if @cot.present? && @cot == "and"
				sbt_and_query = ""
				for sbt_item in @sbt
					sbt_and_query = sbt_and_query + "bag_tag_id = " + sbt_item.to_s
					sbt_and_query = sbt_and_query + " AND " unless sbt_item == @sbt.last
				end
				bag_id_by_tags = BagItem.joins(:bag_tags).where(sbt_and_query).pluck(:id)
			else
				@cot = "or"
				bag_id_by_tags = BagItem.joins(:bag_tags).where("bag_tag_id IN (:tags)", tags: @sbt).pluck(:id)
			end

			# check params obp
			@obp = params[:obp]
			@obp = "none" if @obp.blank? || (@obp != "high" && @obp != "low")

			# check params nod
			@nod = params[:nod]
			@nod = "3" if @nod.blank? || (@nod.to_i != 9 && @nod.to_i != 15 && @nod.to_i != 30)

			# check params dii
			@device = DeviceItem.find(dii)
			redirect_to :root if @device.blank?

			# select object
			if @obp == "high"
				@bags = BagItem.where("long_side > :long_side AND middle_side > :middle_side AND \
									(short_side = 0 OR short_side > :short_side) AND id IN (:id_by_tags)", {
													long_side: @device.long_side, 
													middle_side: @device.middle_side, 
													short_side: @device.short_side, 
													id_by_tags: bag_id_by_tags
											}).page(params[:page]).per(@nod.to_i).order(:price).reverse_order.includes({:bag_tags => :parent})
			elsif @obp == "low"
				@bags = BagItem.where("long_side > :long_side AND middle_side > :middle_side AND \
									(short_side = 0 OR short_side > :short_side) AND id IN (:id_by_tags)", {
													long_side: @device.long_side, 
													middle_side: @device.middle_side, 
													short_side: @device.short_side, 
													id_by_tags: bag_id_by_tags
											}).page(params[:page]).per(@nod.to_i).order(:price).includes({:bag_tags => :parent})				
			else
				@bags = BagItem.where("long_side > :long_side AND middle_side > :middle_side AND \
									(short_side = 0 OR short_side > :short_side) AND id IN (:id_by_tags)", {
													long_side: @device.long_side, 
													middle_side: @device.middle_side, 
													short_side: @device.short_side, 
													id_by_tags: bag_id_by_tags
											}).page(params[:page]).per(@nod.to_i).order(:id).includes({:bag_tags => :parent})	
			end

			# edit data for view					
			if @bags.present?
				@bags.each do |bag|
					bag.name = bag.name[0...18] + "..." if bag.name.length > 19
				end
			end

			# view
			@tags = BagTag.where('tree_depth = ?', 0).includes(:children)
			return
		end
		redirect_to :root
	end

	def test
		@bags = BagItem.where("long_side > :long_side AND middle_side > :middle_side AND \
											(short_side = 0 OR short_side > :short_side) AND bag_tag_id IN (:tags)", { 
													long_side: @device.long_side, 
													middle_side: @device.middle_side, 
													short_side: @device.short_side, 
													tags: params[:tags] 
											}).page(params[:page]).per(3).order(:id)
	end

	private
		def integer_string?(str)
			Integer(str)
			true
		rescue ArgumentError
			false
		end

		def sbt_is_right?(array)
			max_sbt = BagTag.maximum(:id)
			for sbt_item in array
				return false if !(integer_string?(sbt_item)) || sbt_item.to_i > max_sbt
			end
			return true
		end

end
