require 'benchmark'
require 'net/http'
require 'uri'
require 'pry'

numtimes = 10
url = "http://0.0.0.0:9292/orders"

total = 0
puts url
puts '=' * url.length
uri = URI.parse(url)
http = Net::HTTP.new(uri.host, uri.port)

(1..numtimes.to_i).each do |n|
  time = Benchmark.realtime do
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"item_name" => "Item #{n}", "quantity" => n, "price" => n * 10})
    http.request(request)
  end
  puts "#{url} - #{n} : #{time}s"
  total += time
end
puts '=' * url.length
puts "Average for #{url} : #{(total / numtimes.to_i).round(4)}s"
puts "\n"