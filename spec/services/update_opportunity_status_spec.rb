require 'rails_helper'
require 'app/services/update_opportunity_status'
require 'timecop'

RSpec.describe UpdateOpportunityStatus do
  describe '#call' do
    it 'sets the new status on the opportunity' do
      opportunity = create(:opportunity, :published)
      described_class.new.call(opportunity, 'pending')
      expect(opportunity).to be_pending
    end

    it 'disallows some statuses' do
      %w(trash).each do |disallowed_status|
        opportunity = create(:opportunity)
        expect { described_class.new.call(opportunity, disallowed_status) }
          .to raise_error(ArgumentError)
      end
    end

    it 'returns a successful result if opportunity is updated' do
      opportunity = create(:opportunity, :unpublished)

      result = described_class.new(fake_subscriber_notification_sender).call(opportunity, 'publish')
      expect(result.success?).to eq true
    end

    it 'returns a failure result if opportunity is not updated' do
      opportunity = double(:opportunity, update: false, first_published_at: Time.zone.now)

      result = described_class.new.call(opportunity, 'publish')
      expect(result.success?).to eq false
    end

    it 'notifies subscribers if the new status is publish' do
      opportunity = create(:opportunity, :unpublished)
      notification_sender = fake_subscriber_notification_sender

      described_class.new(notification_sender).call(opportunity, 'publish')

      expect(notification_sender).to have_received(:call).with(opportunity)
    end

    context 'when the status is set to "publish" for the first time' do
      it 'records the time' do
        opportunity = create(:opportunity, :unpublished)
        now = Time.now.utc

        Timecop.freeze(now) do
          described_class.new(fake_subscriber_notification_sender).call(opportunity, 'publish')
        end

        expect(opportunity.first_published_at).to eq now
      end
    end

    context 'when the status is set to "publish" after it was first published' do
      it 'does not change the time of first publication' do
        first_published_at = Time.now.utc - 100
        opportunity = create(:opportunity, :unpublished, first_published_at: first_published_at)

        described_class.new(fake_subscriber_notification_sender).call(opportunity, 'publish')
        expect(opportunity.first_published_at).to eq first_published_at
      end

      it 'does not notify subscribers' do
        opportunity = create(:opportunity, :published, first_published_at: Time.zone.yesterday)
        notification_sender = fake_subscriber_notification_sender

        described_class.new(notification_sender).call(opportunity, 'publish')

        expect(notification_sender).not_to have_received(:call).with(opportunity)
      end
    end
  end

  def fake_subscriber_notification_sender
    instance_double('SubscriberNotificationSender', call: nil)
  end
end
