require 'rails_helper'

RSpec.describe DeduplicateStubUsers do
  describe '#call' do
    it 'removes users with duplicate email addresses' do
      create(:user, :stub, email: 'email@example.com')
      create(:user, :stub, email: 'email@example.com')

      DeduplicateStubUsers.new.call

      expect(User.where(email: 'email@example.com').count).to eql 1
    end

    it 'prefers to remove stub users with duplicate email addresses' do
      real_user = create(:user, email: 'email@example.com')
      stub_user = create(:user, :stub, email: 'email@example.com')

      DeduplicateStubUsers.new.call

      expect(User.where(email: 'email@example.com')).to include(real_user)
      expect(User.where(email: 'email@example.com')).not_to include(stub_user)
    end

    it 'removes all but one of the duplicated users' do
      create_list(:user, 5, :stub, email: 'email@example.com')

      DeduplicateStubUsers.new.call

      expect(User.where(email: 'email@example.com').count).to eq 1
    end

    context 'when a real user is available to assign associations to' do
      it 'reassigns enquiries to the remaining matching account' do
        real_user = create(:user, email: 'email@example.com')

        stub_user = create(:user, :stub, email: 'email@example.com')
        enquiry = create(:enquiry, user: stub_user)

        DeduplicateStubUsers.new.call

        real_user.reload

        expect(real_user.enquiries).to include(enquiry)
      end

      it 'reassigns subscriptions to the remaining matching account' do
        real_user = create(:user, email: 'email@example.com')

        stub_user = create(:user, :stub, email: 'email@example.com')
        subscription = create(:subscription, user: stub_user)

        DeduplicateStubUsers.new.call

        real_user.reload

        expect(real_user.subscriptions).to include(subscription)
      end
    end

    context 'when there is no real user to assign associations to' do
      it 'chooses a single stub user and assigns enquiries to it' do
        stub_user = create(:user, :stub, email: 'email@example.com')
        stub_user2 = create(:user, :stub, email: 'email@example.com')

        first_enquiry = create(:enquiry, user: stub_user)
        second_enquiry = create(:enquiry, user: stub_user2)

        DeduplicateStubUsers.new.call

        selected_user = User.find_by(email: 'email@example.com')

        expect(selected_user.enquiries).to include(first_enquiry)
        expect(selected_user.enquiries).to include(second_enquiry)
      end

      it 'chooses a single stub user and assigns subscriptions to it' do
        stub_user = create(:user, :stub, email: 'email@example.com')
        stub_user2 = create(:user, :stub, email: 'email@example.com')

        first_subscription = create(:subscription, user: stub_user)
        second_subscription = create(:subscription, user: stub_user2)

        DeduplicateStubUsers.new.call

        selected_user = User.find_by(email: 'email@example.com')

        expect(selected_user.subscriptions).to include(first_subscription)
        expect(selected_user.subscriptions).to include(second_subscription)
      end
    end
  end
end
