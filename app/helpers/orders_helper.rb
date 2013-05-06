module OrdersHelper
def order_status(order,success_message=nil)
  if(order.success?)
    return render :partial=> 'orders/order_status_message',:locals=>{:style=>"success",:message=>"Transaction Successful",:description=>"Your Transaction was successful, thank you.#{success_message}"}
  end
  if(order.failed?)
    if order.response_code
    case order.response_code
      when "51"
        return render :partial=>'orders/order_status_message',:locals=>{:style=>"error",:message=>"Insufficient Funds",:description=>order.response_description}
      when "54"
        return render :partial=> 'orders/order_status_message',:locals=>{:style=>"error",:message=>"Expired card",:description=>order.response_description}
      when "55"
        return render :partial=> 'orders/order_status_message',:locals=>{:style=>"error",:message=>"Incorrect PIN",:description=>order.response_description}
      else
        return render :partial=> 'orders/order_status_message',:locals=>{:style=>"error",:message=>"Transaction Error",:description=>order.response_description}
    end
    else
      return render :partial=> 'orders/order_status_message',:locals=>{:style=>"error",:message=>"Order Canceled",:description=>""}
    end

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
end
