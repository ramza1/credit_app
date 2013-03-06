class ApplicationController < ActionController::Base
  protect_from_forgery :except => [:notify, :thank_you, :failure, :get_response, :single_notify]

  skip_before_filter :verify_authenticity_token, if: :json_request?

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url
  end

  protected

  def json_request?
    request.format.json?
  end
end
