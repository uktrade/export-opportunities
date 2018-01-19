require 'rails_helper'

RSpec.describe Users::DashboardController, type: :controller do
  before :each do
    sign_in(create(:user))
  end

  describe 'GET dashboard controller index' do
    before(:each) do
      string_inquirer = ActiveSupport::StringInquirer.new('production')
      allow(Rails).to receive(:env).and_return(string_inquirer)
    end

    context 'if it is in production' do
      it 'redirects to SUD alerts page' do
        allow(Figaro.env).to receive(:SUD_PROFILE_PAGE_EMAIL_ALERTS).and_return('/sud_alerts')

        get :index, params: { target: 'alerts' }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to('/sud_alerts')
      end

      it 'redirects to SUD home page' do
        allow(Figaro.env).to receive(:SUD_PROFILE_PAGE).and_return('/sud_homepage')

        get :index

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to('/sud_homepage')
      end
    end
  end
end
