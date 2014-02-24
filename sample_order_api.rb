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
  end
end