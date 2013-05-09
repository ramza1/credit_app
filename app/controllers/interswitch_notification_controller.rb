class InterswitchNotificationController < ApplicationController
  #before_filter :authenticate_user!,:only=>:show_order_status

  def interswitch_notify
    @txn_ref = params[:txnref]
    @order=Order.find_by_transaction_id(@txn_ref)
    if(@order)
      @order.payment_method="interswitch"
      @order.process
      Order.transaction do
        begin
        query_order_status(@order)
        respond_to do |format|
          format.html { redirect_to order_path @order}
        end
        rescue Exception => e
          logger.info "ERROR #{e.message}"
          @_errors = true
          respond_to do |format|
            format.html {redirect_to order_url(@order), alert: "Transaction Error"}
            format.json {render status: 200,:json=>{:message=>"Transaction Failed",:status=>"failed"}}
          end
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to user_orders_path(current_user),alert: "Invalid Transaction, please try again"}
      end
    end
  end

  def show_order_status
    @order=Order.find_by_transaction_id(params[:transaction_id])
    if @order
      if current_user==@order.user
         if(@order.is_processing)
           respond_to do |format|
             format.html { redirect_to order_path @order, alert: "Your Transaction is processing" }
           end
         end
         if(@order.is_successful)
           respond_to do |format|
             format.html { redirect_to order_path @order, notice: "Your Transaction was successful" }
           end
         end
         if(@order.is_failed)
           case @order.response_code
             when "51"
               #Insufficient Funds
             when "54"
               #Expired card
             when "00"
               #successful transaction
             else
               order.failure
           end
           respond_to do |format|
             format.html { redirect_to order_path @order, error: "Your Transaction failed:#{@order.response_description} " }
           end
         end
      else
        respond_to do |format|
          format.html { redirect_to root_url, alert: "Access Denied" }
        end
      end
    else
      respond_to do |format|
        format.html {redirect_to root_url, alert: "404 not found"}
      end
    end
  end

  def web_pay
    @order=Order.find_by_transaction_id(params[:transaction_id])
    param=map_order_to_interswitch_params(@order)
    url="https://stageserv.interswitchng.com/test_paydirect/pay"
    response=Typhoeus.post(url,:params=>param)
      if response.success?
        redirect_url = response.effective_url
        logger.info("Redirect url: #{redirect_url}")
        respond_to do |format|
          format.html {redirect_to redirect_url}
        end
      elsif response.timed_out?
        # aw hell no
        logger.info("Time Out")
        respond_to do |format|
          format.html {redirect_to order_path @order, error: "Time Out"}
        end
      elsif response.code == 0
        # Could not get an http response, something's wrong.
        logger.info("Unknown Error Occurred")
        respond_to do |format|
          format.html {redirect_to order_path @order, error: "Unknown Error Occurred"}
        end
      else
        logger.info("HTTP request failed: " + response.code.to_s)
        redirect_url = response.effective_url
        logger.info("Redirect url: #{redirect_url}")
        respond_to do |format|
          format.html {redirect_to order_path @order, error: "HTTP request failed: " + response.code.to_s}
        end
      end
  end
end