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

  def append_status # rubocop:disable Metrics/AbcSize
    order = Order.find(params[:id])
    state_machine = StateMachine.new
    return if state_machine.terminal_state?(order.details['last_status_name'])

    if params[:cancel].to_s == 'true' || params[:cancel] == true

      state_machine.cancel_order(order.details['last_status_name'], order.id)

    else
      state_machine.transition_order(order.details['last_status_name'], order.id)
    end
    order.reload
    render json: order
  end
end
