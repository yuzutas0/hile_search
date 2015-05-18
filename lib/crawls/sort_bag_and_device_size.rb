# encoding: utf-8
class Crawls::SortBagAndDeviceSize

	# rails runner Crawls::SortBagAndDeviceSize.execute
	def self.execute
		puts "*** job starts!! ***"
		self.sort_device_size
		self.sort_bag_size
		puts "*** job ends!! ***"
	end



	# input:device's H,W,D => output:device's LongSide, MiddleSide, ShortSide
	def self.sort_device_size
		puts "* device sort starts!! *"
		count = 0

		DeviceItem.find_each do |device|
			puts "device - loop - " + count.to_s
			self.sort_each_device_size(device)
			puts "   updated!"
			count += 1
		end

		puts "* device sort ends!! *"
	end



	# sort
	def self.sort_each_device_size(device)
		size = [0, 0, 0]
		size[0] = device.height
		size[1] = device.width
		size[2] = device.depth
		size.sort!

		device.short_side = size[0]
		device.middle_side = size[1]
		device.long_side = size[2]

		puts "     short_side  = " + device.short_side.to_s
		puts "     middle_side = " + device.middle_side.to_s
		puts "     long_side   = " + device.long_side.to_s

		device.save!
	end



	# input:bag's H,W,D => output:bag's LongSide, MiddleSide, ShortSide
	def self.sort_bag_size
		puts "* bag sort starts!! *"
		count = 0

		BagItem.find_each do |bag|
			puts "bag - loop - " + count.to_s
			self.sort_each_bag_size(bag)
			puts "   updated!"
			count += 1
		end

		puts "* bag sort ends!! *"
	end



	# sort
	def self.sort_each_bag_size(bag)
		size = [0, 0, 0]
		size[0] = bag.height
		size[1] = bag.width
		size[2] = bag.depth
		size.sort!

		bag.short_side = size[0]
		bag.middle_side = size[1]
		bag.long_side = size[2]

		puts "     short_side  = " + bag.short_side.to_s
		puts "     middle_side = " + bag.middle_side.to_s
		puts "     long_side   = " + bag.long_side.to_s

		bag.save!
	end
end