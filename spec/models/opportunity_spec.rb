require 'rails_helper'

RSpec.describe Opportunity do
  describe 'validations' do
    subject { FactoryGirl.build(:opportunity) }
    it { is_expected.to validate_uniqueness_of(:slug).case_insensitive }
    it { is_expected.to have_many(:comments).class_name('OpportunityComment') }

    it 'has to have a title' do
      expect(Opportunity.new).to have(1).error_on(:title)
    end

    it 'has to have a teaser' do
      expect(Opportunity.new).to have(1).error_on(:teaser)
    end

    it 'has to have a response_due_on' do
      expect(Opportunity.new).to have(1).error_on(:response_due_on)
    end

    it 'has to have a description' do
      expect(Opportunity.new).to have(1).error_on(:description)
    end

    it 'has to have two contacts' do
      expect(Opportunity.new).to have(1).error_on(:contacts)
    end

    context 'when the contacts are valid' do
      it 'is valid' do
        valid_contact_details = [
          { name: 'Bob', email: 'bob@example.com' },
          { name: 'Mary', email: 'mary@example.com' },
        ]

        opportunity = Opportunity.new(contacts_attributes: valid_contact_details)
        opportunity.valid?

        expect(opportunity).to have(0).error_on(:contacts)
      end
    end

    context 'when the contacts are invalid' do
      it 'is invalid' do
        invalid_contact_details = [
          { name: 'Bob', email: '07123456789' },
          { name: '', email: 'mary@example.com' },
        ]

        opportunity = Opportunity.new(contacts_attributes: invalid_contact_details)
        opportunity.valid?

        expect(opportunity).to have(1).error_on(:"contacts.email")
        expect(opportunity).to have(1).error_on(:"contacts.name")
      end

      it 'does not count empty contacts towards the minimum contacts requirement' do
        opportunity = Opportunity.new(contacts_attributes: Array.new(Opportunity::CONTACTS_PER_OPPORTUNITY, {}))
        expect(opportunity).to have(1).error_on(:contacts)
      end
    end
  end

  describe 'applicable scope' do
    it 'should only find current opportunities' do
      past_due = create(:opportunity, response_due_on: 1.day.ago)
      due_today = create(:opportunity, response_due_on: Time.zone.today)
      due_future = create(:opportunity, response_due_on: 3.months.from_now)

      expect(Opportunity.applicable).to include(due_today)
      expect(Opportunity.applicable).to include(due_future)
      expect(Opportunity.applicable).to_not include(past_due)
    end
  end

  describe 'deletion' do
    it 'deletes its associated contacts' do
      opportunity = create(:opportunity)
      contacts = opportunity.contacts

      opportunity.destroy

      expect(contacts).to all(be_destroyed)
    end
  end

  describe 'versioning' do
    it 'records changes to its status field' do
      opportunity = create(:opportunity, status: :pending)
      opportunity.status = :publish
      opportunity.save

      expect(opportunity.versions.last).not_to be_nil
      expect(opportunity.versions.last.changeset['status']).to eq %w(pending publish)
    end
  end

  describe '#expired?' do
    it 'returns true when the opportunity has expired' do
      opportunity = create(:opportunity, response_due_on: 1.day.ago)
      expect(opportunity).to be_expired
    end

    it 'returns false when the opportunity expires today' do
      opportunity = create(:opportunity, response_due_on: Time.zone.today)
      expect(opportunity).not_to be_expired
    end

    it 'returns false when the opportunity has yet to expire' do
      opportunity = create(:opportunity, response_due_on: 1.day.from_now)
      expect(opportunity).not_to be_expired
    end
  end

  describe '#as_indexed_json' do
    it 'returns only the keys we want' do
      require 'set'

      opportunity = create(:opportunity)
      opportunity.sectors = create_list(:sector, 2)
      opportunity.countries = create_list(:country, 2)
      opportunity.types = create_list(:type, 2)
      opportunity.values = [create(:value)]

      returned = opportunity.as_indexed_json

      permitted_keys = Set.new %w(title teaser description countries sectors types values created_at updated_at status response_due_on first_published_at)
      returned_keys = Set.new(returned.keys)

      expect(permitted_keys).to eq returned_keys
    end
  end
end
