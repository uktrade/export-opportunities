class BasePresenter < ActionView::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper

  def initialize; end

  def put(value, default = 'none')
    value.present? && value != 'undefined' ? value : default
  end

  private def h
    ApplicationController.helpers
  end
end
