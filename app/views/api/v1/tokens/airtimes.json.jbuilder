json.credits @credits do|json,credit|
  json.q_name credit.name
  json.name credit.name.humanize
  json.price number_to_currency(credit.price, unit: "NGN ", precision: 0)
  json.price_val credit.price
end
if @credits.empty?
    json.status "failed"
    json.message "out of stock"
else
    json.status "success"
end


