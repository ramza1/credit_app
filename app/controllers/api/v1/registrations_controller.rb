class Api::V1::RegistrationsController< ApplicationController
  respond_to :json
  def create
 
    @user = User.new(params[:user])
    if @user.save
      @user.ensure_authentication_token!
      json=Jbuilder.encode do |json|
        json.status "success"
        json.user do|json|
          json.phone_number @user.phone_number
          json.wallet do|json|
              json.account_balance_currency view_context.number_to_currency(@user.wallet.account_balance, unit: "NGN ", precision: 0)
              json.account_balance @user.wallet.account_balance
      	      json.touch @user.wallet.updated_at.to_time.to_i.to_s
            end
          end
          json.token @user.authentication_token
        end
      render :json=> json, :status=>201
      return
    else
      warden.custom_failure!
      data={}
      data[:errors]=@user.errors
      data[:message]=@user.errors
      data[:status]="failed"
      logger.info "data: #{data.to_json}"
      render :json=> data, :status=>200
    end
  end
end