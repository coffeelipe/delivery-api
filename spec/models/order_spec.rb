require 'rails_helper'

RSpec.describe Order, type: :model do
  describe '#id' do
    let(:order) { create(:order) }
    it 'generates a valid uuid' do
      expect(order.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end
  end
end
