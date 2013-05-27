module WalletsHelper
  MAC_KEY= "3D7A6A74FF8F6C9AE84050BF87E6C3D2D43A935DB2899B02FB6642AC07D845345D5A22EEFB903FD1534C8DC8431D3ECDB9D44B97782922A445AA68B0B9829706"

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
