class Api::V1::RegistrationsController< ApplicationController
  respond_to :json
  def create
 
    user = User.new(params[:user])
    if user.save
      render :json=> user.as_json(:auth_token=>user.authentication_token, :email=>user.email,:status=>"failed"), :status=>201
      return
    else
      warden.custom_failure!
      data={}
      data[:errors]=user.errors
      data[:message]=user.errors
      data[:status]="failed"
      logger.info "data: #{data.to_json}"
      render :json=> data, :status=>200
    end
  end
end