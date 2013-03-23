json.status "success"
json.user do|json|
   json.phone_number @user.phone_number
   json.wallet do|json|
      json.account_balance_currency number_to_currency(@user.wallet.account_balance, unit: "₦", precision: 0)
      json.account_balance @user.wallet.account_balance
   end
end
json.token @user.authentication_token