class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders, id: :string do |t|
      t.string :store_id
      t.json :order

      t.timestamps
    end
  end
end
