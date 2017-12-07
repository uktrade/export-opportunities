require 'rails_helper'

RSpec.describe 'Viewing the ATOM feed for opportunities', :elasticsearch, :commit, type: :request do
  it 'returns a valid ATOM feed' do
    create(:opportunity,
      :published,
      id: '0a0a7bdc-0da8-439a-978a-758601d7a8ce',
      title: 'Atom Feed Required',
      slug: 'atom-feed-required',
      teaser: 'A company requires an Atom feed',
      description: 'This is some example content',
      author: create(:editor, name: 'Joe Atom'),
      sectors: [create(:sector, name: 'Atoms', slug: 'atoms')],
      updated_at: DateTime.new(2016, 9, 20, 18, 0, 0).utc,
      first_published_at: DateTime.new(2016, 9, 11, 18, 0, 0).utc)

    sleep 1
    get '/opportunities.atom'

    body = parse_xml(response.body)

    expect(response.status).to eql 200
    expect(response.headers['Content-Type']).to eql 'application/atom+xml; charset=utf-8'

    expect(body.at_css('feed > id').text).to eql 'tag:www.example.com,2016:/opportunities'
    expect(body.at_css('feed > title').text).to eql 'Export opportunities'
    expect(body.at_css('feed > subtitle').text).to eql 'The demand is out there. You could be too.'
    expect(body.at_css('feed > updated').text).to eql '2016-09-20T18:00:00Z'

    expect(body.at_css('feed > link[rel=self]').attr('type')).to eql 'application/atom+xml'
    expect(body.at_css('feed > link[rel=self]').attr('href')).to eql 'http://www.example.com/opportunities.atom'
    expect(body.at_css('feed > link[rel=alternate]').attr('type')).to eql 'text/html'
    expect(body.at_css('feed > link[rel=alternate]').attr('href')).to eql 'http://www.example.com/opportunities'

    expect(body.at_css('feed > entry > title').text).to eql 'Atom Feed Required'
    expect(body.at_css('feed > entry > id').text).to eql 'tag:www.example.com,2016:Opportunity/0a0a7bdc-0da8-439a-978a-758601d7a8ce'
    expect(body.at_css('feed > entry > link').attr('rel')).to eql 'alternate'
    expect(body.at_css('feed > entry > link').attr('href')).to eql 'http://www.example.com/opportunities/atom-feed-required'
    expect(body.at_css('feed > entry > link').attr('type')).to eql 'text/html'
    expect(body.at_css('feed > entry > updated').text).to eql '2016-09-20T18:00:00Z'
    expect(body.at_css('feed > entry > published').text).to eql '2016-09-11T18:00:00Z'
    expect(body.at_css('feed > entry > summary').text).to eql 'A company requires an Atom feed'
    expect(body.at_css('feed > entry > content').text).to eql '<p>This is some example content</p>'
    expect(body.at_css('feed > entry > author > name').text).to eql 'Joe Atom'
    expect(body.at_css('feed > entry > category').attr('term')).to eql 'atoms'
    expect(body.at_css('feed > entry > category').attr('label')).to eql 'Atoms'
  end

  it 'returns the correct number of results' do
    create_list(:opportunity, 2, :published)

    sleep 1
    get '/opportunities.atom'
    body = parse_xml(response.body)

    expect(body.css('feed > entry').count).to eql 2
  end

  it "returns the feed's updated field correctly" do
    recently_updated = create(:opportunity, :published, updated_at: 5.minutes.ago)
    create(:opportunity, :published, updated_at: 30.minutes.ago)
    create(:opportunity, updated_at: 1.minute.ago)

    sleep 1
    get '/opportunities.atom'
    body = parse_xml(response.body)

    expect(body.at_css('feed > updated').text).to eql(recently_updated.updated_at.iso8601)
  end

  it 'returns an empty list when there are no results' do
    get '/opportunities.atom'
    body = parse_xml(response.body)

    expect(response.status).to eql 200
    expect(body.at_css('feed > entry')).to be_nil
    expect(body.at_css('feed > updated')).to be_nil
  end

  it 'returns the opportunities ordered by updated_at, with newest first' do
    newest_opportunity = create(:opportunity, :published, response_due_on: 3.days.from_now, updated_at: 1.day.ago, title: 'newest')
    new_opportunity = create(:opportunity, :published, response_due_on: 2.days.from_now, updated_at: 2.days.ago, title: 'new')
    old_opportunity = create(:opportunity, :published, response_due_on: 1.day.from_now, updated_at: 3.days.ago, title: 'old')

    sleep 1
    get '/opportunities.atom'
    body = parse_xml(response.body)

    expect(body.css('feed > entry:eq(1) > title').text).to eql newest_opportunity.title
    expect(body.css('feed > entry:eq(2) > title').text).to eql new_opportunity.title
    expect(body.css('feed > entry:eq(3) > title').text).to eql old_opportunity.title

    expect(body.css('feed > updated').text).to eql newest_opportunity.updated_at.iso8601
  end

  context 'pagination' do
    it 'adds links to the next page when appropriate' do
      create_list(:opportunity, 25, :published)

      sleep 1
      get '/opportunities.atom'

      body = parse_xml(response.body)

      expect(body.css('feed > link[rel=next]')).to be_empty

      create(:opportunity, :published)

      sleep 1
      get '/opportunities.atom'
      body = parse_xml(response.body)

      expect(body.css('feed > link[rel=next]').attr('href').text).to eql 'http://www.example.com/opportunities.atom?paged=2'

      sleep 1
      get '/opportunities.atom?paged=2'
      body = parse_xml(response.body)

      expect(body.css('feed > link[rel=next]')).to be_empty
    end

    it 'adds links to the previous page when appropriate' do
      create_list(:opportunity, 26, :published)

      sleep 1
      get '/opportunities.atom'
      body = parse_xml(response.body)

      expect(body.css('feed > link[rel=prev]')).to be_empty

      get '/opportunities.atom?paged=2'
      body = parse_xml(response.body)

      expect(body.css('feed > link[rel=prev]').attr('href').text).to eql 'http://www.example.com/opportunities.atom?paged=1'
    end
  end

  private

  def parse_xml(body)
    doc = Nokogiri::XML(body, &:noblanks) # Ignore empty nodes
    doc.remove_namespaces! # Simplify xpath needed to query nodes
  end
end
