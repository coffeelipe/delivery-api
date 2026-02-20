# frozen_string_literal: true

class Order < ApplicationRecord
  before_create :generate_uuid

  validates :id, presence: true, uniqueness: true
  validates :store_id, presence: true
  validates :details, presence: true

  private

  def generate_uuid
    self.id = SecureRandom.uuid
  end
end
