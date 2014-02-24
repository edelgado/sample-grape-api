module Digium
  module Entities
    class Order < Grape::Entity

      expose :uuid
      expose :item_name
      expose :quantity
      expose :price
      expose :created_at
      
      attr_accessor :uuid, :item_name, :quantity, :price, :created_at
    
      def initialize(object, options = {})
        super
        self.generate_uuid
        self.item_name = @object.item_name
        self.quantity = @object.quantity
        self.price = @object.price
        self.created_at = Time.now
        return self
      end
      
      def self.recent(n=10)
        number_of_orders = redis.zcard("orders")
        recent_order_uuids = redis.zrevrange("orders", 0, n - 1) # returns most recent orders specified by 'n' arg
        recent_order_uuids.map do |uuid|
          self.find(uuid)
        end
      end
    
      def self.create!(params)
        self.new(params).save
      end
      
      def self.find(uuid)
        attributes = self.redis.hgetall("order-#{uuid}")
      end
      
      def save
        self.class.redis.hmset("order-#{uuid}", *self.as_json.flatten)
        add_to_orders_set
        return self
      end
      
      def add_to_orders_set
        self.class.redis.zadd("orders", created_at.to_i, uuid)
      end
      
      def self.redis
        @redis ||= Redis.new
      end
      
      def generate_uuid
        self.uuid ||= SecureRandom.uuid
      end
     
    end
  end
end