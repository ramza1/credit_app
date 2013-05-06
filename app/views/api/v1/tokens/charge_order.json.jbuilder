json.status "success"
json.user do|json|
   json.wallet do|json|
      json.account_balance_currency number_to_currency(@user.wallet.account_balance, unit: "NGN ", precision: 0)
      json.account_balance @user.wallet.account_balance
   end
end

json.pin @order.item.pin
json.message @order.item.one_click