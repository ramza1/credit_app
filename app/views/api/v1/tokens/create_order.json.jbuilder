 json.status "success"
 json.transaction do|json|
 json.transaction_id @order.id.to_s
 json.q_name @order.credit.name
 json.name @order.credit.name.humanize
 json.price number_to_currency(@order.credit.price, unit: "₦", precision: 0)
 json.price_val @order.credit.price
 end