# frozen_string_literal: true
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'json'

json_file_path = Rails.root.join('db', 'seeds', 'pedidos.json')
data = JSON.parse(File.read(json_file_path))

data.each do |entry|
  Order.find_or_create_by!(
    id: entry['order_id'],
    store_id: entry['store_id'],
    details: entry['order']
  )
end
