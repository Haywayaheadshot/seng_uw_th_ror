class BaseController < ApplicationController
  # Remove Comment after creating authentication
  # before_action :require_admin

  # def require_admin
  #   redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
  # end
end
