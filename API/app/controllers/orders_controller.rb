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

  def create
    details_params = params[:details] || {}

    # for simplicity, I'm not validating details
    # given more time, I would break down details into a separate model
    order = Order.create!(
      store_id: params[:store_id],
      details: details_params.to_unsafe_h
    )
    render json: order, status: :created
    puts order.to_json
  end

  def destroy
    order = Order.find(params[:id])
    order.destroy
    head :no_content
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
