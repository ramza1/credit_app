json.message do|json|
    status=order_status_message(order)
	json.formatted_date  "#{order.created_at.strftime('%a %d %b %Y')} #{order.created_at.strftime("%I:%M%p")}"
	json.date order.created_at.to_time.to_i.to_s
  	json.notification do|json|
  		    json.type "Transaction"
   			json.transaction_id order.transaction_id.to_s
   			json.date order.created_at.to_time.to_i.to_s
   			json.item_type order.item_type
   			json.name order.name
   			json.amount order.amount.to_s
			json.payment_method order.payment_method
			json.response_description order.response_description
			json.response_code order.response_code
   			json.amount_currency number_to_currency(order.amount, unit: "NGN ", precision: 0)
   			json.state order.state
				json.item do|json|
   					json.account_balance_currency number_to_currency(order.item.account_balance, unit: "NGN ", precision: 0)
  					json.account_balance order.item.account_balance.to_s
   					json.touch order.item.updated_at.to_time.to_i.to_s
				end
	end
end