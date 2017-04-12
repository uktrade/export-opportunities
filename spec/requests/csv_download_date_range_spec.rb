require 'rails_helper'

RSpec.describe 'Downloading a CSV' do
  describe 'date ranges:' do
    it 'raises a sensible error when no dates are provided' do
      login_as create(:admin)

      url = '/admin/opportunities/downloads'

      expect { post url, {} }.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: created_at_from')
    end

    it 'raises a sensible error when a "to" date is provided but the "from" date is missing' do
      login_as create(:admin)

      params = { created_at_to: { year: '2017', month: '1', day: '16' } }
      url = '/admin/opportunities/downloads.csv'

      expect { post url, params }.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: created_at_from')
    end

    it 'raises a sensible error when the "from" date is provided but the "to" date is missing' do
      login_as create(:admin)

      params = { created_at_from: { year: '2017', month: '1', day: '16' } }
      url = '/admin/opportunities/downloads.csv'

      expect { post url, params }.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: created_at_to')
    end

    it 'returns a sensible error when parts of date range values are missing' do
      login_as create(:admin)

      params = { created_at_from: { year: '', month: '1', day: '16' } }
      url = '/admin/opportunities/downloads.csv'

      expect { post url, params }.to raise_error(ArgumentError, 'Invalid date: year was blank')
    end
  end
end
