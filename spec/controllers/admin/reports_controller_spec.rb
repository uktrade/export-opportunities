require 'rails_helper'

RSpec.describe Admin::ReportsController, type: :controller do
  describe 'GET index' do
    subject(:get_index) { get :index }
  end

  describe '#index' do
    login_editor(role: :admin)

    let(:country) { create(:country) }

    it 'renders an index page' do
      skip('TODO: fix')
      expect(get(:index, commit: :Generate)).to render_template('admin/reports/index')
    end
  end
end
