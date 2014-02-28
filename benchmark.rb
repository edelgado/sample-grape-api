require 'benchmark'
require 'json'
require 'typhoeus'
require 'pry'

numtimes = 1000 # How many reads and writes?
# binding.pry

# =================== POST Benchmark ====================
hydra = Typhoeus::Hydra.hydra # A hundred serpents is better than one
max_hydra_batch = 10 # Hydra batch size
queue_size = 0 
total = 0            # Reset the total time counter
batch_total_time = 0 # Reset the Hydra batch time counter

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
        puts "POST #{url} - #{n}: #{(response.total_time - batch_total_time).round(6)}s"
        batch_total_time = response.total_time
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
  queue_size += 1
  if queue_size == max_hydra_batch
    queue_size = 0
    batch_total_time = 0
    total += batch_total_time
    hydra.run # Release the Hydra!
  end
end

# binding.pry
puts '=' * url.length
puts "Average for #{url} : #{(total / numtimes.to_i).round(4)}s or #{1 / (total / numtimes.to_i).round(4)} reqs/sec."
puts "\n"


# =================== GET Benchmark ====================
hydra = Typhoeus::Hydra.hydra # A hundred serpents is better than one
total = 0            # Reset the total time counter
batch_total_time = 0 # Reset the Hydra batch time counter

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
        puts "GET #{url} - #{order['uuid']}: #{(response.total_time - batch_total_time).round(6)}s"
        batch_total_time = response.total_time
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
  queue_size += 1
  if queue_size == max_hydra_batch
    queue_size = 0
    batch_total_time = 0
    total += batch_total_time
    hydra.run # Release the Hydra!
  end
end

puts '=' * url.length
puts "Average for #{url} : #{(total / numtimes.to_i).round(4)}s or #{1 / (total / numtimes.to_i).round(4)} reqs/sec."
puts "\n"