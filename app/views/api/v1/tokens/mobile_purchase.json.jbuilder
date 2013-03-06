json.status "success"
json.user do|json|
   json.account_balance @user.account_balance
end

json.pin @order.credit.pin
json.message @order.credit.one_click

