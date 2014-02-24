module Digium
  class API < Grape::API
    version 'v1', using: :header, vendor: 'digium'
    format :json

    helpers do
      def current_user
        @current_user ||= User.authorize!(env)
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

    resource :statuses do
      desc "Return all orders."
      get :public_timeline do
        Order.limit(20)
      end

      desc "Return a a user's orders."
      get :home_timeline do
        authenticate!
        current_user.orders.limit(20)
      end

      desc "Return an order."
      params do
        requires :id, type: Integer, desc: "Order id."
      end
      route_param :id do
        get do
          Order.find(params[:id])
        end
      end

      desc "Create an order."
      params do
        requires :product, type: String, desc: "Product name."
      end
      post do
        authenticate!
        Order.create!({
          user: current_user,
          product: params[:status]
        })
      end

      desc "Delete an order."
      params do
        requires :id, type: String, desc: "Order ID."
      end
      delete ':id' do
        authenticate!
        current_user.orders.find(params[:id]).destroy
      end
    end
  end
end