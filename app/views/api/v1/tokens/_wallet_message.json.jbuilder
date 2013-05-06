json.message do|json|
	json.subject "Your Wallet Has Been Loaded"
	json.body  "#{number_to_currency(order.amount, unit: "NGN ", precision: 0)} has been credited to your wallet"
	json.formatted_date  "#{order.created_at.strftime('%a %d %b %Y')} #{order.created_at.strftime("%I:%M%p")}"
	json.date order.created_at.to_time.to_i.to_s
  	json.notification do|json|
  		json.type "transaction"
		json.item do|json|
   			json.transaction_id order.transaction_id.to_s
   			json.date order.created_at.to_time.to_i.to_s
   			json.item_type order.item_type
   			json.name order.name
   			json.amount order.amount.to_s
			json.response_description order.response_description
			json.response_code order.response_code
   			json.amount_currency number_to_currency(order.amount, unit: "NGN ", precision: 0)
   			json.state order.state
				json.wallet do|json|
   					json.account_balance_currency number_to_currency(order.item.account_balance, unit: "NGN ", precision: 0)
  					json.account_balance order.item.account_balance
   					json.touch order.item.updated_at.to_time.to_i.to_s
				end
		end
	end
end