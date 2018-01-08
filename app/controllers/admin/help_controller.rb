class Admin::HelpController < Admin::BaseController
  after_action :verify_authorized, except: %i[index show]

  def show
    page_url = params[:id]
    case page_url

    when 'how-to-assess-a-uk-company'
      render 'admin/help/how_to_assess_a_uk_company/overview'
    when 'right-for-opportunity-responses'
      render 'admin/help/right_for_opportunity_responses/overview'
   when 'not-right-for-opportunity-responses'
      render 'admin/help/not_right_for_opportunity_responses/overview'

    when 'opportunities'
      render 'admin/opportunities/help'
    when 'enquiries'
      render 'admin/enquiries/help'
    else
      render 'errors/not_found'
    end
  end

end
