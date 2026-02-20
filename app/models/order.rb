# frozen_string_literal: true

class Order < ApplicationRecord
  before_create :generate_uuid

  validates :id, uniqueness: true

  private

  def generate_uuid
    self.id = SecureRandom.uuid
  end
end
