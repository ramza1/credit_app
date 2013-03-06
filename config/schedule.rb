every 1.day, at: "10.00 AM" do
  runner "User.daily_mail"
end

every 1.month, at: "10.00 AM" do
  runner "User.monthly_mail"
end

every :sunday, at: "10.00 AM" do
  runner "User.weekly_mail"
end

every 10.minutes do
  runner "Order.delete_closed_orders"
end

every 1.day, at: "11.00 PM" do
  runner "Credit.total_added_today"
end

every 1.day, at: "12:00 AM" do
  runner "Credit.low_mtn_100"
end

every 1.day, at: "1:00 AM" do
  runner "Credit.low_mtn_200"
end

every 1.day, at: "2:00 AM" do
  runner "Credit.low_mtn_400"
end

every 1.day, at: "3:00 AM" do
  runner "Credit.low_mtn_1500"
end

every 1.day, at: "4:00 AM" do
  runner "Credit.low_mtn_3000"
end

every 1.day, at: "4:30 AM" do
  runner "Credit.low_glo_100"
end

every 1.day, at: "2:30 AM" do
  runner "Credit.low_glo_500"
end

every 1.day, at: "1:30 AM" do
  runner "Credit.low_glo_1000"
end

every 1.day, at: "5:00 AM" do
  runner "Credit.low_airtel_100"
end

every 1.day, at: "3:30 AM" do
  runner "Credit.low_airtel_500"
end

every 1.day, at: "5:30 AM" do
  runner "Credit.low_airtel_1000"
end

every 1.day, at: "6:00 AM" do
  runner "Credit.low_etisalat_100"
end

every 1.day, at: "11:30 AM" do
  runner "Credit.low_etisalat_500"
end

every 1.day, at: "10:00 PM" do
  runner "Credit.low_etisalat_1000"
end
