# frozen_string_literal: true

class RenameOrderToDetailsInOrders < ActiveRecord::Migration[8.1]
  def change
    rename_column :orders, :order, :details
  end
end
