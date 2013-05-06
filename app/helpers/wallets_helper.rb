module WalletsHelper
  MAC_KEY= "76589649D8850AA4E5D6A47370E21842D52E5902DA781F7EE00C722B7D70D798418216EFC74575C060EEECEEE0EC21F20DDB534D9C684939DEA6437E5C572B18"

  def map_order_to_wallet_params(order)
    params={}
    params[:transaction_id]= order.transaction_id
    params[:hash] =hash_post_params_w(params)
    logger.info("PARAMS: #{params}")
    params
  end

  def hash_post_params_w(params)
    message=params[:transaction_id].to_s+MAC_KEY
    Digest::SHA512.hexdigest(message)
  end


  def verify_mac(params)
    (hash_post_params_w(params)==params[:hash])
  end
end
