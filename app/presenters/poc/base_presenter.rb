class Poc::BasePresenter < ActionView::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper

  def initialize
  end

  private def h
    ApplicationController.helpers
  end
end
