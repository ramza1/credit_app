   json.notification do|json|
      json.type "transaction"
      json.transaction_id @order.transaction_id.to_s
      json.date @order.created_at.to_time.to_i.to_s
      json.item_type @order.item_type
      json.name @order.name
      json.amount @order.amount.to_s
      json.response_description @order.response_description
      json.response_code @order.response_code
      json.payment_method @order.payment_method
      json.amount_currency number_to_currency(@order.amount, unit: "NGN ", precision: 0)
      json.state @order.state
      if(@order.success?)
        json.item @order.item.to_json
        if(@order.payment_method=="wallet")
          json.wallet @order.user.wallet.to_json
          end
      end
      end