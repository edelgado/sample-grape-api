require 'benchmark'
require 'json'
require 'typhoeus'
require 'pry'

numtimes = 30 # How many reads and writes?
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
puts "Average for #{url} : #{(total / numtimes.to_i).round(4)}s or #{1 / (total / numtimes.to_i).round(4)} reqs/sec."
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
puts "Average for #{url} : #{(total / numtimes.to_i).round(4)}s or #{1 / (total / numtimes.to_i).round(4)} reqs/sec."
puts "\n"