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
end
