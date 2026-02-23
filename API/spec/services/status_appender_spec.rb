# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusAppender do
  describe '#append' do
    let(:order) { create(:order, details: { 'statuses' => [] }) }
    let(:appender) { StatusAppender.new }

    it 'appends a new status to the order' do
      result = appender.append(order.id, name: Order::STATUSES[:delivered], origin: 'STORE')

      expect(result.details['statuses'].length).to eq(2)
      expect(result.details['statuses'].last['name']).to eq(Order::STATUSES[:delivered])
      expect(result.details['last_status_name']).to eq(Order::STATUSES[:delivered])
    end

    it 'appends and updates in the correct flow until terminal state' do
      # Order starts with RECEIVED (from after_create callback)
      expected_flow = [Order::STATUSES[:confirmed], Order::STATUSES[:dispatched], Order::STATUSES[:delivered]]

      expected_flow.each do |status|
        result = appender.append(order.id, name: status, origin: 'STORE')
        order.reload # Reload to see updated data
        expect(result.details['last_status_name']).to eq(status)
        expect(order.details['statuses'].last['name']).to eq(status)
      end

      # Verify complete flow:
      expect(order.details['statuses'].length).to eq(4)
      expect(order.details['statuses'].map { |s| s['name'] }).to eq([
                                                                      Order::STATUSES[:received],
                                                                      Order::STATUSES[:confirmed],
                                                                      Order::STATUSES[:dispatched],
                                                                      Order::STATUSES[:delivered]
                                                                    ])
    end
  end
end
