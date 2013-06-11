module OrdersHelper

def order_status(order,success_message=nil)
  if(order.success?)
      if success_message
        return {:style=>"success",:message=>success_message[:message],:description=>success_message[:description]}
      else
        return {:style=>"success",:message=>"Transaction Successful",:description=>"Your Transaction was successful, thank you."}
      end
  elsif(order.failed?)
    if order.response_code
      if order.payment_method=="interswitch"
        return interswitch_transaction_error_message(order)
      end
      if order.payment_method=="wallet"
        return wallet_transaction_error_message(order)
      end
    end
  elsif(order.pending?)
    return {:style=>"warning",:message=>"Transaction Pending",:description=>"Awaiting payment confirmation"}
  else
    return {:style=>"error",:message=>"Transaction Error",:description=>"An error occured while processing your transaction, please try again"}
  end
end

  def order_nav(tab)
    return render :partial=>'orders/nav',locals: {current_tab: tab}
  end

def order_nav_tab(title, url, options = {})
  current_tab = options.delete(:current)
  options[:class] = (current_tab == title) ? 'active' : ''
  link= link_to url do
   content_tag(:div,"",class:"tape").concat("#{title}")
  end
  content_tag(:li,link,options)
  end


  def interswitch_transaction_error_message(order)
    description=order.response_description||""
    if INTERSWITCH_RESPONSE_CODE_TO_MESSAGE[order.response_code]
      return {:style=>"error",:message=>"Transaction Error",:description=>description}
    elsif order.response_code=="Z6" || order.response_code=="17" 
      return {:style=>"error",:message=>"Transaction Cancelled",:description=>description}
    else
      return {:style=>"error",:message=>"Transaction Error",:description=>description}
    end
  end

  def wallet_transaction_error_message(order)
    description=order.response_description||""
    if WALLET_RESPONSE_CODE_TO_MESSAGE[order.response_code]
      return {:style=>"error",:message=>WALLET_RESPONSE_CODE_TO_MESSAGE[order.response_code],:description=>description}
    else
      return {:style=>"error",:message=>WALLET_RESPONSE_CODE_TO_MESSAGE[order.response_code],:description=>description}
    end
  end

  def order_details(order)
     if order.type=="MoneyOrder"
       render :partial=> 'money_orders/order_details'
     end
     if order.item_type=="PurchaseOrder"
       render :partial=> 'purchase_orders/order_details'
     end
  end

  def mobile_order_item(order)
    if order.item_type=="Wallet"
      return render :partial=> '/api/v1/tokens/wallet'
    end
    if order.item_type=="Airtime"
      return  render :partial=> '/api/v1/tokens/airtime'
    end
  end
  
  def order_status_message(order)
    if order.item_type=="Wallet"
    return order_status(order,{:message=>"Your Wallet Has Been Credited",:description=>"#{number_to_currency(order.amount, unit: "NGN ", precision: 0)} has been credited to your wallet"})
    end
    if order.item_type=="Airtime"
        return  order_status(order,{:message=>"#{order.item.name.upcase} recharge successful",:description=>"your pin is #{order.item.pin}.Thank you! "})
    end
  end
end
