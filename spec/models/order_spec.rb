# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  describe '#id' do
    let(:order) { create(:order) }
    it 'generates a valid uuid' do
      expect(order.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end
  end

  describe 'validations' do
    context 'when order entry already exists' do
      let(:existing_order) { create(:order) }
      let(:duplicate_order) { build(:order, id: existing_order.id) }

      it 'is not valid' do
        expect(duplicate_order).not_to be_valid
      end
    end
  end
end
