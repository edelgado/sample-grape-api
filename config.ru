# gems
require 'pry'
require 'grape'
require 'grape-entity'
require 'redis'

# API entities
require './entities/order'

# API
require './sample_order_api'
run Digium::API