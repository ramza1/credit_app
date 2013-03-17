json.status "success"
json.user do|json|
   json.phone_number @user.phone_number
   json.account_balance number_to_currency(@user.account_balance, unit: "₦", precision: 0)
   json.account_balance_val @user.account_balance
end
json.token @user.authentication_token
