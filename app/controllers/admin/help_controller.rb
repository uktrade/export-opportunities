class Admin::HelpController < Admin::BaseController
  after_action :verify_authorized, except: [:index, :show]

  def show
    page_url = params[:id]
    case page_url
    when 'opportunities'
      render 'admin/opportunities/help'
    when 'enquiries'
      render 'admin/enquiries/help'
    else
      render 'errors/not_found'
    end
  end
end
