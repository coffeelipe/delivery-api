# frozen_string_literal: true

class Order < ApplicationRecord
  STATUSES = {
    received: 'RECEIVED',
    confirmed: 'CONFIRMED',
    dispatched: 'DISPATCHED',
    delivered: 'DELIVERED',
    canceled: 'CANCELED'
  }.freeze

  before_validation :generate_uuid, on: :create
  before_create :initialize_details
  after_create :set_initial_status

  validates :id, presence: true, uniqueness: true
  validates :store_id, presence: true
  validates :details, presence: true

  private

  def generate_uuid
    self.id = SecureRandom.uuid if id.blank?
  end

  def initialize_details
    details['order_id'] = id  # Always sync to match the database id
    details['statuses'] ||= []
  end

  def set_initial_status
    StatusAppender.new.append(id, name: STATUSES[:received], origin: 'STORE')
    reload
  end
end
