RSpec.describe StateMachine do
  describe '#valid_transition?' do
    let(:state_machine) { StateMachine.new }

    it 'disallows backwards transitions' do
      expect(state_machine.valid_transition?(Order::STATUSES[:confirmed], Order::STATUSES[:received])).to be_falsey
      expect(state_machine.valid_transition?(Order::STATUSES[:dispatched], Order::STATUSES[:confirmed])).to be_falsey

      # CANCELED is a terminal state, so no transitions allowed from it
      expect(state_machine.valid_transition?(Order::STATUSES[:canceled], Order::STATUSES[:received])).to be_falsey
      expect(state_machine.valid_transition?(Order::STATUSES[:canceled], Order::STATUSES[:confirmed])).to be_falsey
      expect(state_machine.valid_transition?(Order::STATUSES[:canceled], Order::STATUSES[:dispatched])).to be_falsey
      expect(state_machine.valid_transition?(Order::STATUSES[:canceled], Order::STATUSES[:delivered])).to be_falsey

      # DELIVERED is a terminal state, so no transitions allowed from it
      expect(state_machine.valid_transition?(Order::STATUSES[:delivered], Order::STATUSES[:received])).to be_falsey
      expect(state_machine.valid_transition?(Order::STATUSES[:delivered], Order::STATUSES[:confirmed])).to be_falsey
      expect(state_machine.valid_transition?(Order::STATUSES[:delivered], Order::STATUSES[:dispatched])).to be_falsey
      expect(state_machine.valid_transition?(Order::STATUSES[:delivered], Order::STATUSES[:canceled])).to be_falsey
    end

    it 'allows valid forward transitions' do
      expect(state_machine.valid_transition?(Order::STATUSES[:received], Order::STATUSES[:confirmed])).to be_truthy
      expect(state_machine.valid_transition?(Order::STATUSES[:received], Order::STATUSES[:canceled])).to be_truthy
      expect(state_machine.valid_transition?(Order::STATUSES[:confirmed], Order::STATUSES[:dispatched])).to be_truthy
      expect(state_machine.valid_transition?(Order::STATUSES[:confirmed], Order::STATUSES[:canceled])).to be_truthy
      expect(state_machine.valid_transition?(Order::STATUSES[:dispatched], Order::STATUSES[:delivered])).to be_truthy
      expect(state_machine.valid_transition?(Order::STATUSES[:dispatched], Order::STATUSES[:canceled])).to be_truthy
    end
  end
end
