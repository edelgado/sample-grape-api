require 'benchmark'
require 'json'
require 'typhoeus'
require 'pry'

def separate_comma(number)
  whole, decimal = number.to_s.split(".")
  whole_with_commas = whole.chars.to_a.reverse.each_slice(3).map(&:join).join(",").reverse
  [whole_with_commas, decimal].compact.join(".")
end

puts "How many API requests should I do?"
numtimes = gets # How many reads and writes?
numtimes.chomp
url = "http://0.0.0.0:9292/orders"

# =================== POST Benchmark ====================
total = 0 # Total time (updates after each request)
uuids = [] # UUIDs of newly created records
puts '=' * url.length
puts url

(1..numtimes.to_i).each do |n|
  # Compose the request
  request = Typhoeus::Request.new(
    url,
    method: :post,
    body: {"item_name" => "Item #{n}", "quantity" => n, "price" => n * 10}
  )
  # Run it
  request.run
  # Get the response
  response = request.response
  # If successful, do a couple of things:
  if response.success?
    puts "POST #{url} - #{n}: #{(response.total_time).round(4)}s"
    total += response.total_time
    order = JSON.parse(response.body)
    uuids.push(order['uuid'])
  end
end

# binding.pry
puts '=' * url.length
avg = (total / numtimes.to_i).round(4)
puts "Average for #{url} : #{avg}s or #{1 / avg} reqs/sec or #{separate_comma((86400 / avg).round(4))} reqs/day"
puts "\n"


# =================== GET Benchmark ====================
total = 0 # Reset the total time counter

# Lets read back the UUIDs we just wrote:
(uuids).each do |n|
  # Compose the request
  request = Typhoeus::Request.new(
    url + '/' + n,
    method: :get
  )
  # Run it
  request.run
  # Get the response
  response = request.response
  # If successful, do a couple of things:
  if response.success?
    order = JSON.parse(response.body)
    puts "GET #{url} - #{order['uuid']}: #{(response.total_time).round(4)}s"
    total += response.total_time
  end
end

puts '=' * url.length
avg = (total / numtimes.to_i).round(4)
puts "Average for #{url} : #{avg}s or #{1 / avg} reqs/sec or #{separate_comma((86400 / avg).round(4))} reqs/day"
puts "\n"