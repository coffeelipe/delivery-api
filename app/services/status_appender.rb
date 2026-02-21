class StatusAppender
  def append(order_id, name:, origin:)
    order = Order.find(order_id)
    status = new_status(order, name: name, origin: origin)
    order.details['statuses'] << status
    order.details['last_status_name'] = status['name']
    order.save!
    order
  end

  private

  def new_status(order, name:, origin:)
    {
      'created_at' => (Time.now.to_f * 1000).to_i,
      'name' => name,
      'order_id' => order.details['order_id'],
      'origin' => origin
    }
  end
end
