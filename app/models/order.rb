# frozen_string_literal: true

class Order < ApplicationRecord
  before_create :generate_uuid, :set_initial_status

  validates :id, presence: true, uniqueness: true
  validates :store_id, presence: true
  validates :details, presence: true

  private

  def generate_uuid
    self.id = SecureRandom.uuid
  end

  def set_initial_status
    details['last_status_name'] = 'RECEIVED'
  end
end
