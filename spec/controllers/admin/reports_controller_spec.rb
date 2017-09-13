require 'rails_helper'

RSpec.describe Admin::ReportsController, type: :controller do
  describe 'GET index' do
    subject(:get_index) { get :index }
  end

  describe '#index' do
    login_editor(role: :admin)

    let(:country) { create(:country) }

    it 'renders an index page' do
      response = get(:index, commit: 'Generate')

      expect(response.inspect).to have_content('The requested Monthly Outcome against Targets by Country report has been emailed to you.')
    end
  end
end
