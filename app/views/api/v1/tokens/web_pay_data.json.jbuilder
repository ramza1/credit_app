json.status "success"
json.payment do|json|
   json.product_id @interswitch[:product_id]
   json.pay_item_id  @interswitch[:pay_item_id]
   json.amount  @interswitch[:amount]
   json.currency  @interswitch[:currency]
   json.site_redirect_url  @interswitch[:site_redirect_url]
   json.txn_ref    @interswitch[:tnx_ref]
   json.site_name  @interswitch[:site_name]
   json.hash  @interswitch[:hash]
   json.url "https://webpay.interswitchng.com/paydirect/pay"
end