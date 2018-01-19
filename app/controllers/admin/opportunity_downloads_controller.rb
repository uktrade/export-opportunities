class Admin::OpportunityDownloadsController < Admin::BaseController
  include ActionController::Live

  # Authentication for opportunity downloads is handled in routes.rb as
  # ActionController::Live and Devise don't play well together
  #
  # https://github.com/plataformatec/devise/issues/2332
  skip_before_action :authenticate_editor!, raise: false

  def new; end

  def create
    @opportunities = policy_scope(Opportunity).where(created_at: from..to)
    authorize @opportunities

    response.set_header('Content-Disposition', "attachment; filename=\"#{download_filename}\"")
    response.set_header('Content-Type', 'text/csv; charset=utf-8')

    csv = OpportunityCSV.new(@opportunities)

    begin
      csv.each do |row|
        response.stream.write(row)
      end
    ensure
      response.stream.close
    end

    redirect_to action: 'new'
  end

  private def from_params
    params.require(:created_at_from).permit(:year, :month, :day)
  end

  private def to_params
    params.require(:created_at_to).permit(:year, :month, :day)
  end

  private def download_filename
    "eig-opportunities-#{from.strftime('%Y-%m-%d')}-#{to.strftime('%Y-%m-%d')}.csv"
  end

  private def from
    @from ||= parse_date(from_params)
  end

  private def to
    @to ||= parse_date(to_params)
  end

  private def parse_date(params)
    raise ArgumentError, 'Invalid date: year was blank' if params[:year].blank?
    raise ArgumentError, 'Invalid date: month was blank' if params[:month].blank?
    raise ArgumentError, 'Invalid date: day was blank' if params[:day].blank?
    Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
  end
end
