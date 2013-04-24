module OrdersHelper
def order_status(order)
  if(order.success?)
    return render :partial=> 'orders/order_status_message',:locals=>{:style=>"success",:message=>"Transaction Successful",:description=>"Your Transaction was successful, thank you"}
  end
  if(order.failed?)
    case order.response_code
      when "51"
        return render :partial=>'orders/order_status_message',:locals=>{:style=>"error",:message=>"Insufficient Funds",:description=>order.response_description}
      when "54"
        return render :partial=> 'orders/order_status_message',:locals=>{:style=>"error",:message=>"Expired card",:description=>order.response_description}
      when "55"
        return render :partial=> 'orders/order_status_message',:locals=>{:style=>"error",:message=>"Incorrect PIN",:description=>order.response_description}
      else
        return render :partial=> 'orders/order_status_message',:locals=>{:style=>"error",:message=>"Transaction Error",:descriptionn=>"A transaction error has occurred"}
     end
  end
end

  def admin_view(tab)
    if current_user.admin?
      return render :partial=>'orders/admin_view',locals: {current_tab: tab}
    end
  end
end
