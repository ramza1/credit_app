json.status "success"
json.user do|json|
   json.account_balance number_to_currency(@user.account_balance, unit: "₦", precision: 0)
   json.account_balance_val @user.account_balance
end

json.pin @order.credit.pin
json.message @order.credit.one_click