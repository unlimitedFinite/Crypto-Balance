class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_credentials
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def set_credentials
    unless params[:controller].include?("devise")
      Binance::Api::Configuration.api_key = current_user.api_key
      Binance::Api::Configuration.secret_key = current_user.secret_key
    end
  end

def after_sign_in_path_for(resource)
  stored_location_for(resource) || portfolio_path(current_user)
end

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :api_key, :secret_key])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :api_key, :secret_key])
  end
end
