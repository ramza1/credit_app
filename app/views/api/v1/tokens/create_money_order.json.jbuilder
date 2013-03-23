 json.status "success"
 json.transaction do|json|
 json.transaction_id @order.transaction_id.to_s
 json.name @order.item_type
 json.currency number_to_currency(@order.amount, unit: "₦", precision: 0)
 json.amount @order.amount
 end