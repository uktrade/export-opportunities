require 'rails_helper'
require 'lib/constraints/new_domain_constraint'

RSpec.feature 'visiting the site on different domains', :elasticsearch, :commit, sso: true do
  context 'opportunities.export.great.gov.uk' do
    context 'when not logged in' do
      scenario 'visiting / displays opportunities' do
        visit '/export-opportunities/'
        expect(page).to have_content 'Find export opportunities'
      end
    end

    context 'when logged in as a user' do
      before :each do
        mock_sso_with(email: 'email@example.com')
        visit '/export-opportunities/sign_in'
      end

      scenario 'visiting / displays opportunities, not the dashboard' do
        visit '/export-opportunities/'
        expect(page).to have_content 'Find export opportunities'
      end
    end

    context 'when logged in as an editor' do
      before :each do
        uploader = create(:uploader)
        login_as(uploader)
      end

      scenario 'visiting / displays opportunities, not the admin login page' do
        visit '/export-opportunities/'
        expect(page).to have_content 'Find export opportunities'
      end
    end

    context 'exportingisgreat.gov.uk' do
      scenario 'visiting /opportunities does not redirect' do
        allow_any_instance_of(NewDomainConstraint).to receive(:matches?).and_return(false)
        visit '/export-opportunities/opportunities'
        expect(current_path).to eq '/export-opportunities/opportunities'
        expect(page).to have_content 'Search results'
      end
    end
  end
end
