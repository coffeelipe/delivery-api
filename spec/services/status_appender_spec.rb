require 'rails_helper'

RSpec.describe StatusAppender do
  describe '#append' do
    let(:order) { create(:order, details: { 'statuses' => [], 'order_id' => order.id }) }
    let(:appender) { StatusAppender.new }

    it 'appends a new status to the order' do
      result = appender.append(order.id, name: Order::STATUSES[:delivered], origin: 'STORE')

      expect(result.details['statuses'].length).to eq(2)
      expect(result.details['statuses'].first['name']).to eq(Order::STATUSES[:delivered])
      expect(result.details['last_status_name']).to eq(Order::STATUSES[:delivered])
    end
  end
end
