require 'digest'
module InterswitchHelper
  MAC_KEY= "3D7A6A74FF8F6C9AE84050BF87E6C3D2D43A935DB2899B02FB6642AC07D845345D5A22EEFB903FD1534C8DC8431D3ECDB9D44B97782922A445AA68B0B9829706"
  PRODUCT_ID="4223"
  PAY_ITEM_ID="101"
  PAY_ITEM_NAME="WEB PAY"
  CURRENCY="566"
  SITE_NAME="www.poploda.com"

  def map_order_to_interswitch_params(order,redirect=nil)
    params={}
    params[:product_id]= PRODUCT_ID
    params[:tnx_ref]= order.transaction_id
    params[:pay_item_id]= PAY_ITEM_ID
    params[:amount] = amount_to_small_denomination(order.total_amount)
    params[:site_redirect_url] = redirect||show_order_status_url
    params[:cust_id] = order.user.phone_number
    params[:cust_id_desc] = "Phone Number"
    params[:hash] = hash_post_params(params)
    params[:site_name] = SITE_NAME
    params[:currency] = CURRENCY
    logger.info("PARAMS: #{params}")
    params
  end

  def hash_post_params(params)
    message=params[:tnx_ref].to_s+params[:product_id]+params[:pay_item_id]+params[:amount].to_s+params[:site_redirect_url]+MAC_KEY
    logger.info("MESSAGE #{message}")
    Digest::SHA512.hexdigest(message)
  end

  def verify_interswitch_mac(params)
    message=params[:txn_ref].to_s+params[:product_id]+params[:pay_item_id]+params[:amount].to_s+params[:site_redirect_url]+MAC_KEY
    hash=Digest::SHA512.hexdigest(message)
    (hash==params[:hash])
  end

   def amount_to_small_denomination(amount)
     amount*100
   end

  def amount_to_large_denomination(amount)
    amount/100
  end

  def build_req_params(order)
    params={}
    params[:transactionreference]= order.transaction_id
    params[:amount]= amount_to_small_denomination(order.total_amount)
    params[:product_id]= PRODUCT_ID
    params
  end

  def build_req_url(params)
    "http://webpay.interswitchng.com/paydirect/api/v1/gettransaction.json?transactionreference=#{params[:transactionreference]}&amount=#{params[:amount]}&productid=#{params[:product_id]}"
  end

  def hash_request_params(params)
    message=params[:product_id].to_s+params[:transactionreference].to_s+MAC_KEY
    Digest::SHA512.hexdigest(message)
  end

  def test_req_params(order)
    req_params=build_req_params(order)
    logger.info("HASH: #{hash_request_params(req_params)}")
    logger.info("INTERSWITCH_REQUEST_URL: #{build_req_url(req_params)}")
  end

  def get_order_status(order)
    req_params=build_req_params(order)
    hash=hash_request_params(req_params)
    url=build_req_url(req_params)
    logger.info("HASH: #{hash_request_params(req_params)}")
    logger.info("INTERSWITCH_REQUEST_URL: #{url}")
    response=RestClient.get url,:hash => hash
    transaction = Yajl::Parser.parse(response)
  end

  def query_order_status(order)
    begin
    transaction=get_order_status(order)
    logger.info("transaction response: #{transaction}")
    process_transaction(order,transaction)
    rescue Exception => e
      logger.error "ERROR #{e.message}"
      #logger.warn $!.backtrace.collect { |b| " > #{b}" }.join("\n")
    end
  end

  def process_transaction(order,transaction)
    logger.info("transaction: #{transaction}")
    order.response_code=transaction["ResponseCode"]
    order.response_description = transaction["ResponseDescription"]
    order.save
    case order.response_code
      when "00"
        order.success
      else
        order.failure
    end
  end


  def create_payment(order,transaction)
    payment=Payment.new
    payment.order=order
    payment.payment_reference  = transaction["PaymentReference"]
    payment.retrieval_reference_number = transaction["RetrievalReferenceNumber"]
    payment.card_number=transaction["CardNumber"]
    payment.amount =amount_to_large_denomination(transaction["Amount"])
    payment.transaction_date = transaction["TransactionDate"]
    saved=payment.save
    payment
  end
end