class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
   if current_user.admin?
     @page=(params[:page]||1).to_i
     @per_page  = (params[:per_page] || 20).to_i
     @count=User.count
     @users = User.includes(:wallet).order("created_at desc").page(@page).per_page(@per_page)

   else
      redirect_to root_url, alert: "Access denied"
   end
  end

  def show
    @user ||= User.find(params[:id])
    if current_user.can_edit?(@user)
      @user = User.find(params[:id])
    else
      render :text => 'Sorry you are not authorized to do that', :layout => true, :status => 401
    end
  end

  def transactions
    @user ||= User.find(params[:id])
    if current_user.can_edit?(@user)
      @user = User.find(params[:id])
    else
      render :text => 'Sorry you are not authorized to do that', :layout => true, :status => 401
    end
  end

  def profile
    @user ||= User.find(params[:id])
    if current_user.can_edit?(@user)
      @user = User.find(params[:id])
    else
      render :text => 'Sorry you are not authorized to do that', :layout => true, :status => 401
    end
  end

  def edit
    @user ||= User.find(params[:id])
    if current_user.can_edit?(@user)
      @user = User.find(params[:id])
    else
      render :text => 'Sorry you are not authorized to do that', :layout => true, :status => 401
    end
  end

  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'Profile was successfully updated.' }
        format.json { head :ok }
      else
        format.html {redirect_to @user}
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    @page=(params[:page]||1).to_i
    @per_page  = (params[:per_page] || 20).to_i
    @count=User.count
    @users = User.where("phone_number LIKE (?) OR email LIKE (?)", "%#{params[:search_params]}%", "%#{params[:search_params]}%").page(@page).per_page(@per_page)
  end

  def credit_wallet
    @user = User.find(params[:id])
  end

  def amount_to_credit
    @user = User.find(params[:id])
    amount = params[:amount].to_i
    deposit(amount, @user)
  end

  def deposit(amount, user)
    @order= MoneyOrder.new
    @order.name = user.wallet.name
    @order.user= user
    @order.item= user.wallet
    @order.payment_method="Direct Funding"
    @order.amount = amount
    if @order.save
     @order.direct_pay
     @wallet = user.wallet
     @wallet.credit_wallet(amount.to_i)
     redirect_to credit_wallet_user_path(user), notice: "Account credited with #{amount}, current account balance is #{@wallet.account_balance}"
    else
      redirect_to credit_wallet_user_path(user), alert: "Amount too low"
    end
  end

end
