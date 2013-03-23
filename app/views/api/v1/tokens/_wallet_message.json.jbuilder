json.title "Your Wallet Has Been Loaded"
json.body  "#{number_to_currency(order.amount, unit: "₦", precision: 0)} has been credited to your wallet"
json.date  order.created_at.day MONTH[order.created_at.month-1] order.created_at.strftime("%Y") order.created_at.strftime("%I:%M%p")