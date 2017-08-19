class Admin::HelpController < Admin::BaseController
  after_action :verify_authorized, except: [:show]

  def show
    shorten_link_id = params[:id]
    DocumentUrlShortener.new.s3_link(current_user, 1, shorten_link_id)
  end
end
