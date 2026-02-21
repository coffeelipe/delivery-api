class StateMachine
  # states order: RECEIVED -> CONFIRMED -> DISPATCHED -> DELIVERED
  #                 \------------\-----------\---------> CANCELED
  TRANSITIONS = {
    Order::STATUSES[:received] => [Order::STATUSES[:confirmed], Order::STATUSES[:canceled]],
    Order::STATUSES[:confirmed] => [Order::STATUSES[:dispatched], Order::STATUSES[:canceled]],
    Order::STATUSES[:dispatched] => [Order::STATUSES[:delivered], Order::STATUSES[:canceled]],
    Order::STATUSES[:delivered] => [],
    Order::STATUSES[:canceled] => []
  }.freeze

  def initialize
    @appender = StatusAppender.new
    @origin = 'STORE'
  end

  def valid_transition?(current_status, new_status)
    allowed_transitions = TRANSITIONS[current_status] || []
    allowed_transitions.include?(new_status)
  end

  def cancel_order(current_status, order_id)
    @appender.append(order_id, name: Order::STATUSES[:canceled], origin: @origin) if cancelable?(current_status)
  end

  def transition_order(current_status, order_id)
    return if terminal_state?(current_status)

    case current_status
    when Order::STATUSES[:received]
      @appender.append(order_id, name: Order::STATUSES[:confirmed], origin: @origin)
    when Order::STATUSES[:confirmed]
      @appender.append(order_id, name: Order::STATUSES[:dispatched], origin: @origin)
    when Order::STATUSES[:dispatched]
      @appender.append(order_id, name: Order::STATUSES[:delivered], origin: @origin)
    end
  end

  private

  def cancelable?(status)
    TRANSITIONS[status]&.include?(Order::STATUSES[:canceled])
  end

  def terminal_state?(status)
    TRANSITIONS[status].empty?
  end
end
