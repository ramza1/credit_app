json.credits @credits do|json,credit|
  json.(credit,:id,:name,:price)
end
if @credits.empty?
    json.status "failed"
    json.message "out of stock"
else
    json.status "success"
end


