# frozen_string_literal: true

class OrdersController < ApplicationController
  def index
    @orders = Order.all
    render json: @orders
  end

  def show
    order = Order.find(params[:id])
    render json: order
  end

  def append_status
    order = Order.find(params[:id])
    state_machine = StateMachine.new
    state_machine.transition_order(order.details['last_status_name'], order.id)
    order.reload
    render json: order
  end
end
