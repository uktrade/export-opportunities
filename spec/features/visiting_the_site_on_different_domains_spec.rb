require 'rails_helper'
require 'lib/constraints/new_domain_constraint'

RSpec.feature 'visiting the site on different domains', :elasticsearch, :commit do
  context 'opportunities.export.great.gov.uk' do
    context 'when not logged in' do
      scenario 'visiting / displays opportunities' do
        visit '/'
        expect(page).to have_content 'Find and apply for overseas opportunities'
      end

      scenario 'visiting /opportunities redirects to /' do
        allow_any_instance_of(NewDomainConstraint).to receive(:matches?).and_return(true)

        visit '/opportunities'
        expect(current_path).to eq '/'
        expect(page).to have_content 'Find and apply for overseas opportunities'
      end
    end

    context 'when logged in as a user' do
      before :each do
        mock_sso_with(email: 'email@example.com')
        visit '/sign_in'
      end

      scenario 'visiting / displays opportunities, not the dashboard' do
        visit '/'
        expect(page).to have_content 'Find and apply for overseas opportunities'
      end
    end

    context 'when logged in as an editor' do
      before :each do
        uploader = create(:uploader)
        login_as(uploader)
      end

      scenario 'visiting / displays opportunities, not the admin login page' do
        visit '/'
        expect(page).to have_content 'Find and apply for overseas opportunities'
      end
    end

    context 'exportingisgreat.gov.uk' do
      scenario 'visiting /opportunities does not redirect' do
        allow_any_instance_of(NewDomainConstraint).to receive(:matches?).and_return(false)
        visit '/opportunities'
        expect(current_path).to eq '/opportunities'
        expect(page).to have_content 'Find and apply for overseas opportunities'
      end
    end
  end
end
