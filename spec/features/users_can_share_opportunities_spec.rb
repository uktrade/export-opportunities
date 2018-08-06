require 'rails_helper'

RSpec.feature 'Users can share an opportunity' do

  context 'from the opportunity page' do
    before do
      opportunity = create(:opportunity, :published, title: 'A particularly interesting opportunity')
      @opp_title = opportunity.title
      @opp_path = opportunity_url(opportunity)
      visit opportunity_path(opportunity)
    end

    scenario 'with Twitter' do
      twitter_share_link = "https://twitter.com/intent/tweet?text=#{@opp_title} #{@opp_path}"
      link = find_link('Share with Twitter')

      expect(link).to_not be(nil)
      expect(link['href']).to eq(twitter_share_link)
    end

    scenario 'with Facebook' do
      facebook_share_link = "http://www.facebook.com/share.php?u=#{@opp_path}"
      link = find_link('Share with Facebook')

      expect(link).to_not be(nil)
      expect(link['href']).to eq(facebook_share_link)
    end

    scenario 'with LinkedIn' do
      linkedin_share_link = "https://www.linkedin.com/shareArticle?mini=true&url=#{@opp_path}&title=#{@opp_title}&source=LinkedIn"
      link = find_link('Share with LinkedIn')

      expect(link).to_not be(nil)
      expect(link['href']).to eq(linkedin_share_link)
    end

    scenario 'by email' do
      email_share_link  = "mailto:?body=#{@opp_path}&amp;subject=#{@opp_title}"
      link = find_link('Share by email')

      expect(link).to_not be(nil)
      expect(link['href']).to eq(email_share_link)
    end
  end
end
