module Digium
  class API < Grape::API
    version 'v1', using: :header, vendor: 'digium'
    format :json

    resources :orders do
      
      desc "Returns recent orders"
      params do
        optional :num, type: Integer
      end
      get do
        if params[:num]
          Digium::Entities::Order.recent(params[:num])
        else
          Digium::Entities::Order.recent
        end
      end
      
      desc "Create an order"
      post do
        Digium::Entities::Order.create! params
      end
      
      desc "Get an order"
      route_param :uuid do
        get do
          Digium::Entities::Order.find(params[:uuid]) 
        end
      end
    end
    # resource :orders do
      # desc "Return all orders."
      #      get  do
      #        Order.limit(20)
      #      end
      # 
      #      desc "Return a a user's orders."
      #      get :user_order do
      #        authenticate!
      #        current_user.orders.limit(20)
      #      end
      # 
      #      desc "Return an order."
      #      params do
      #        requires :id, type: Integer, desc: "Order id."
      #      end
      #      route_param :id do
      #        get do
      #          Order.find(params[:id])
      #        end
      #      end
      # 
      #      desc "Create an order."
      #      params do
      #        requires :product, type: String, desc: "Product name."
      #      end
      #      post do
      #        authenticate!
      #        Order.create!({
      #          user: current_user,
      #          product: params[:status]
      #        })
      #      end
      # 
      #      desc "Delete an order."
      #      params do
      #        requires :id, type: String, desc: "Order ID."
      #      end
      #      delete ':id' do
      #        authenticate!
      #        current_user.orders.find(params[:id]).destroy
      #      end
      #    end
    # 
  end
end