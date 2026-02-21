# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Orders', type: :request do
  describe 'GET /orders' do
    it 'returns a successful response' do
      get orders_path
      expect(response).to have_http_status(200)
    end

    it 'responds as JSON' do
      get orders_path, headers: { 'ACCEPT' => 'application/json' }
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end
  end

  describe 'PATCH /orders/:id/status' do
    let(:order) { create(:order) }

    it 'appends a new status to the order' do
      patch status_order_path(order.id), headers: { 'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq('application/json; charset=utf-8')

      json_response = JSON.parse(response.body)
      expect(json_response['details']['statuses'].length).to eq(2)
      expect(json_response['details']['statuses'].last['name']).to eq(Order::STATUSES[:confirmed])
      expect(json_response['details']['last_status_name']).to eq(Order::STATUSES[:confirmed])
    end
  end
end
