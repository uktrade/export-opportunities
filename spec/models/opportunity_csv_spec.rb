require 'rails_helper'

describe OpportunityCSV do
  describe '#each' do
    it 'yields the CSV header, even when there are no opportunities' do
      expect { |b| subject.each(&b) }.to yield_with_args(expected_header)
    end

    it 'yields the CSV header and then the rows in turn' do
      service_provider = create(:service_provider, name: 'Morocco OBNI')
      countries = [create(:country, name: 'Morocco')]
      sectors = [create(:sector, name: 'Communications'), create(:sector, name: 'Education & Training')]
      contacts = [build(:contact, email: 'bill@example.com'), build(:contact, email: 'sue@example.com')]
      uploader = build(:uploader, email: 'author@example.com')

      opportunity = create(
        :opportunity,
        title: 'Morocco - English language training requested',
        contacts: contacts,
        countries: countries,
        service_provider: service_provider,
        sectors: sectors,
        status: :publish,
        response_due_on: Date.new(2015, 8, 15),
        created_at: DateTime.new(2016, 8, 6, 13, 45, 30).utc,
        first_published_at: DateTime.new(2016, 8, 15, 10, 25, 19).utc,
        updated_at: Date.new(2016, 7, 27),
        author: uploader
      )

      create(:enquiry, opportunity: opportunity)

      expected_row = "2016-08-06 13:45:30,2016-08-15 10:25:19,2016/07/27,Morocco - English language training requested,1,Morocco OBNI,\"bill@example.com,sue@example.com\",author@example.com,2015/08/15,Morocco,\"Communications,Education & Training\",Published\n"

      expect { |b| subject.each(&b) }.to yield_successive_args(expected_header, expected_row)
    end

    it 'yields the CSV with the minimum number of valid fields' do
      service_provider = create(:service_provider, name: 'Morocco OBNI')
      uploader = build(:uploader, email: 'author@example.com')

      create(
        :opportunity,
        title: 'Morocco - English language training requested',
        countries: [],
        service_provider: service_provider,
        sectors: [],
        status: :pending,
        response_due_on: Date.new(2015, 8, 15),
        created_at: DateTime.new(2016, 7, 21, 10, 0, 12).utc,
        first_published_at: DateTime.new(2016, 8, 15, 10, 25, 19).utc,
        updated_at: Date.new(2016, 7, 27),
        contacts: [
          create(:contact, email: 'contact@example.com'),
          create(:contact, email: 'second@example.com'),
        ],
        author: uploader
      )

      expected_row = "2016-07-21 10:00:12,2016-08-15 10:25:19,2016/07/27,Morocco - English language training requested,0,Morocco OBNI,\"contact@example.com,second@example.com\",author@example.com,2015/08/15,,,Pending\n"

      expect { |b| subject.each(&b) }.to yield_successive_args(expected_header, expected_row)
    end

    it 'humanizes status' do
      create(:opportunity, status: 'publish')

      expect { |b| subject.each(&b) }.to yield_successive_args(expected_header, /Published/)
    end

    it 'does not choke when the opportunity has an invalid status' do
      opportunity = create(:opportunity)
      opportunity.update_column(:status, 999)

      expect { |b| subject.each(&b) }.to yield_control.twice
    end
  end

  def expected_header
    "Created at,First published,Updated at,Title,Number of responses,Service provider,Contact email addresses,Uploader email address,Expiry date,Countries,Sectors,Status\n"
  end
end
