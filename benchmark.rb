require 'benchmark'
require 'net/http'
require 'uri'
require 'json'
require 'pry'

numtimes = 1000
url = "http://0.0.0.0:9292/orders"

total = 0
puts url
puts '=' * url.length
uri = URI.parse(url)
http = Net::HTTP.new(uri.host, uri.port)
uuids = []

(1..numtimes.to_i).each do |n|
  response = nil
  time = Benchmark.realtime do
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"item_name" => "Item #{n}", "quantity" => n, "price" => n * 10})
    response = http.request(request)
  end  
  puts "#{url} - #{n} : #{time}s"
  total += time
  order = JSON.parse(response.body)
  uuids.push(order['uuid'])
end
puts '=' * url.length
puts "Average for #{url} : #{(total / numtimes.to_i).round(4)}s or #{1 / (total / numtimes.to_i).round(6)} reqs/sec."
puts "\n"

(uuids).each do |n|
  response = nil
  url = "http://0.0.0.0:9292/orders/" + n
  uri = URI.parse(url)
  time = Benchmark.realtime do
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
  end
  
  total += time
  order = JSON.parse(response.body)
  puts "#{url} - #{order['uuid']} : #{time}s"
end
puts '=' * url.length
puts "Average for #{url} : #{(total / numtimes.to_i).round(4)}s or #{1 / (total / numtimes.to_i).round(6)} reqs/sec."
puts "\n"