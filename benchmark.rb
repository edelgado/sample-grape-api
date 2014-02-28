require 'benchmark'
require 'json'
require 'typhoeus'
require 'pry'

numtimes = 100 # How many reads and writes?
# binding.pry

# =================== POST Benchmark ====================
hydra = Typhoeus::Hydra.new(max_concurrency: 2) # A hundred serpents is better than one
total = 0            # Reset the total time counter

url = "http://0.0.0.0:9292/orders"
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

  # Request callbacks
  request.on_complete do |response|
    if response.success?
      # hell yeah
        puts "POST #{url} - #{n}: #{(response.total_time).round(6)}s"
        total += response.total_time
        order = JSON.parse(response.body)
        uuids.push(order['uuid'])
    elsif response.timed_out?
      # aw hell no
      puts "Got a time out"
    elsif response.code == 0
      # Could not get an http response, something's wrong.
      puts "Could not get an HTTP response, message was: #{response.return_message}"
    else
      # Received a non-successful http response.
      puts "HTTP request failed: #{response.code.to_s}"
    end
  end

  # Queue the request
  hydra.queue(request);
end

hydra.run # Release the Hydra!

#binding.pry
puts '=' * url.length
puts "Average for #{url} : #{(total / numtimes.to_i).round(4)}s or #{1 / (total / numtimes.to_i).round(4)} reqs/sec."
puts "\n"


# =================== GET Benchmark ====================
hydra = Typhoeus::Hydra.new(max_concurrency: 2) # A hundred serpents is better than one
total = 0            # Reset the total time counter

(uuids).each do |n|

  # Compose the request
  request = Typhoeus::Request.new(
    url + '/' + n,
    method: :get
  )

  # Request callbacks
  request.on_complete do |response|
    if response.success?
      # hell yeah
        order = JSON.parse(response.body)
        puts "GET #{url} - #{order['uuid']}: #{(response.total_time).round(6)}s"
        total += response.total_time
    elsif response.timed_out?
      # aw hell no
      puts "Got a time out"
    elsif response.code == 0
      # Could not get an http response, something's wrong.
      puts "Could not get an HTTP response, message was: #{response.return_message}"
    else
      # Received a non-successful http response.
      puts "HTTP request failed: #{response.code.to_s}"
    end
  end

  # Queue the request
  hydra.queue(request);
end

hydra.run # Release the Hydra!

puts '=' * url.length
puts "Average for #{url} : #{(total / numtimes.to_i).round(4)}s or #{1 / (total / numtimes.to_i).round(4)} reqs/sec."
puts "\n"