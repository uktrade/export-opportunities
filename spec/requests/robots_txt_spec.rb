require 'rails_helper'

describe 'robots.txt' do
  let(:production_environment) { %w[staging development].include? Figaro.env.RAILS_ENV }
  let(:prevent_search_engines) { Figaro.env.DISALLOW_ALL_WEB_CRAWLERS }

  describe 'search engine prevention' do
    it 'should not be active in Production' do
      if production_environment
        expect(prevent_search_engines).to be_falsey
      end
    end

    it 'should be active in Development or Staging' do
      if !production_environment
        expect(prevent_search_engines).to be_truthy
      end
    end
  end

  context 'when not blocking all web crawlers' do
    it 'allows all crawlers' do
      if prevent_search_engines.nil?
        get '/robots.txt'

        expect(response.code).to eq '404'
        expect(response.headers['X-Robots-Tag']).to be_nil
      end
    end
  end

  context 'when blocking all web crawlers' do
    it 'blocks all crawlers' do
      if prevent_search_engines.present?
        get '/robots.txt'

        expect(response).to render_template 'disallow_all'
        expect(response.headers['X-Robots-Tag']).to eq 'noindex, nofollow'
      end
    end
  end
end
