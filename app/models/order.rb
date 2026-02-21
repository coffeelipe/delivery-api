# frozen_string_literal: true

class Order < ApplicationRecord
  STATUSES = {
    received: 'RECEIVED',
    confirmed: 'CONFIRMED',
    dispatched: 'DISPATCHED',
    delivered: 'DELIVERED',
    canceled: 'CANCELED'
  }.freeze

  before_create :generate_uuid, :set_initial_status

  validates :id, presence: true, uniqueness: true
  validates :store_id, presence: true
  validates :details, presence: true

  private

  def generate_uuid
    self.id = SecureRandom.uuid if id.blank?
  end
  end

  def set_initial_status
    StatusAppender.new.append(id, name: STATUSES[:received], origin: 'STORE')
  end
end
