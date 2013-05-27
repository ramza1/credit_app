 json.status "success"
 json.transaction do|json|
 json.transaction_id @order.transaction_id.to_s
 json.name @order.item.name.humanize
 json.currency number_to_currency(@order.amount, unit: "NGN ", precision: 0)
 json.amount @order.amount
 #json.hash map_order_to_wallet_params(@order)[:hash]
 end