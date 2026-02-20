# frozen_string_literal: true
class OrdersController < ApplicationController
  def index
    @orders = Order.all
    render json: @orders
  end
end
