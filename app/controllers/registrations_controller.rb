class RegistrationsController < Devise::RegistrationsController
  skip_before_action :set_credentials

  def after_sign_up_path_for(_resource)
    new_portfolio_path
  end
end
