# rails runner Crawls::Test.execute
# => both messages displayed
class Crawls::Test
	def self.execute
    puts "***** Success! *****\n***** Your Rails Runner and Your Job Script did! *****"
	end
end

# rails runner lib/crawls/test.rb
# => this messsage displayed
puts "***** Success! *****\n***** Your Rails Runner and Your Job Script did! *****"

