module Admin
  class ReportsController < BaseController
    def index
      authorize :reports

      @result = 'report'
    end
  end
end
