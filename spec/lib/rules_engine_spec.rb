require 'rails_helper'

RSpec.describe RulesEngine do
  describe '#call' do
    it 'puts opportunities near to expiration into the trash' do
      opportunity = create(:opportunity,
        status: :draft,
        response_due_on: 6.days.from_now)
      RulesEngine.new.call(opportunity)
      opportunity.reload
      assert_equal :publish, opportunity.status.to_sym
    end
    it 'puts opportunities not near to expiration into the trash' do
      opportunity = create(:opportunity,
        status: :draft,
        response_due_on: 3.days.from_now)
      RulesEngine.new.call(opportunity)
      opportunity.reload
      assert_equal :trash, opportunity.status.to_sym
    end
  end
end
