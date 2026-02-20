require 'rails_helper'

RSpec.describe 'Orders', type: :request do
  describe 'GET /orders' do
    it 'returns a successful response' do
      get orders_path
      expect(response).to have_http_status(200)
    end
  end
end
