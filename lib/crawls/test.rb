# rails runner Crawls::Test.execute
# 3 => 2 => 5 => 4 => 7 => 1

# rails runner Crawls::Test
# 3 => 2 => 5 => 4 => 7

# rails runner lib/crawls/test.rb
# 3 => 2 => 5 => 4 => 7 

class Crawls::Test
	def self.execute
    puts "***** 1 *****\n***** Success! *****\n***** Your Rails Runner and Your Job Script did! *****"
	end

	puts "***** 3 *****\n***** Success! *****\n***** Your Rails Runner and Your Job Script did! *****"
end

puts "***** 2 *****\n***** Success! *****\n***** Your Rails Runner and Your Job Script did! *****"

class Crawls::Try
	def self.execute
    puts "***** 4 *****\n***** Success! *****\n***** Your Rails Runner and Your Job Script did! *****"
    self.try
    # challenge => Exception
    # self.challenge => Exception
	end

	def self.try
    puts "***** 7 *****\n***** Success! *****\n***** Your Rails Runner and Your Job Script did! *****"
	end

	def challenge
    puts "***** 6 *****\n***** Success! *****\n***** Your Rails Runner and Your Job Script did! *****"
	end

	puts "***** 5 *****\n***** Success! *****\n***** Your Rails Runner and Your Job Script did! *****"
	self.execute
end



