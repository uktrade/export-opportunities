class Users::BaseController < ApplicationController
  before_action :require_sso!
end
